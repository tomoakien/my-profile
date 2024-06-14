import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'count.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(CountAdapter());
  runApp(myApp());
}

class myApp extends StatefulWidget {
  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder(
            future: Hive.openBox<Count>('countBox'), //保存している箱を開ける、ない場合は作る。
            builder: (builder, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError)
                  return Text(snapshot.error.toString()); //エラーの場合
                else
                  return Home(); //正常の場合
              } else
                return Scaffold(); //開くまでの間
            }));
  }

  @override
  void dispose() {
    Hive.close(); //アプリを閉じたら、箱も閉じる
    super.dispose();
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String mailAddress = 'flutter.database@gmail.com';

  final String mailTitle = '件名です';

  final String mailContents = 'メール本文です';

  final String webSite = 'https://yahoo.co.jp';

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw '${url}が立ち上がりません';
    }
  }

  late Box box;
  @override
  void initState() {
    //画面を作る時にboxを呼び出す
    super.initState();
    box = Hive.box<Count>('countBox');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Count>>(
        valueListenable: Hive.box<Count>('countBox').listenable(),
        builder: (context, countBox, _) {
          return Scaffold(
              backgroundColor: Colors.blue.shade50,
              appBar: AppBar(
                backgroundColor: Colors.blue,
                actions: [
                  TextButton(
                      onPressed: () async {
                        await screenshotController
                            .capture(delay: const Duration(milliseconds: 10))
                            .then((image) async {
                          if (image != null) {
                            final directory =
                                (await getApplicationDocumentsDirectory()).path;
                            final imagePath =
                                await File('${directory}/image.png').create();
                            await imagePath.writeAsBytes(image);

                            //Share plugin
                            await Share.shareXFiles([XFile(imagePath.path)],
                                text: '私のプロフィールです');
                          }
                        });
                      },
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                      ))
                ],
                title: Text("My Profile"),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Screenshot(
                          controller: screenshotController,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      int ctemp = box
                                              .get('count',
                                                  defaultValue:
                                                      Count(count: 0))!
                                              .count +
                                          1;
                                      box.put('count', Count(count: ctemp));
                                      print(ctemp);
                                    },
                                    child: Icon(Icons.thumb_up),
                                  ),
                                  Text(
                                    '${countBox.get('count', defaultValue: Count(count: 0))!.count} likes',
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                              Image.asset("assets/icon.png", height: 200),
                              Text("Emily Shibuya",
                                  style: TextStyle(fontSize: 30)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "所属:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("〇〇株式会社")
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("電話:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text("090-xxx-xxxx")
                                    ]),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("メール:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("ooo@ooo.ooo"),
                                TextButton(
                                    onPressed: () async {
                                      launchURL(
                                          'mailto:${mailAddress}?subject=${mailTitle}&body=${mailContents}');
                                    },
                                    child: Icon(Icons.mail))
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "HP:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(webSite),
                              TextButton(
                                  onPressed: () async {
                                    launchURL(webSite);
                                  },
                                  child: Icon(Icons.public))
                            ],
                          ),
                        ),
                      ]),
                ),
              ));
        });
  }
}
