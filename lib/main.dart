import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'strings.dart';

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
        title: 'evosus App',
        theme: ThemeData(
          useMaterial3: true,

          //changed color scheme to orange to better fit the company brand
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            primary: Colors.orange,
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // added history variable to hold the previous wordpairs
  var history = <WordPair>[];

  // added historylistkey as globalkey
  GlobalKey? historyListKey;

  // Added getNext()
  // insert current wordpair into history wordpair
  // added an animatedlist which will visually show the previous wordpairs
  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  // Added favorites
  var favorites = <WordPair>[];

  // modified the variable current as pair so if the current pair exists,
  // it will be removed
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  // added removeFavorite function to remove favorite pairword
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

// Replaced MyHomePage with a modified code
// Changed stateless to stateful
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Added a selectindex variable
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    // Added colorScheme theme variable
    var colorScheme = Theme.of(context).colorScheme;

    // added a page widget to change pages
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
        case 1:
        // set page to FavoritesPage
          page = FavoritesPage();
        // Added another page called AboutMe
        case 2:
          page = AboutMePage();
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }

    // Container for current page with background color with subtle switching animation
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    // added layoutbuilder to scaffold for constraints
    // modified screen layout with BottomNavigationBar for narrow screens
    // changed favorite icons to fireplace to better fit evosus customer base
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.fireplace),
                        label: 'Favorites',
                      ),

                      // Added AboutMe on the bottom side of the navigation bar
                      BottomNavigationBarItem(
                        icon: Icon(Icons.question_mark),
                        label: 'About Me',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.fireplace),
                        label: Text('Favorites'),
                      ),

                      // Added About Me on the navigation rail
                      NavigationRailDestination(
                        icon: Icon(Icons.question_mark),
                        label: Text('About Me'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

// Added a AboutMePage that tells a little bit of myself, has padding around the side
// so that the text isnt touching the side, centered so it is easy to read.
class AboutMePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // used string from string file, all string variables should be used in a string file
            Text(aboutMeString),
          ],
        ),
      )
    );
  }
}

// added GeneratorPage that contains all favorite wordpairs
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;

    // Changed icon to fireplace from favorite to better reflect hearth
    if (appState.favorites.contains(pair)) {
      icon = Icons.fireplace;
    } else {
      icon = Icons.fireplace_outlined;
    }

    // Added HistoryListView() to visually show wordpair history
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
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
          // puts space between the bottom so its not all the way at the bottom
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
    }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {

    // added variable theme and style
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // Refactored to return card instead of widget
    // Set padding to 20 instead of 8
    // added color based on theme
    // Changed child of card to have AnimatedSize and use pair
    // Card will animate to size of wordpair
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                  ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],)
          )
        )
      ),
    );
  }
}

// Added a new favorites page
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // added theme variable
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty)
    {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    // Changed Listview into Column, set padding to 30
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),

          // Tooltip text has been updated to be more imformative
          // increased text size for better visibility
          child: Text('You have chosen '
              '${appState.favorites.length} pair words as your favorite:',
              style:DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0) ),
        ),

        // Changed to gridview so that pairwords are easily viewable in different dimensions
        // add a button to delete favorited pairwords
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
          ),
          children: [
            for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
              color: theme.colorScheme.primary,
              onPressed: ()
              {
                appState.removeFavorite(pair);
              },
            ),
            title: Text(pair.asLowerCase, semanticsLabel: pair.asPascalCase,
            ),
          ),
          ],
          ),
        )
      ],
    );
  }
}

// Added HistoryListView class
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
