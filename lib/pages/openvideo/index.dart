import 'dart:async';
import 'dart:io';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/videomodel.dart';
import '../player/FijkplayerUI/local_fijk_panel.dart';

class SimpleViewPlayer extends StatefulWidget {
  late final FijkPlayer fijkPlayer;
  final String title;
  final String m3u8Url;
  final bool isLive;
  final VoidCallback? call;

  SimpleViewPlayer(
      {this.title: "", required this.m3u8Url, required this.isLive, this.call}) {
    this.fijkPlayer = FijkPlayer()..setDataSource(this.m3u8Url, autoPlay: true);
  }

  @override
  State<StatefulWidget> createState() => _SimpleViewPlayerState();
}

class _SimpleViewPlayerState extends State<SimpleViewPlayer> with WidgetsBindingObserver{
  late FijkView _fijkView = FijkView(
    player: widget.fijkPlayer,
    color: Colors.black,
    panelBuilder: localFijkPanel2Builder(m3u8Url: widget.m3u8Url, title: widget.title,isLive: widget.isLive, callDrawer: widget.call),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // FijkLog.setLevel(FijkLogLevel.Error);
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
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
    widget.fijkPlayer.release();
  }

  @override
  Widget build(BuildContext context) {
    return _fijkView;
  }
}




class OpenVideoPlayer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _OpenVideoPlayerState();
}

class _OpenVideoPlayerState extends State<OpenVideoPlayer> {
  late FToast fToast;
  String inputText = "";
  String playWait = "请选择播放资源";
  SimpleViewPlayer? _simpleViewPlayer;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _simpleViewPlayer = null;
  }

  void controllerInit(String? source) async {
    if (source == null) {
      playWait = "请选择播放资源";
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
      title: "${inputText}",
      m3u8Url: m3u8Url,
      isLive: false,
    );

    setState(() {
      playWait = "请选集";
    });
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
      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          icon: Icon(Icons.text_fields),
          labelText: '请输入地址',
          helperText: '请输入要加载的网络视频地址',
        ),
        onSubmitted: (_inputText) => inputText = _inputText,
        autofocus: false,
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_link),
            Expanded(
              child: TextButton(
                child: Text(
                  "播放网络视频",
                  style: TextStyle(fontSize: 14),
                ),
                onPressed: () async {
                  // 加载网络数据
                  if (inputText.isNotEmpty) {
                    controllerInit(null);
                    setState(() {
                      playWait = "正在解析地址…";
                    });
                    Timer(Duration(milliseconds: 300), () async {
                      String? m3u8Url = this.inputText;
                      controllerInit(m3u8Url);
                    });
                    return;
                  }
                  fToast.showToast(
                    gravity: ToastGravity.CENTER,
                    child: Text(
                      "尚未输入网址",
                      style: TextStyle(
                        backgroundColor: Colors.red,
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                },
              ),
            )
          ]),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.file_copy_outlined),
            Expanded(
              child: TextButton(
                child: Text(
                  "打开本地视频",
                  style: TextStyle(fontSize: 14),
                ),
                onPressed: () async {
                  // 加载本地数据
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['mp4','mov','mkv','avi','wmv','m4v','mpg','webm','ogv','3g2.flv','f4v','swf'],
                  );
                  if (result != null) {
                    inputText = result.paths.first!;
                    controllerInit(null);
                    setState(() {
                      playWait = "正在解析地址…";
                    });
                    Timer(Duration(milliseconds: 300), () async {
                      String? m3u8Url = this.inputText;
                      controllerInit(m3u8Url);
                    });
                    return;
                  }
                  fToast.showToast(
                    toastDuration: Duration(milliseconds: 1300),
                    gravity: ToastGravity.CENTER,
                    child: Text(
                      "没有选择文件",
                      style: TextStyle(
                        backgroundColor: Colors.red,
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                },
              ),
            )
          ]),
    ];
    return videoPageColumnEnd;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("打开视频"),
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
}
