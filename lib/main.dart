import 'dart:convert';
import 'package:flutter/material.dart';
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
      theme: ThemeData.dark(),
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
  TextEditingController _searchController = TextEditingController();
  List<Repository> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("yumemi passport"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter keyword...',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _searchRepositories();
            },
            child: Text('Search'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index].name),
                  onTap: () {
                    _showRepositoryDetails(_searchResults[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _searchRepositories() async {
    String keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      final response = await http.get(
        Uri.parse('https://api.github.com/search/repositories?q=$keyword'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'];

        List<Repository> repositories = List.generate(
          items.length,
          (index) => Repository.fromJson(items[index]),
        );

        setState(() {
          _searchResults = repositories;
        });
      } else {
        // Handle error
        print('Failed to load repositories');
      }
    }
  }

  void _showRepositoryDetails(Repository repository) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(repository.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Owner: ${repository.owner}'),
              Text('Language: ${repository.language}'),
              Text('Stars: ${repository.stars}'),
              Text('Watchers: ${repository.watchers}'),
              Text('Forks: ${repository.forks}'),
              Text('Issues: ${repository.issues}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class Repository {
  final String name;
  final String owner;
  final String language;
  final int stars;
  final int watchers;
  final int forks;
  final int issues;

  Repository({
    required this.name,
    required this.owner,
    required this.language,
    required this.stars,
    required this.watchers,
    required this.forks,
    required this.issues,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'],
      owner: json['owner']['login'],
      language: json['language'] ?? 'N/A',
      stars: json['stargazers_count'],
      watchers: json['watchers_count'],
      forks: json['forks_count'],
      issues: json['open_issues_count'],
    );
  }
}
