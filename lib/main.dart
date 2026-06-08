import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TntToeicApp());
}

class TntToeicApp extends StatelessWidget {
  const TntToeicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TNT TOEIC Day 11-18',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457DF)),
        useMaterial3: true,
      ),
      home: const ToeicHomePage(),
    );
  }
}

class ToeicHomePage extends StatefulWidget {
  const ToeicHomePage({super.key});

  @override
  State<ToeicHomePage> createState() => _ToeicHomePageState();
}

class _ToeicHomePageState extends State<ToeicHomePage> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  static const String _htmlAsset = 'assets/web/index.html';
  static const List<String> _audioAssets = [
    '11-01.mp3','11-02.mp3','11-03.mp3','11-04.mp3','11-05.mp3','11-06.mp3','11-07.mp3','11-08.mp3','11-09.mp3','11-10.mp3',
    '12-01.mp3','12-02.mp3','12-03.mp3','12-04.mp3','12-05.mp3','12-06.mp3','12-07.mp3','12-08.mp3','12-09.mp3','12-10.mp3',
    '13-01.mp3','13-02.mp3','13-03.mp3','13-04.mp3','13-05.mp3','13-06.mp3','13-07.mp3','13-08.mp3','13-09.mp3','13-10.mp3',
    '14-01.mp3','14-02.mp3','14-03.mp3','14-04.mp3','14-05.mp3','14-06.mp3','14-07.mp3','14-08.mp3','14-09.mp3','14-10.mp3',
    '15-01.mp3','15-02.mp3','15-03.mp3','15-04.mp3','15-05.mp3','15-06.mp3','15-07.mp3','15-08.mp3','15-09.mp3','15-10.mp3',
    '16-01.mp3','16-02.mp3','16-03.mp3','16-04.mp3','16-05.mp3','16-06.mp3','16-07.mp3','16-08.mp3','16-09.mp3','16-10.mp3',
    '17-01.mp3','17-02.mp3','17-03.mp3','17-04.mp3','17-05.mp3','17-06.mp3','17-07.mp3','17-08.mp3','17-09.mp3','17-10.mp3',
    '18-01.mp3','18-02.mp3','18-03.mp3','18-04.mp3','18-05.mp3','18-06.mp3','18-07.mp3','18-08.mp3','18-09.mp3','18-10.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // iOS can emit harmless favicon/local-media warnings, so do not block UI here.
          },
        ),
      );

    _prepareAndLoad();
  }

  Future<void> _prepareAndLoad() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final Directory webDir = Directory('${dir.path}/tnt_toeic_web');
      final Directory audioDir = Directory('${webDir.path}/audio');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // Copy HTML.
      final String html = await rootBundle.loadString(_htmlAsset);
      final File htmlFile = File('${webDir.path}/index.html');
      await htmlFile.writeAsString(html, flush: true);

      // Copy MP3 files. Keeping them as real local files makes iOS WebView audio more reliable.
      for (final String name in _audioAssets) {
        final ByteData data = await rootBundle.load('assets/web/audio/$name');
        final File out = File('${audioDir.path}/$name');
        if (!await out.exists() || await out.length() != data.lengthInBytes) {
          await out.writeAsBytes(data.buffer.asUint8List(), flush: true);
        }
      }

      await _controller.loadFile(htmlFile.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _reloadApp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _prepareAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TNT TOEIC Day 11–18'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reloadApp,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_error == null) WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Đang mở bộ đề offline...'),
                ],
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Không mở được bộ đề:\n$_error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
