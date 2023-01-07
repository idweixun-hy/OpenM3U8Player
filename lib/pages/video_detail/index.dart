import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_m3u8_player/data/videomodel.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/pages/player/sview_player.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/util/aes_util.dart';
import 'package:open_m3u8_player/util/fit_text_box.dart';
import 'package:open_m3u8_player/util/page_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

ShapeBorder shape = PageUtil.shape;

class VideoDetail extends StatelessWidget {
  final VideoModel videoData;
  final bool isLive;
  late FToast fToast;

  VideoDetail({Key? key, required this.videoData, required this.isLive})
      : super(key: key);

  void _video_model_cache() {
    String videoJsonString = json.encode(videoData.toJson());
    VideoModelCache.tempHistoryCacheManager
        .getString(VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE)
        .then((String? value) {
      String querysTemp = "";
      if (null != value) {
        Set<String> querySet = Set<String>();
        String querys = value;
        querys.split("<v@v>")
          ..add(videoJsonString.trim())
          ..forEach((qText) {
            if (qText.trim().isNotEmpty && !querySet.contains(qText)) {
              querysTemp = querysTemp.isEmpty
                  ? (qText)
                  : (querysTemp + "<v@v>" + qText.trim());
              querySet.add(qText);
            }
          });
      } else {
        querysTemp = videoJsonString;
      }
      VideoModelCache.tempHistoryCacheManager.setString(
          VideoModelCache.VIDEO_HISTORY_CACHE_KEY_TRY_CACHE, querysTemp);
    }).catchError((onError) {});
  }

  @override
  Widget build(BuildContext context) {
    String? msg;
    return FutureBuilder(
        future: XmlData.getXml2VideoModelBase(
            this.videoData.apiBase ?? "",
            XmlData.getWebXmlDataByIds(
                this.videoData.apiBase ?? "", this.videoData.id ?? "")),
        builder:
            (BuildContext context, AsyncSnapshot<VideoListModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            VideoModel videoData = (snapshot.data!.videoModelList.isEmpty)
                ? this.videoData
                : snapshot.data!.videoModelList.first;
            fToast = FToast();
            fToast.init(context);
            return Scaffold(
              appBar: AppBar(
                title: Text("视频详情"),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 320,
                        child: Stack(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.expand(),
                              child: CachedNetworkImage(
                                imageUrl: videoData.pic!,
                                imageBuilder: (context, imageProvider) => Image(
                                    image: imageProvider, fit: BoxFit.fitWidth),
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.black38))),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/fp.png"),
                              ),
                            ),
                            Center(
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 3.0, sigmaY: 3.0),
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 3.0, vertical: 6.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: videoData.pic!,
                                    imageBuilder: (context, imageProvider) =>
                                        Image(
                                            height: 320,
                                            image: imageProvider,
                                            fit: BoxFit.fitHeight),
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.black38))),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/fp.png"),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 1, //主轴上子控件的间距
                                  runSpacing: 1, //交叉轴上子控件之间的间距
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                            CircleBorder(
                                                side: BorderSide(
                                          //设置 界面效果
                                          color:
                                              Color.fromRGBO(58, 66, 86, 1.0),
                                          style: BorderStyle.none,
                                        ))),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Color.fromRGBO(58, 66, 86, 1.0),
                                        child: Icon(Icons.play_circle_outline,
                                            color: Colors.orange),
                                      ),
                                      onPressed: () {
                                        _video_model_cache();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return SviewPlayer(
                                              videoData: videoData,
                                              isLive: this.isLive,
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                    if (null != videoData.apiBase &&
                                        videoData.apiBase!.isNotEmpty)
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              CircleBorder(
                                                  side: BorderSide(
                                            //设置 界面效果
                                            color:
                                                Color.fromRGBO(58, 66, 86, 1.0),
                                            style: BorderStyle.none,
                                          ))),
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Color.fromRGBO(58, 66, 86, 1.0),
                                          child: Icon(Icons.share,
                                              color: Colors.orange),
                                        ),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: AESUtil.encrypt(
                                                      '${videoData.apiBase ?? ""}${AESUtil.SHARE_TAG}${videoData.id ?? ""}')
                                                  .replaceAll("=", "")));
                                          fToast.showToast(
                                            toastDuration:
                                                Duration(milliseconds: 1300),
                                            gravity: ToastGravity.CENTER,
                                            child: Text(
                                              "数据已经复制到剪贴板，现在去分享给你的朋友吧。",
                                              style: TextStyle(
                                                backgroundColor: Colors.blue,
                                                color: Colors.white,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          width: double.infinity,
                          height: 100.0 + 130.0 + 50.0,
                          decoration: BoxDecoration(
                            color: Colors.white, // 背景色
                            border: new Border.all(
                                color: Color.fromRGBO(91, 112, 137, 1.0),
                                width: 0.5), // border
                            borderRadius: BorderRadius.circular((8)), // 圆角
                          ),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "名称:" + (videoData.name ?? ""),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "国家:" + (videoData.area ?? ""),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "主演:" + (videoData.director ?? ""),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "演员:" + (videoData.actor ?? ""),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                "简介:",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                child: FitTextBox(
                                  showText: (videoData.des ?? "")
                                      .replaceAll("\t", "")
                                      .replaceAll("\n", "")
                                      .replaceAll(
                                          new RegExp(r'<\/?.+?\/?>'), ""),
                                  fixedHeightHeaderWidget: Container(
                                    width: 100.0,
                                    height: 8.0,
                                    color: Color(0x00000000),
                                  ),
                                  fixedHeightBottomWidget: Container(
                                    color: Color(0x00000000),
                                  ),
                                  textStyle: TextStyle(
                                      color: Colors.black45, fontSize: 14),
                                ),
                              ),
                            ],
                            //设置样式
                            //设置横轴定位
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //设置主轴定位，也就是纵轴
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasData) {
            msg = "没有数据";
          }
          return Scaffold(
            appBar: AppBar(
              title: Text("视频详情"),
            ),
            body: SafeArea(
              child: Text(
                "${msg == null ? '数据加载' : msg}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        });
  }
}
