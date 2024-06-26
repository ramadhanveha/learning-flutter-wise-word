import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var next = <WordPair>[];
  void getNext() {
    current = WordPair.random();
    next.add(current);
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void removeNext(WordPair pair) {
    next.remove(pair);
    notifyListeners();
  }

  void removeAllFavorites() {
    favorites.clear();
    notifyListeners();
  }

  void removeAllNext() {
    next.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavouritePage();
      case 2:
        page = HistoryPage();
      default:
        page = Placeholder();
    }
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex,
        destinations: [
          NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: "Home"),
          NavigationDestination(
              selectedIcon: Icon(Icons.favorite),
              icon: Icon(Icons.favorite_border_outlined),
              label: "Favorite"),
          NavigationDestination(
              selectedIcon: Icon(Icons.history),
              icon: Icon(Icons.history_outlined),
              label: "History"),
        ],
      ),
      body: Container(
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("it's ${appState.current}"),
                      ),
                    );
                },
                icon: Icon(icon),
                label: Text('Favorites'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavouritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Favorites (${appState.favorites.length}):'),
                if (appState.favorites.isEmpty)
                  Center(
                    child: Text('No favorites yet.'),
                  )
                else
                  Expanded(
                    child: ListView(
                      children: [
                        for (var pair in appState.favorites)
                          ListTile(
                            leading: Icon(Icons.favorite),
                            title: Text(pair.asLowerCase),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                appState.removeFavorite(pair);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Remove ${appState.current}"),
                                    ),
                                  );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    appState.removeAllFavorites();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("Remove all success"),
                        ),
                      );
                  },
                  child: Text('Remove All Favorites'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Spasi antara dua kolom
          Expanded(
            child: Column(
              children: [
                Text('Next History:'),
                if (appState.next.isEmpty)
                  Center(
                    child: Text('No history yet.'),
                  )
                else
                  Expanded(
                    child: ListView(
                      children: [
                        for (var pair in appState.next)
                          ListTile(
                            leading: Icon(Icons.history),
                            title: Text(pair.asLowerCase),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                appState.removeNext(pair);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Remove ${appState.current}"),
                                    ),
                                  );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    appState.removeAllNext();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("Remove all success"),
                        ),
                      );
                  },
                  child: Text('Remove All History'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
