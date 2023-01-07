import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class ConsumerDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _consumerDrawerState();
}

class _consumerDrawerState extends State<ConsumerDrawer> {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        ),
        child: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: UserAccountsDrawerHeader(
                        accountName: Text('开源视频播放器'),
                        accountEmail: Text('为生活加点儿料'),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: AssetImage("assets/fp.png"),
                        ), //用户头像
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(58, 66, 86, 1.0)), //背景
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                    child: Icon(Icons.account_tree_outlined),
                  ),
                  title: Text('数据源管理'),
                  onTap: () {
                    // Navigator.of(context).pop(); //隐藏侧边栏
                    Scaffold.of(context).openEndDrawer();
                    context.vRouter.to("/setting_source");
                  },
                ),
                Divider(), // 增加一条线
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                    child: Icon(Icons.voice_chat_outlined),
                  ),
                  title: Text('打开视频'),
                  onTap: () {
                    // Navigator.of(context).pop(); //隐藏侧边栏
                    Scaffold.of(context).openEndDrawer();
                    context.vRouter.to("/open_video");
                  },
                ),
                Divider(), // 增加一条线
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                    child: Icon(Icons.share),
                  ),
                  title: Text('打开分享的视频'),
                  onTap: () {
                    // Navigator.of(context).pop(); //隐藏侧边栏
                    Scaffold.of(context).openEndDrawer();
                    context.vRouter.to("/share_video");
                  },
                ),
                Divider(), // 增加一条线
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                    child: Icon(Icons.cached_outlined),
                  ),
                  title: Text('缓存管理'),
                  onTap: () {
                    // Navigator.of(context).pop(); //隐藏侧边栏
                    Scaffold.of(context).openEndDrawer();
                    context.vRouter.to("/setting_cache");
                  },
                ),
                Divider(), // 增加一条线
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                    child: Icon(Icons.assignment_late_outlined),
                  ),
                  title: Text('关于'),
                  onTap: () {
                    // Navigator.of(context).pop(); //隐藏侧边栏
                    Scaffold.of(context).openEndDrawer();
                    context.vRouter.to("/about");
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}
