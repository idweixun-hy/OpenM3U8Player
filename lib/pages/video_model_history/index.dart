import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/pages/video_model_history/video_list_cache.dart';

class VideoModelCachePage extends StatefulWidget {
  final String title;

  VideoModelCachePage({Key? key, this.title = "历史记录"}) : super(key: key);

  State<StatefulWidget> createState() => _VideoModelCachePageState();
}

class _VideoModelCachePageState extends State<VideoModelCachePage> {
  late Function listClear;

  VideoListCache buildVideoListCachePage() {
    return VideoListCache(listClear: (clear) {
      listClear = clear;
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            tooltip: '清除',
            onPressed: () async {
              bool? isClear = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('删除播放记录'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('确定要清空播放记录吗？'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: Text('确定'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      MaterialButton(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  );
                },
              );
              if (isClear!) {
                await VideoModelCache.m3u8CurrentPosCacheManager.clearAll();
                await VideoModelCache.tempHistoryCacheManager.clearAll();
                listClear();
                setState(() {});
              }
            },
          )
        ],
      ),
      body: SafeArea(child: buildVideoListCachePage()),
    );
  }
}
