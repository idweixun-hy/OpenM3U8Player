import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_m3u8_player/util/page_util.dart';
import 'package:open_m3u8_player/data/videomodel.dart';

import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/pages/player/FijkplayerUI/local_fijk_panel.dart';
import 'package:open_m3u8_player/server/local_m3u8_server_api.dart';
import 'dart:async';

class SimpleViewPlayer extends StatefulWidget {
  late final FijkPlayer fijkPlayer;
  final String title;
  final String m3u8Url;
  final bool isLive;
  final VoidCallback? call;

  SimpleViewPlayer(
      {this.title: "",
      required this.m3u8Url,
      required this.isLive,
      this.call}) {
    this.fijkPlayer = FijkPlayer()..setDataSource(this.m3u8Url, autoPlay: true);
  }

  @override
  State<StatefulWidget> createState() => _SimpleViewPlayerState();
}

class _SimpleViewPlayerState extends State<SimpleViewPlayer>
    with WidgetsBindingObserver {
  late FijkView _fijkView = FijkView(
    player: widget.fijkPlayer,
    color: Colors.black,
    panelBuilder: localFijkPanel2Builder(
        m3u8Url: widget.m3u8Url,
        title: widget.title,
        isLive: widget.isLive,
        callDrawer: widget.call),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        {
          widget.fijkPlayer.pause();
        }
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    widget.fijkPlayer.release();
  }

  @override
  Widget build(BuildContext context) {
    return _fijkView;
  }
}

class DLTabBar extends StatefulWidget {
  final List<Map<String, dynamic>> dlMap;

  const DLTabBar({Key? key, required this.dlMap}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DLTabBarState();
}

class _DLTabBarState extends State<DLTabBar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        initialIndex: 0, length: widget.dlMap.length, vsync: this); // 直接传this
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: widget.dlMap.map((ddMap) {
              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 60,
                    maxHeight: 50,
                  ),
                  child: Text(ddMap["srcKey"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      )),
                ),
              );
            }).toList(),
          ),
        ),
        Container(
          height: 320,
          child: TabBarView(
              controller: _tabController,
              children: widget.dlMap.isEmpty
                  ? []
                  : widget.dlMap.map((ddMap) {
                      return SingleChildScrollView(
                        child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 2, //主轴上子控件的间距
                            runSpacing: -12, //交叉轴上子控件之间的间距
                            children: ddMap["dd"]),
                      );
                    }).toList()),
        ),
      ],
    );
  }
}

class SviewPlayer extends StatefulWidget {
  final VideoModel videoData;
  final bool isLive;

  SviewPlayer({Key? key, required this.videoData, required this.isLive})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SviewPlayerState();
}

class _SviewPlayerState extends State<SviewPlayer> {
  SimpleViewPlayer? _simpleViewPlayer;
  late FToast fToast;
  String playWait = "请选集";

  String itemSelect = "";

  @override
  void initState() {
    super.initState();

    playWait = "请选集";
    _simpleViewPlayer = null;

    _temp_item_select_get().then((String? value) {
      if (null != value) {
        setState(() {
          itemSelect = value;
        });
      }
    }).catchError((onError) {});
  }

  void _temp_item_select_set(String itemSelect) {
    VideoModelCache.tempHistoryCacheManager.setString(
        VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE +
            "@" +
            widget.videoData.name!,
        itemSelect);
  }

  Future<String?> _temp_item_select_get() {
    return VideoModelCache.tempHistoryCacheManager.getString(
        VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE +
            "@" +
            widget.videoData.name!);
  }

  void controllerInit(String? source) async {
    if (source == null) {
      playWait = "请选集";
      _simpleViewPlayer?.fijkPlayer.release();
      _simpleViewPlayer = null;
      setState(() {});
      return;
    }

    print("source:${source}");
    print("source encode :${Uri.encodeFull(source)}");
    _simpleViewPlayer?.fijkPlayer.release();
    String m3u8Url = Uri.encodeFull(source);
    _simpleViewPlayer = SimpleViewPlayer(
      title: "${widget.videoData.name!}-${itemSelect}",
      m3u8Url: m3u8Url,
      isLive: widget.isLive,
    );

    setState(() {
      playWait = "请选集";
    });
  }

