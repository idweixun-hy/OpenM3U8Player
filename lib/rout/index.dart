// 应用的路由设置


import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/pages/about/index.dart';
import 'package:open_m3u8_player/pages/cache/index.dart';
import 'package:open_m3u8_player/pages/share_video/index.dart';
import 'package:open_m3u8_player/pages/source/index.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import '../pages/openvideo/index.dart';
import './appHome.dart';

class AppRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late XmlData _xmlData;

  @override
  void initState() {
    _xmlData = XmlData();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _xmlData),
      ],
      child: VRouter(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(58, 66, 86, 1.0),
              onPrimary: Colors.white,
              onBackground: Colors.white,
              secondary: Colors.white),
        ),
        routes: [
          // VGuard protects the routes in stackedRoutes
          VGuard(
            stackedRoutes: [
              VWidget(path: '/', widget: AppHome(xmlData: _xmlData,), stackedRoutes: [
                VWidget(path: 'about', widget: AboutPage()),
                VWidget(path: 'open_video', widget: OpenVideoPlayer()),
                VWidget(path: 'setting_source', widget: SourceSettingPage()),
                VWidget(path: 'setting_cache', widget: CacheSettingPage()),
                VWidget(path: 'share_video', widget: ShareVideoPage()),
              ])
            ],
          ),

          // :_ is a path parameters named _
          // .+ is a regexp to match any path
          VRouteRedirector(path: ':_(.+)', redirectTo: '/')
        ],
      ),
    );
  }
}
