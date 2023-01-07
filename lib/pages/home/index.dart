// app  首页布局

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_m3u8_player/pages/home/consumer_drawer.dart';
import 'package:open_m3u8_player/pages/home/video_list.dart';
import 'package:open_m3u8_player/pages/search/index.dart';
import 'package:open_m3u8_player/pages/video_model_history/index.dart';

import 'package:open_m3u8_player/data/XmlDataGet.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TagList();
  }
}

class TagList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TagList();
}

class _TagList extends State<TagList> with TickerProviderStateMixin {
  List<Map<String, String>> tyList = <Map<String, String>>[];
  TabController? _tabController;
  late int initialIndex;
  late List<Widget> _actions;

  @override
  void initState() {
    super.initState();
    initialIndex = 0;

    _actions = <Widget>[
      IconButton(
        icon: Icon(Icons.search, ),
        tooltip: '搜索',
        onPressed: () =>
            showSearch(context: context, delegate: SearchBarDelegate()),
      ),
      IconButton(
        icon: Icon(Icons.history),
        tooltip: '历史',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VideoModelCachePage()),
          );
        },
      ),
    ];
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.watch<XmlData>().getXml2VideoTypeList(
            context.watch<XmlData>().getWebXmlDataTypeList()),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            tyList = snapshot.data as List<Map<String, String>>;
            // tyList.removeWhere((Map<String,String> tyMap){
            //   return tyMap["tyText"].indexOf("视频") >= 0 ||tyMap["tyText"].indexOf("写真") >= 0 ||tyMap["tyText"].indexOf("福利") >= 0 ||tyMap["tyText"].indexOf("美女") >= 0 ||tyMap["tyText"].indexOf("伦理") >= 0 ||tyMap["tyText"].indexOf("系列") >= 0;
            // });
            if (null != _tabController &&
                _tabController!.index < tyList.length) {
              initialIndex = _tabController!.index;
              _tabController!.dispose();
            }
            initialIndex =
                tyList.length > 0 ? min(initialIndex, tyList.length - 1) : 0;
            _tabController = new TabController(
                initialIndex: initialIndex, vsync: this, length: tyList.length);
            return Scaffold(
                  drawer: ConsumerDrawer(),
                  appBar: AppBar(
                    actions: _actions,
                    bottom: TabBar(
                      controller: _tabController,
                      //可以和TabBarView使用同一个TabController
                      tabs: tyList
                          .map((Map<String, String> tyMap) => Tab(
                                text: tyMap["tyText"],
                              ))
                          .toList(),
                      isScrollable: true,
                      indicatorColor: Color(0xffff0000),
                      indicatorWeight: 1,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.only(bottom: 10.0),
                      labelColor: Colors.orange,
                      labelStyle: TextStyle(
                        fontSize: 15.0,
                      ),
                      unselectedLabelColor: Colors.white,
                      unselectedLabelStyle: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  body: SafeArea(
                    child: TabBarView(
                        controller: _tabController,
                        children: tyList
                            .map((Map<String, String> tyMap) => Container(
                                  child: VideoList(
                                    tId: tyMap["tyId"],
                                    wd: "",
                                  ),
                                ))
                            .toList()),
                  ),
                );
          }
          return Scaffold(
              drawer: ConsumerDrawer(),
              appBar: AppBar(
                actions: _actions,
              ),
              body: SafeArea(
                child: Text(
                  "数据加载",
                  textAlign: TextAlign.center,
                ),
              ),
          );
        });
  }
}
