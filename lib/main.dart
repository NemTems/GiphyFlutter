import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giphy App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gifs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> gifs = [];
  int offset = 0;
  String query = '';
  Timer? queryTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: TextField(
          controller: searchController,
          onChanged: (query){
            // Live search implementation 
            queryTimer?.cancel();
            // Previosly Future class was used. Changed due to incorrect work
            queryTimer = Timer(const Duration(milliseconds: 400), () {
              gifs = [];
              searchGifs(query);
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search Gifs',
          ),
        ),
      ),
        body: buildGifList(),
    );
  }

    // Grid type of view
    Widget buildGifList(){ 
      return GridView.builder(
        itemCount: gifs.length,
        padding: const EdgeInsets.all(0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          //  mainAxisSpacing: 0.0,
          //  crossAxisSpacing: 0.0,
        ),
        itemBuilder: (context, index){
          
          // load more, when user reaching the 10th gif from the end (Bonus thing(I hope))
          if(index == gifs.length-10){
            _loadMoreGifs();
          }
          return ListTile(
            title: Image.network(gifs[index]['images']['fixed_height']['url']),        
          );
        },
      );
    }

    // gif searching function for the first part  
  Future<void> searchGifs(query) async {
    final gifUri = Uri.https(
      'api.giphy.com',
      '/v1/gifs/search',
      {'api_key': 'Pyoqvh7L7elrqaYVAeqBnhO1KqMpd8gy', 'q': query},
    );
    
    //get request f giphy 
    final response = await http.get(
      gifUri,
      headers: {'api_key': 'Pyoqvh7L7elrqaYVAeqBnhO1KqMpd8gy'},
      );

    if(response.statusCode == 200){
      setState(() {
        gifs.addAll(json.decode(response.body)['data']);
        offset = gifs.length;
      });
    }
  }

  // gif load function for the live search
  Future<void> _loadMoreGifs() async {
    final gifUri = Uri.https(
      'api.giphy.com',
      '/v1/gifs/search',
      {
      'api_key': 'Pyoqvh7L7elrqaYVAeqBnhO1KqMpd8gy',
      'q': searchController.text,
      'offset':'$offset',
      },
    );

    final response = await http.get(
      gifUri,
      headers: {'api_key': 'Pyoqvh7L7elrqaYVAeqBnhO1KqMpd8gy'},
      );

    if(response.statusCode == 200){
      setState(() {
        gifs.addAll(json.decode(response.body)['data']);
        offset = gifs.length;
      });
    }
  }
}


