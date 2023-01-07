
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/data/videomodel.dart';
import 'package:open_m3u8_player/pages/home/video_item.dart';

class VideoList extends StatefulWidget {
  final String? tId;
  final String? wd;
  final Function? listClear;

  VideoList({Key? key, this.listClear, this.tId, this.wd}) : super(key: key);

  Future<VideoListModel> videoListData(BuildContext context,
      String? tId, String? pageIndex, String? wd) async {
    return await context.watch<XmlData>().getXml2VideoModel(context.watch<XmlData>().getWebXmlData(
      tId,
      pageIndex,
      wd,
    ));
  }

  @override
  State<StatefulWidget> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  String? get tId => widget.tId;

  String? get wd => widget.wd;
  String? pageIndex;
  late int _pageCashIndex;
  String? pageCount;
  late List<VideoModel> videoModelList;

  late ScrollController _scrollController;

  @override
  void initState() {
    _pageCashIndex = 0;
    videoModelList = <VideoModel>[];
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (int.parse(pageCount!) > _pageCashIndex) {
          setState(() {
            pageIndex = (_pageCashIndex + 1).toString();
          });
        }
      }
    });
    if (null != widget.listClear) {
      widget.listClear!(() {
        setState(() {
          videoModelList.clear();
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoListModel>(
      future: widget.videoListData(context, this.tId, this.pageIndex, this.wd),
      builder: (context, snapshot) {
        if (videoModelList.isNotEmpty || snapshot.hasData) {
          if (snapshot.hasData) {
            VideoListModel videoListModel = snapshot.data as VideoListModel;
            pageIndex = videoListModel.page.toString();
            pageCount = videoListModel.pagecount.toString();

            if (_pageCashIndex != videoListModel.page) {
              _pageCashIndex = videoListModel.page;
              List<VideoModel> videoModelData = videoListModel.videoModelList;
              videoModelList.addAll(videoModelData);
            }
          }
          if (videoModelList.isNotEmpty) {
            return GridView.count(
                controller: _scrollController,
                primary: false,
                //竖向间距
                // mainAxisSpacing: 0.0,
                //横向Item的个数
                crossAxisCount: 1,
                //横向间距
                crossAxisSpacing: 3.0,
                //宽高比
                childAspectRatio: 2.1,
                children: _buildGridTileList(videoModelList));
          }
          return Text("暂无记录");
        }
        return Text("加载数据中……");
      },
    );
  }

  List<Widget> _buildGridTileList(List<VideoModel> videoList) {
    RenderBox? renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    return videoList
        .map((VideoModel videoModel) => VideoItem(
              imageSrc: videoModel.pic,
              videoTitle: videoModel.name!,
              videoId: videoModel.id,
              videoData: videoModel,
              size: size,
            ))
        .toList() ;
  }
}
