// 关于

import 'package:flutter/material.dart';
import 'package:open_m3u8_player/util/fit_text_box.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("关于"),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Image.asset("assets/fp.png"),
              Card(
                child: Container(
                  width: double.infinity,
                  height: 100.0 + 30.0,
                  // color: Colors.red[200],
                  child: FitTextBox(
                    showText:
                        "开源视频播放器：一款使用flutter简单开发的视频播放器，欢迎使用反馈，关注公众号【开源视频播放器】获得更多支持。",
                    fixedHeightHeaderWidget: Container(
                      width: 100.0,
                      height: 30.0,
                      color: Color(0x00000000),
                    ),
                    fixedHeightBottomWidget: Container(
                      color: Color(0x00000000),
                    ),
                    textStyle: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
