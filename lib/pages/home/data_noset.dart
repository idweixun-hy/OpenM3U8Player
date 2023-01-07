// 当资源没有选中的时候 展示的页面

import 'package:flutter/material.dart';
import 'package:open_m3u8_player/util/page_util.dart';
import 'package:vrouter/vrouter.dart';

import '../../util/fit_text_box.dart';

ShapeBorder shape = PageUtil.shape;

class HomeDataNoSet extends StatelessWidget {
  final String title;

  const HomeDataNoSet({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        // actions: _actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Icon(Icons.favorite),
              MaterialButton(
                shape: shape,
                color: Theme.of(context).textTheme.button!.color,
                textColor: Colors.white,
                child: new Text('去资源配置'),
                onPressed: () => context.vRouter.to("/setting_source"),
                // onPressed: _setting_on_pressed,
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Icon(Icons.favorite),
              MaterialButton(
                shape: shape,
                color: Theme.of(context).textTheme.button!.color,
                textColor: Colors.white,
                child: new Text('去打开视频'),
                onPressed: () => context.vRouter.to("/open_video"),
                // onPressed: _setting_on_pressed,
              )
            ]),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                width: double.infinity,
                height: 100.0 ,
                decoration: BoxDecoration(
                  color: Colors.white, // 背景色
                  border: new Border.all(
                      color: Color.fromRGBO(91, 112, 137, 1.0),
                      width: 0.5), // border
                  borderRadius: BorderRadius.circular((8)), // 圆角
                ),
                child: FitTextBox(
                    showText:
                        "本软件自身不包含任何影视资源，仅仅提供网络媒体或本地视频的播放能力。\n如需要进行影视资源的搜索点播，请自行进行资源配置。",
                    fixedHeightHeaderWidget: Container(
                      width: 100.0,
                      height: 8.0,
                      color: Color(0x00000000),
                    ),
                    fixedHeightBottomWidget: Container(
                      color: Color(0x00000000),
                    ),
                    textStyle: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
