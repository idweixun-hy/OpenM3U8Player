import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/pages/home/video_list.dart';
import 'package:open_m3u8_player/util/aes_util.dart';

class ShareVideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShareVideoState();
}

class _ShareVideoState extends State<ShareVideoPage> {
  static Future<String?> Function() _GET_CLIPBOARD_DATA = () async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  };

  static String shareCheck(String shareStr) {
    if (shareStr.isNotEmpty) {
      String decrypt = AESUtil.decrypt("${shareStr}==");
      if (decrypt.contains(AESUtil.SHARE_TAG)) {
        return decrypt;
      }
    }
    return "";
  }

  static Future<List<String>> shareStrPars() async {
    String? shareStr = await Function.apply(_GET_CLIPBOARD_DATA, []);
    late String shareCheckStr;
    if (null == shareStr || (shareCheckStr = shareCheck(shareStr)).isNotEmpty) {
      return shareCheckStr.split(AESUtil.SHARE_TAG);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("打开视频"),
        ),
        body: SafeArea(
          child: FutureBuilder<List<String>>(
              future: shareStrPars(),
              builder: (BuildContext buildContext,
                  AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text('等待检测分享数据'),
                        CircularProgressIndicator()
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  List<String> shareSplit = snapshot.data!;
                  if (shareSplit.length == 2) {
                    // 正常的数据
                    return VideoListSharePage(shareSplit[0], shareSplit[1]);
                  }
                }
                return Text("没有检测到分享数据");
              }),
        ),
    );
  }
}

class VideoListSharePage extends VideoList {
  final String apiBase;
  final String ids;

  VideoListSharePage(this.apiBase, this.ids,
      {Key? key, Function? listClear, String? tId, String? wd})
      : super(key: key, listClear: listClear, tId: tId, wd: wd);

  @override
  Future<VideoListModel> videoListData(
          BuildContext context, String? tId, String? pageIndex, String? wd) =>
      XmlData.getXml2VideoModelBase(
          apiBase, XmlData.getWebXmlDataByIds(apiBase, ids));
}