  DLTabBar _dlTabBarBuild() {
    List<Map<String, dynamic>> dlMap =
        widget.videoData.dl!.map(this.videoSrcInit).toList();
    return DLTabBar(
      dlMap: dlMap,
    );
  }

  List<Widget> videoPageInit() {
    List<Widget> videoPageColumnEnd = <Widget>[
      Container(
        height: 300.0,
        child: null == _simpleViewPlayer
            ? Center(
                child: Text(playWait),
              )
            : _simpleViewPlayer,
      ),
      SizedBox(
        height: 32,
      ),
      _dlTabBarBuild()
    ];
    return videoPageColumnEnd;
  }

  Map<String, dynamic> videoSrcInit(String dd) {
    dd = dd.trim();
    List<ButtonTheme> ddMaterialButton = <ButtonTheme>[];

    int lastIndexOf = dd.lastIndexOf("\$");
    String srcKey = dd.substring(lastIndexOf + 1, dd.length);
    List<String> ddItemList = dd.split("#");
    ddMaterialButton.add(ButtonTheme(
      minWidth: 30.0,
      child: MaterialButton(
        shape: PageUtil.shape,
        height: 23,
        color: Colors.amberAccent,
        textColor: Colors.white,
        child: new Text(
          "复制网址",
          style: TextStyle(fontSize: 12),
        ),
        onPressed: () async {
          Clipboard.setData(ClipboardData(
              text: await LocalM3u8Server.mkWebPlayerPath(
                  await DefaultAssetBundle.of(context)
                      .loadString('AssetManifest.json'),
                  widget.videoData.name!,
                  dd)));
          fToast.showToast(
            toastDuration: Duration(milliseconds: 1300),
            gravity: ToastGravity.CENTER,
            child: Text(
              "网址已经复制到剪贴板，现在去你的其他设备观看吧。",
              style: TextStyle(
                backgroundColor: Colors.blue,
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          );
        },
      ),
    ));
    ddMaterialButton.addAll(ddItemList
        .where((ddItem) => ddItem.isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map((ddItemEntry) {
      int index = ddItemEntry.key;
      String ddItem = ddItemEntry.value;
      if (ddItem.endsWith(".m3u8")) {
        List<String> ddSplit = ddItem.split("\$");
        ddItem =
            "${ddSplit.length > 1 ? ddSplit[0] : "第${index + 1}集"}\$${ddSplit[ddSplit.length - 1]}\$ckplayer";
        srcKey = "ckplayer";
      }
      if (ddItem.endsWith(".html")) {
        List<String> ddSplit = ddItem.split("\$");
        ddItem =
            "${ddSplit.length > 1 ? ddSplit[0] : "第${index + 1}集"}\$${ddSplit[ddSplit.length - 1]}\$html";
        srcKey = "html";
      }
      String _itemSelect = ddItem;
      if (ddItem.contains("\$")) {
        _itemSelect = ddItem.substring(0, ddItem.indexOf("\$"));
      }
      return ButtonTheme(
        minWidth: 30.0,
        child: MaterialButton(
          shape: PageUtil.shape,
          height: 23,
          color: itemSelect == _itemSelect
              ? Colors.red
              : Color.fromRGBO(58, 66, 86, 1.0),
          textColor: Colors.white,
          child: new Text(
            _itemSelect,
            style: TextStyle(fontSize: 12),
          ),
          onPressed: () async {
            _temp_item_select_set(_itemSelect);
            controllerInit(null);
            setState(() {
              playWait = "正在解析地址…";
              itemSelect = _itemSelect;
            });
            Timer(Duration(milliseconds: 300), () async {
              String? m3u8Url = await XmlData.getM3U8Url(ddItem, context);
              controllerInit(m3u8Url);
            });
          },
        ),
      );
    }).toList());

    return {"srcKey": srcKey, "dd": ddMaterialButton};
  }

  @override
  Widget build(BuildContext context) {
    fToast = FToast();
    fToast.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoData.name!),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Column(
            children: this.videoPageInit(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _simpleViewPlayer?.fijkPlayer.release();
    super.dispose();
  }

  // md5 加密
  String _generate_MD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }
}
