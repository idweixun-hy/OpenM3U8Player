
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/data/videomodel.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/pages/home/video_item.dart';

class VideoListCache extends StatefulWidget{

  final Function(Function clear) listClear;
  VideoListCache({Key? key, required this.listClear}):super(key: key);

  Future<VideoListModel> videoListData() async{
    String? cacheString = await VideoModelCache.tempHistoryCacheManager.getString(VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE);
    String querys = null != cacheString ? cacheString:"";
    List<VideoModel> videoModelList = querys.isNotEmpty ? querys.split("<v@v>").map((jsonStr){
      return VideoModel.fromJson(json.decode(jsonStr));
    }).toList() : <VideoModel>[];
    return VideoListModel(1,1,videoModelList);
  }

  void videoListDataRemove(VideoModel videoModel) async{
    String videoJsonString = json.encode(videoModel.toJson()).trim();
    String querysTemp = "";
    Set<String> querySet = Set<String>();
    VideoListModel videoListModel = await videoListData();
    List<VideoModel> videoModelList = videoListModel.videoModelList;
    videoModelList
    .map((videoModel) => json.encode(videoModel.toJson()))
    .forEach((qText) {
      if (qText.trim().isNotEmpty && qText.trim().compareTo(videoJsonString) != 0 && !querySet.contains(qText) ) {
        querysTemp = querysTemp.isEmpty
            ? (qText)
            : (querysTemp + "<v@v>" + qText.trim());
        querySet.add(qText);
      }
    });
    VideoModelCache.tempHistoryCacheManager.setString(
        VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE, querysTemp);
  }

  @override
  State<StatefulWidget> createState() => _VideoListCacheState();
}

class _VideoListCacheState extends State<VideoListCache>{


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoListModel>(
      future: widget.videoListData(),
      builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            VideoListModel videoListModel = snapshot.data as VideoListModel;
            List<VideoModel> videoModelData = videoListModel.videoModelList;
            widget.listClear(() {
              videoModelData.clear();
            });
            if (videoModelData.isEmpty){
              return Text("暂无记录");
            }
            RenderBox? renderBox = context.findRenderObject() as RenderBox;
            Size size = renderBox.size;
            return ListView.builder(
              itemBuilder: (c, index) {
                return _item(size,index,videoModelData,(int index) {
                  widget.videoListDataRemove(videoModelData[index]);
                  (context as Element).markNeedsBuild();
                });
              },
              itemCount: videoModelData.length,
            );
        } else if (snapshot.connectionState == ConnectionState.waiting){
            return Text("加载数据中……");
        }
          return Text("暂无记录");
      },
    );
  }
  Widget _item(Size size, int index, List<VideoModel> list, void Function(int) removeFunc) {
    VideoModel videoModel = list[index];
    return SwipeActionCell(
      ///这个key是必要的
      key: ValueKey(videoModel),
      trailingActions: <SwipeAction>[
        SwipeAction(
            title: "删除",
            onTap: (CompletionHandler handler) async {
              removeFunc(index);
              list.removeAt(index);
            },
            color: Colors.red),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: VideoItem(
          imageSrc: videoModel.pic,
          videoTitle: videoModel.name!,
          videoId: videoModel.id,
          videoData: videoModel,
          size: size,
        ),
      ),
    );
  }

}
