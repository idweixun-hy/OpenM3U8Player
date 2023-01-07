import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/m3u8CachePoint.dart';
import 'package:open_m3u8_player/data/m3u8TempPoint.dart';

class CacheSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CacheSettingState();
}

class _CacheSettingState extends State<CacheSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("缓存管理"),
        ),
        body: SafeArea(
          child: Builder(builder: (BuildContext context) {
            List<Widget> widgetList = <Widget>[
              Builder(builder: (BuildContext context) {
                return FutureBuilder<String>(
                    future: M3u8TempPoint.allSizeStr(),
                    builder: (BuildContext buildContext,
                        AsyncSnapshot<String> snapshot) {
                      String tempPointSizeStr = "0";
                      if (snapshot.hasData) {
                        tempPointSizeStr = snapshot.data!;
                      }
                      return SimpleDialogOption(
                        child: Text(
                          "清空视频观看缓存:$tempPointSizeStr",
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () async {
                          // 清空视频观看缓存
                          await M3u8TempPoint.cleanAll();
                          (context as Element).markNeedsBuild();
                        },
                      );
                    });
              }),
              Builder(builder: (BuildContext context) {
                return FutureBuilder<String>(
                    future: M3u8CachePoint.allSizeStr(),
                    builder: (BuildContext buildContext,
                        AsyncSnapshot<String> snapshot) {
                      String cachePointSizeStr = "0";
                      if (snapshot.hasData) {
                        cachePointSizeStr = snapshot.data!;
                      }
                      return SimpleDialogOption(
                        child: Text(
                          "清空视频下载缓存:$cachePointSizeStr",
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () async {
                          // 清空视频下载缓存
                          await M3u8CachePoint.cleanAll();
                          (context as Element).markNeedsBuild();
                        },
                      );
                    });
              }),
            ];

            return SingleChildScrollView(
              child: Column(
                children: widgetList,
              ),
            );
          }),
        ),
    );
  }
}
