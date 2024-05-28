import 'package:flutter/material.dart';
import 'package:tvtime/model/tvShow.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _currentPage = 1;

  void _increment() {
    setState(() {
      _currentPage++;
    });
  }

  void _decrement() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  void _resetPage() {
    setState(() {
      _currentPage = 1;
    });
  }

  Future<List<tvShow>> fetchTvShows(int currentPage) async {
    final response = await http.get(Uri.parse('https://www.episodate.com/api/most-popular?page=$currentPage'));
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<dynamic> tvShowsJson = jsonResponse['tv_shows'];
      return tvShowsJson.map((json) => tvShow.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load TV shows');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF202238),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TV Shows', style: TextStyle(color: Colors.white)),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))
            )),
          ],
        ),
        elevation: 4.0,
        actions: [
          IconButton(
            onPressed: _resetPage,
            icon: const Icon(Icons.update, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<List<tvShow>>(
        future: fetchTvShows(_currentPage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No TV shows found'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final tvShow = snapshot.data![index];
                  return Card(
                    color: const Color(0xFF202238),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.network(
                              tvShow.imageThumbnailPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            tvShow.name,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              tooltip: 'Increment',
              onPressed: _increment,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Align(
            alignment: Alignment.bottomCenter,
            // Page
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Page $_currentPage',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              tooltip: 'Decrement',
              onPressed: _decrement,
              child: const Icon(Icons.remove, color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF01031C),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
