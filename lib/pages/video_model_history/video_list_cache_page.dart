
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/data/videomodel.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/pages/home/video_list.dart';

class VideoListCachePage extends VideoList{

  VideoListCachePage({Key? key,Function? listClear,String? tId, String? wd}):super(key: key,listClear:listClear,tId:tId,wd:wd);

  @override
  Future<VideoListModel> videoListData(BuildContext context, String? tId, String? pageIndex, String? wd) async{
    String? cacheString = await VideoModelCache.tempHistoryCacheManager.getString(VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE);
    String querys = null != cacheString ? cacheString:"";
    List<VideoModel> videoModelList = querys.isNotEmpty ? querys.split("<v@v>").map((jsonStr){
      return VideoModel.fromJson(json.decode(jsonStr));
    }).toList() : <VideoModel>[];
    return VideoListModel(1,1,videoModelList);
  }
}
