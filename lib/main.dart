import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

import 'student.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(const MainApp()));

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
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('ar'),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 121, 23, 28)),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = Student.fromJson(jsonDecode(
      '{ "id": "", "name": "                                    ", "school": "", "grade": "", "track": "" }'));
  var history = <Student>[];

  GlobalKey? historyListKey;

  void getNext(student) {
    try {
      var studentString = jsonDecode(student);
      print(studentString);
      var nextStudent = Student.fromJson(studentString);

      var index = history.indexWhere((item) => item.id == nextStudent.id);
      print(index);
      if (current.id != nextStudent.id && index == -1) {
        history.insert(0, current);
        var animatedList = historyListKey?.currentState as AnimatedListState?;
        animatedList?.insertItem(0);
        current = nextStudent;
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    page = const MainPage();

    var mainArea = ColoredBox(
      color: colorScheme.background,
      // color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    var qrArea = QrWidget(appState: appState);

    var appBar2 = AppBar(
      toolbarHeight: 64, // Set this height
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Padding(padding: EdgeInsets.all(1)),
          const Expanded(
            flex: 1,
            child: SizedBox(width: 1),
          ),
          Expanded(
            flex: 5,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              height: 64,
            ),
          ),
          const Expanded(
            flex: 15,
            child: SizedBox(width: 10),
          ),
          Expanded(
            flex: 5,
            child: Image.asset(
              'assets/gate1.png',
              fit: BoxFit.contain,
              height: 32,
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(width: 10),
          ),
          // Padding(padding: EdgeInsets.all(1)),
        ],
      ),
    );

    return Scaffold(
        appBar: appBar2,
        body: LayoutBuilder(builder: (context, constraints) {
          return Row(children: [
            const SizedBox(width: 25),
            Expanded(flex: 3, child: mainArea),
            const SizedBox(width: 25),
            Expanded(flex: 2, child: qrArea),
            const SizedBox(width: 100),
          ]);
        }));
  }
}

class QrWidget extends StatelessWidget {
  const QrWidget({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: RotatedBox(
        quarterTurns: 3,
        child: MobileScanner(
            controller: MobileScannerController(
              facing: CameraFacing.front,
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                appState.getNext(barcode.rawValue ?? '');
              }
            }),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          BigCard(),
          SizedBox(height: 50),
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
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

    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: false,
        padding: const EdgeInsets.only(bottom: 100),
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
    var theme = Theme.of(context);
    var style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.primary,
    );

    return Wrap(
      children: [
        Text(
          student.name,
          style: style.copyWith(fontWeight: FontWeight.bold),
        ),
        const Text("   "),
        Text(
          student.school,
          style: style.copyWith(fontWeight: FontWeight.w100),
        ),
        const Text("   "),
        Text(
          student.grade,
          style: style.copyWith(fontWeight: FontWeight.w100),
        ),
      ],
    );
  }
}

class BigCard extends StatefulWidget {
  const BigCard({
    Key? key,
  }) : super(key: key);

  @override
  State<BigCard> createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final student = appState.current;
    var theme = Theme.of(context);

    var style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
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
