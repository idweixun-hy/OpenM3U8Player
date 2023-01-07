import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DlnaDialog extends StatefulWidget {
  final DLNADevice dev;
  final String videoM3u8Url;

  DlnaDialog(this.dev, this.videoM3u8Url);

  @override
  State<StatefulWidget> createState() {
    return DlnaDialogState(dev, videoM3u8Url);
  }
}

class DlnaDialogState extends State<DlnaDialog> {
  final DLNADevice dev;
  PositionParser? position;
  Timer timer = Timer(Duration(seconds: 1), () {});
  final String videoM3u8Url;
  late FToast fToast;

  DlnaDialogState(this.dev, this.videoM3u8Url) {
    final callback = (_) async {
      final text = await dev.position();
      final p = PositionParser(text);
      setState(() {
        position = p;
      });
    };
    timer = Timer.periodic(Duration(seconds: 5), callback);
    callback(null);
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialog = Container(
        child: ListView(
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: Text(
            dev.info.friendlyName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: Text(
            dev.info.URLBase,
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ),
        SizedBox(
          height: 160,
          child: buildCurrUri(),
        ),
        buildActions(),
      ],
    ));

    return SizedBox(
      child: dialog,
      height: 430,
      width: MediaQuery.of(context).size.width - 100,
    );
  }

  Widget buildCurrUri() {
    if (position == null || position!.TrackURI.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: Text("暂无视频信息"),
      );
    }
    final List<Widget> slist = [];
    slist.add(Align(
      alignment: Alignment.topLeft,
      child: Text(
        "当前播放:",
        style: TextStyle(color: Colors.green),
      ),
    ));
    var currUrl = position!.TrackURI;
    if (currUrl.length > 100) {
      currUrl = currUrl.substring(0, 100) + '...';
    }
    slist.add(Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              child: Text(
                currUrl,
                style: TextStyle(fontSize: 12, color: Colors.orange),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                ClipboardData data = ClipboardData(text: position!.TrackURI);
                Clipboard.setData(data);
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "已复制",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              },
            ))));
    if (position!.AbsTime.isNotEmpty) {
      slist.add(Container(
        child: Align(
          child: Text(position!.AbsTime + " / " + position!.TrackDuration),
          alignment: Alignment.topLeft,
        ),
      ));
    }
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(10),
        child: Card(
          elevation: 1,
          color: Colors.white70,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: slist,
            ),
          ),
        ));
  }

  Widget buildActions() {
    final style = TextStyle(fontSize: 12);
    final push = ElevatedButton(
      child: Text("投屏"),
      onPressed: () async {
        final v = this.videoM3u8Url;
        if (v.isEmpty) {
          fToast.showToast(
            gravity: ToastGravity.CENTER,
            child: Text(
              "请输入http地址",
              style: TextStyle(
                backgroundColor: Colors.blue,
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          );
          return;
        }
        try {
          await dev.setUrl(v);
          await dev.play();
        } catch (e) {
          fToast.showToast(
            gravity: ToastGravity.CENTER,
            child: Text(
              "$e",
              style: TextStyle(
                backgroundColor: Colors.blue,
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          );
        }
        Timer(Duration(seconds: 2), () async {
          final text = await dev.position();
          position = PositionParser(text);
        });
      },
    );
    final play = SizedBox(
        width: 60,
        height: 30,
        child: ElevatedButton(
          onPressed: () async {
            try {
              await dev.play();
            } catch (e) {
              fToast.showToast(
                gravity: ToastGravity.CENTER,
                child: Text(
                  "$e",
                  style: TextStyle(
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              );
            }
          },
          child: Text(
            "播放",
            style: style,
          ),
        ));
    final pause = SizedBox(
        width: 60,
        height: 30,
        child: ElevatedButton(
            onPressed: () async {
              try {
                await dev.pause();
              } catch (e) {
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "$e",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              }
            },
            child: Text(
              "暂停",
              style: style,
            )));
    final stop = SizedBox(
        width: 60,
        height: 30,
        child: ElevatedButton(
            onPressed: () async {
              try {
                await dev.stop();
              } catch (e) {
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "$e",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              }
            },
            child: Text("停止", style: style)));
    final prev10 = SizedBox(
        width: 90,
        height: 30,
        child: ElevatedButton(
            onPressed: () async {
              try {
                final curr = await dev.position();
                final p = PositionParser(curr);
                setState(() {
                  position = p;
                });
                dev.seekByCurrent(curr, -10);
              } catch (e) {
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "$e",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              }
            },
            child: Text("快退10秒", style: style)));
    final next10 = SizedBox(
        width: 90,
        height: 30,
        child: ElevatedButton(
            onPressed: () async {
              try {
                final curr = await dev.position();
                final p = PositionParser(curr);
                setState(() {
                  position = p;
                });
                dev.seekByCurrent(curr, 10);
              } catch (e) {
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "$e",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              }
            },
            child: Text("快进10秒", style: style)));

    final prev30 = SizedBox(
        width: 90,
        height: 30,
        child: ElevatedButton(
            onPressed: () async {
              try {
                final curr = await dev.position();
                final p = PositionParser(curr);
                setState(() {
                  position = p;
                });
                await dev.seekByCurrent(curr, -30);
              } catch (e) {
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "$e",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              }
            },
            child: Text("快退30秒", style: style)));
    final next30 = SizedBox(
        width: 90,
        height: 30,
        child: ElevatedButton(
            onPressed: () async {
              try {
                final curr = await dev.position();
                final p = PositionParser(curr);
                setState(() {
                  position = p;
                });
                await dev.seekByCurrent(curr, 30);
              } catch (e) {
                fToast.showToast(
                  gravity: ToastGravity.CENTER,
                  child: Text(
                    "$e",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              }
            },
            child: Text("快进30秒", style: style)));

    return Container(
      child: Column(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              push,
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              play,
              pause,
              stop,
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [next10, prev10],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [next30, prev30],
          ),
        ],
      ),
    );
  }
}
