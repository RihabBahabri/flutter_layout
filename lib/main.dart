import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'North Gate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 121, 23, 28)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = Student.fromJson(jsonDecode(
      '{ "id": "11221133551", "name": "شهد خالد العمودي", "school": "المرحلة الثانوية", "grade": "الصف الثالث", "track": "صحة وحياة (2)" }'));
  var history = <Student>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = Student.fromJson(jsonDecode(
        '{ "id": "11221133551", "name": "أحمد العمودي", "school": "المرحلة المتوسطة", "grade": "الصف الأول", "track": "" }'));

    ;
    notifyListeners();
  }

  // var favorites = <WordPair>[];

  // void toggleFavorite([WordPair? pair]) {
  //   // pair = pair ?? current;
  //   // if (favorites.contains(pair)) {
  //   //   favorites.remove(pair);
  //   // } else {
  //   //   favorites.add(pair);
  //   // }
  //   notifyListeners();
  // }

  // void removeFavorite(WordPair pair) {
  //   // favorites.remove(pair);
  //   notifyListeners();
  // }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    Widget page;
    page = MainPage();

    var mainArea = ColoredBox(
      color: colorScheme.background,
      // color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    var qrArea = Container(
        child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Placeholder(),
      ],
    ));

    var appBar2 = AppBar(
      toolbarHeight: 64, // Set this height
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            height: 64,
          ),
          Image.asset(
            'assets/gate1.png',
            fit: BoxFit.contain,
            height: 32,
          ),
        ],
      ),
    );

    return Scaffold(
        appBar: appBar2,
        body: LayoutBuilder(builder: (context, constraints) {
          return Row(children: [
            SizedBox(width: 50),
            Expanded(flex: 3, child: mainArea),
            SizedBox(width: 50),
            Expanded(flex: 2, child: qrArea),
            SizedBox(width: 50),
          ]);
        }));
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var student = appState.current;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          BigCard(student: student),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          const Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

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
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: false,
        padding: EdgeInsets.only(bottom: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final student = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton(
                onPressed: () {
                  // appState.toggleFavorite(pair);
                },
                child: HistoryItem(student: student),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          student.name,
          // style: style.copyWith(fontWeight: FontWeight.w200),
        ),
        const Text(" - "),
        Text(
          student.school,
          // style: style.copyWith(fontWeight: FontWeight.bold),
        ),
        const Text(" - "),
        Text(
          student.grade,
          // style: style.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.student,
  }) : super(key: key);

  final Student student;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          // Make sure that the compound word wraps correctly when the window
          // is too narrow.
          child: MergeSemantics(
            child: Column(
              children: [
                Text(
                  student.name,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  student.school,
                  style: style,
                ),
                Text(
                  student.grade,
                  style: style,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
