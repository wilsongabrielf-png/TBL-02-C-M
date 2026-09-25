import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  Pokemon? pokemon;

  String? erro;

  final TextEditingController controller = TextEditingController();

  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> buscarPokemon(String busca) async {
    busca = busca.trim();

    if (busca.isEmpty) {
      setState(() {
        erro = 'Digite um nome ou número.';
        pokemon = null;
      });

      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/$busca',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          pokemon = Pokemon.fromJson(data);
          erro = null;
        });
      } else {
        setState(() {
          pokemon = null;
          erro = 'Pokémon não encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        pokemon = null;
        erro = 'Erro ao conectar com a API.';
      });
    }
  }

  Future<void> tocarCry() async {
    if (pokemon == null) {
      return;
    }

    if (pokemon!.cryUrl.isEmpty) {
      return;
    }

    await audioPlayer.play(
      UrlSource(pokemon!.cryUrl),
    );
  }

  void pokemonAnterior() {
    if (pokemon == null) {
      return;
    }

    if (pokemon!.id <= 1) {
      return;
    }

    buscarPokemon(
      '${pokemon!.id - 1}',
    );
  }

  void pokemonProximo() {
    if (pokemon == null) {
      return;
    }

    buscarPokemon(
      '${pokemon!.id + 1}',
    );
  }

  @override
  void initState() {
    super.initState();

    buscarPokemon('1');
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nome ou número',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                buscarPokemon(controller.text);
              },
              child: const Text('Buscar'),
            ),

            const SizedBox(height: 20),

            if (erro != null)
              Text(
                erro!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),

            if (pokemon != null) ...[
              Text(
                '#${pokemon!.id}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                pokemon!.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Image.network(
                pokemon!.imageUrl,
                width: 250,
                height: 250,
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: tocarCry,
                child: const Text('🔊 Ouvir'),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: pokemon!.id > 1
                        ? pokemonAnterior
                        : null,
                    child: const Text('← Anterior'),
                  ),

                  ElevatedButton(
                    onPressed: pokemonProximo,
                    child: const Text('Próximo →'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
