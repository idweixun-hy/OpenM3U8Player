import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/XmlDataGet.dart';
import '../data/site_source_model.dart';
import '../data/videomodelcache.dart';
import '../pages/home/data_noset.dart';
import '../pages/home/index.dart';

class AppHome extends StatefulWidget {
  final XmlData xmlData;

  const AppHome({Key? key, required this.xmlData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppHomeState();
}
class AppHomeState extends State<AppHome>{
  bool apiBaseIsOk = false ;


  @override
  void initState() {
    super.initState();
    VideoModelCache.tempSourceSiteCacheManager
        .getString(VideoModelCache.SOURCE_SITE_CACHE_KEY_TRY_CACHE)
    .then((value) {
      if (value != null) {
        List<dynamic> sourceSiteListDecode = json.decode(value);
        List<SiteSourceModel> siteSourceModelList =
        getSiteSourceModelList(sourceSiteListDecode);
        if (siteSourceModelList.isNotEmpty && !apiBaseIsOk) {
          SiteSourceModel siteSourceModel = siteSourceModelList.first;
          if( widget.xmlData.apiBase != siteSourceModel.url!){
            widget.xmlData.apiBase = siteSourceModel.url!;
            widget.xmlData.title = siteSourceModel.name!;
          }
        }
      }
      if (!apiBaseIsOk){
        setState(() {
          apiBaseIsOk = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<XmlData>().addListener(() {
      if (!apiBaseIsOk && widget.xmlData.apiBase.isNotEmpty){
        setState(() {
          apiBaseIsOk = true;
        });
      }
    });
    return FutureBuilder<String?>(
        future: Future.value(widget.xmlData.apiBase),
        builder: (BuildContext buildContext, AsyncSnapshot<String?> snapshot) {
          if (!apiBaseIsOk || snapshot.connectionState == ConnectionState.waiting ){
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "开源视频播放器",
                  textAlign: TextAlign.center,
                ),
                // actions: _actions,
              ),
              body: SafeArea(
                child: Container(
                  height: 300.0,
                  child: Center(
                    child: Text("当前配置加载中……"),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasData && (snapshot.data??"").isNotEmpty) {
            return HomePage();
          }
          return HomeDataNoSet(
            title: "请进行资源配置",
          );
        }
    );
  }
}
