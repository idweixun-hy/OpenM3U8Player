import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_m3u8_player/data/live_host_list_entity.dart';
import 'package:open_m3u8_player/data/live_type_list_entity.dart';
import 'package:open_m3u8_player/data/videomodel.dart';
import 'package:open_m3u8_player/util/netUtil.dart';
import 'package:m3u_nullsafe/m3u_nullsafe.dart';
import 'package:xml2json/xml2json.dart';
import 'package:xml/xml.dart' as xml;

class XmlData with ChangeNotifier {
  static final String FILE_BASE_START = "file://";
  static final String LIVE_BASE_START = "live://";
  static final String LIVE_ALL_JSON = "json.txt";

  String _title = "";

  set title(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  String get title => _title;
  String _apiBase = "";

  set apiBase(String value) {
    if (_apiBase != value) {
      _apiBase = value;
      notifyListeners();
    }
  }

  String get apiBase => _apiBase;

  static bool isFileApiBase(String apiBase) =>
      apiBase.startsWith(FILE_BASE_START);

  static bool isLiveApiBase(String apiBase) =>
      apiBase.startsWith(LIVE_BASE_START);

  bool isFileApi() => isFileApiBase(apiBase);

  bool isLiveApi() => isLiveApiBase(apiBase);

  static Future<bool> sourceCheck(String apiBase) async {
    if (apiBase.isEmpty) {
      return false;
    }
    try {
      if (isLiveApiBase(apiBase)) {
        await NetUtil.loadAsyncDio(
            "${apiBase.replaceFirst(LIVE_BASE_START, '')}/$LIVE_ALL_JSON");
      } else if (isFileApiBase(apiBase)) {
        // 只要文件存在 就没有需要处理的
        return (File("${apiBase.replaceFirst(FILE_BASE_START, '')}"))
            .existsSync();
      } else {
        await NetUtil.loadAsyncDio("${apiBase}");
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getWebXmlDataByIds(String apiBase, String ids) =>
      NetUtil.loadAsyncDio("${apiBase}?ac=videolist&t=&ids=${ids}");

  static Future<String> getWebXmlDataByWd(String apiBase, String wd) =>
      NetUtil.loadAsyncDio("${apiBase}?ac=list&t=&pg=&wd=${wd}");

  static Future<String> getWebXmlDataBase(
          String apiBase, String? tId, String? pageIndex, String? wd) =>
      NetUtil.loadAsyncDio(
          "${apiBase}?ac=videolist&t=${tId ?? ""}&pg=${pageIndex ?? "1"}&wd=${wd ?? ""}");

  Future<String> getWebXmlData(String? tId, String? pageIndex, String? wd) {
    if (isFileApi()) {
      // 返回 文件内容
      return Future(() async {
        return tId ?? "";
      });
    }
    if (isLiveApi()) {
      return NetUtil.loadAsyncDio(
          "${apiBase.replaceFirst(LIVE_BASE_START, '')}/${tId ?? ""}");
    }
    if (wd != null && wd.trim().isNotEmpty) {
      return () async {
        String ids = await getXmlIds(getWebXmlDataByWd(apiBase, wd));
        return await getWebXmlDataByIds(apiBase, ids);
      }();
    }
    return getWebXmlDataBase(apiBase, tId ?? "", pageIndex ?? "1", wd ?? "");
  }

  Future<String> getWebXmlDataTypeList() {
    if (isFileApi()) {
      return (File("${apiBase.replaceFirst(FILE_BASE_START, '')}"))
          .readAsString();
    }
    if (isLiveApi()) {
      return NetUtil.loadAsyncDio(
          "${apiBase.replaceFirst(LIVE_BASE_START, '')}/$LIVE_ALL_JSON");
    }
    return NetUtil.loadAsyncDio("${apiBase}");
  }

  Future<String> getWebXmlDataTypeListWithParam() {
    return NetUtil.loadAsyncDio("${apiBase}?ac=list");
  }

  Future<List<Map<String, String>>> getXml2VideoTypeList(
      Future<String> xmlFututer) async {
    if (isFileApi()) {
      final listOfTracks = await parseFile(await xmlFututer);
      final categories =
          sortedCategories(entries: listOfTracks, attributeName: 'group-title');
      return categories.keys
          .map((gtitle) => {"tyId": gtitle, "tyText": gtitle})
          .toList();
    }
    if (isLiveApi()) {
      Map<String, dynamic> liveTypeMap = json.decode(await xmlFututer);
      LiveTypeListEntity liveTypeListEntity = LiveTypeListEntity()
        ..fromJson(liveTypeMap);
      return liveTypeListEntity.pingtai
          .map((LiveTypeListPingtai pingtai) =>
              {"tyId": pingtai.address, "tyText": pingtai.title})
          .toList();
    }

    String xmlData = await xmlFututer;
    xmlData = xmlData.replaceAll("\r\n", "");
    xmlData = xmlData.replaceAll("\"></script><a a=\"", "");
    xmlData = xmlData.replaceAll(
        "</script><a a=370\" src=//js.tiantiantuiqiu.com/1.js></script><a a=451\" src=//js.tiantiantuiqiu.com/1.js></script><a a=550\"<script src=//js.",
        "");
    List<Map<String, String>> tyList = <Map<String, String>>[];
    tyList.add({"tyId": "", "tyText": "最新"});
    xml.XmlDocument xmlDocument;
    try {
      xmlDocument = xml.XmlDocument.parse(xmlData);
    } catch (e) {
      // 硬编码 异常重试
      try {
        xmlDocument =
            xml.XmlDocument.parse(await getWebXmlDataTypeListWithParam());
      } catch (e) {
        return tyList;
      }
    }

    xmlDocument
        .findAllElements("class")
        .first
        .findAllElements("ty")
        .forEach((xml.XmlElement xe) {
      String tyText = xe.text.trim();
      xml.XmlAttribute xa = xe.attributes.first;
      tyList.add({"tyId": xa.value, "tyText": tyText});
    });
    return tyList;
  }

  Future<String> getLocalXmlData(BuildContext context) {
    return DefaultAssetBundle.of(context).loadString("assets/data.xml");
  }

  Future<String?> getXml2Json(Future<String> xmlFututer) async {
    String xmlData = await xmlFututer;
    xmlData = xmlData.replaceAll("\r\n", "");
    xmlData = xmlData.replaceAll("\"></script><a a=\"", "");
    xmlData = xmlData.replaceAll(
        "</script><a a=370\" src=//js.tiantiantuiqiu.com/1.js></script><a a=451\" src=//js.tiantiantuiqiu.com/1.js></script><a a=550\"<script src=//js.",
        "");
    if (xmlData != null) {
      Xml2Json x2j = new Xml2Json();
      x2j.parse(xmlData);
      String jsonData = x2j.toParker();
      return jsonData;
    }
  }

  static Future<String> getXmlIds(Future<String> xmlFututer) async {
    String xmlData = await xmlFututer;
    xmlData = xmlData.replaceAll("\r\n", "");
    xmlData = xmlData.replaceAll("\"></script><a a=\"", "");
    xmlData = xmlData.replaceAll(
        "</script><a a=370\" src=//js.tiantiantuiqiu.com/1.js></script><a a=451\" src=//js.tiantiantuiqiu.com/1.js></script><a a=550\"<script src=//js.",
        "");
    xml.XmlDocument xmlDocument = xml.XmlDocument.parse(xmlData);
    Iterable<xml.XmlElement> itXmlElement =
        xmlDocument.findAllElements("video");

    return itXmlElement.map((xe) => VideoModel.fildValue(xe, "id")).join(",");
  }

  static Future<VideoListModel> getXml2VideoModelBase(
      String apiBase, Future<String> xmlFututer) async {
    late int page;
    late int pagecount;
    List<VideoModel> videoModelList;
    if (apiBase.isEmpty) {
      return VideoListModel(1, 1, []);
    }
    if (isFileApiBase(apiBase)) {
      // 本地文件内容
      page = 1;
      pagecount = 1;
      String? tId = await xmlFututer;
      final fileCentextFututer =
          (File("${apiBase.replaceFirst(FILE_BASE_START, '')}")).readAsString();
      final listOfTracks = await parseFile(await fileCentextFututer);
      final categories =
          sortedCategories(entries: listOfTracks, attributeName: 'group-title');
      List<M3uGenericEntry> groupEntrys = [];
      if (tId != null) {
        groupEntrys = categories[tId] ?? [];
      }
      videoModelList = groupEntrys
          .map((M3uGenericEntry m3uGenericEntry) => VideoModel(
                // apiBase: apiBase,
                name: m3uGenericEntry.title,
                pic: Uri.decodeFull(
                    (m3uGenericEntry.attributes["tvg-logo"]) ?? ""),
                dl: <String>["播放\$${m3uGenericEntry.link}\$ckplayer"],
                type: 'live',
              ))
          .toList();
    } else if (isLiveApiBase(apiBase)) {
      page = 1;
      pagecount = 1;
      Map<String, dynamic> liveHostMap = json.decode(await xmlFututer);
      LiveHostListEntity liveHostListEntity = LiveHostListEntity()
        ..fromJson(liveHostMap);
      videoModelList = liveHostListEntity.zhubo
          .map((LiveHostListZhubo zhubo) => VideoModel(
                name: zhubo.title,
                pic: Uri.decodeFull(zhubo.img),
                dl: <String>["播放\$${zhubo.address}\$ckplayer"],
                type: 'live',
              ))
          .toList();
    } else {
      String xmlData = await xmlFututer;
      xmlData = xmlData.replaceAll("\r\n", "");
      xmlData = xmlData.replaceAll("<script src=http://MacCms.InFo:88/Mac10/Mac.js></script><img style=\"display:none\" src=\"", "");
      xmlData = xmlData.replaceAll(
          "</script><a a=370\" src=//js.tiantiantuiqiu.com/1.js></script><a a=451\" src=//js.tiantiantuiqiu.com/1.js></script><a a=550\"<script src=//js.",
          "");
      xmlData = xmlData.replaceAll("\"></script><a a=\"", "");
      xml.XmlDocument xmlDocument = xml.XmlDocument.parse(xmlData);

      Iterable<xml.XmlElement> itListTag = xmlDocument.findAllElements("list");
      if (itListTag.isNotEmpty) {
        itListTag.first.attributes.forEach((xml.XmlAttribute attr) {
          String name = attr.name.toString();
          switch (name) {
            case "page":
              {
                page = int.tryParse(attr.value)!;
              }
              break;
            case "pagecount":
              {
                pagecount = int.tryParse(attr.value)!;
              }
              break;
          }
        });
      }
      Iterable<xml.XmlElement> itXmlElement =
          xmlDocument.findAllElements("video");
      videoModelList = itXmlElement
          .map((xml.XmlElement xe) => VideoModel(
                apiBase: apiBase,
                id: VideoModel.fildValue(xe, "id"),
                last: VideoModel.fildValue(xe, "last"),
                tid: VideoModel.fildValue(xe, "tid"),
                type: VideoModel.fildValue(xe, "type"),
                name: VideoModel.fildValue(xe, "name"),
                pic: VideoModel.fildValue(xe, "pic").replaceAll("\">", ""),
                lang: VideoModel.fildValue(xe, "lang"),
                area: VideoModel.fildValue(xe, "area"),
                year: VideoModel.fildValue(xe, "year"),
                state: VideoModel.fildValue(xe, "state"),
                keywords: VideoModel.fildValue(xe, "keywords"),
                len: VideoModel.fildValue(xe, "len"),
                total: VideoModel.fildValue(xe, "total"),
                jq: VideoModel.fildValue(xe, "jq"),
                nickname: VideoModel.fildValue(xe, "nickname"),
                reweek: VideoModel.fildValue(xe, "reweek"),
                douban: VideoModel.fildValue(xe, "douban"),
                mtime: VideoModel.fildValue(xe, "mtime"),
                imdb: VideoModel.fildValue(xe, "imdb"),
                tvs: VideoModel.fildValue(xe, "tvs"),
                company: VideoModel.fildValue(xe, "company"),
                ver: VideoModel.fildValue(xe, "ver"),
                longtxt: VideoModel.fildValue(xe, "longtxt"),
                note: VideoModel.fildValue(xe, "note"),
                actor: VideoModel.fildValue(xe, "actor"),
                director: VideoModel.fildValue(xe, "director"),
                dl: VideoModel.dlInit(xe.findElements("dl").isNotEmpty
                    ? xe.findElements("dl").first
                    : null),
                des: VideoModel.fildValue(xe, "des"),
                reurl: VideoModel.fildValue(xe, "reurl"),
              ))
          .toList();
    }
    return VideoListModel(page, pagecount, videoModelList);
  }

  Future<VideoListModel> getXml2VideoModel(Future<String> xmlFututer) =>
      getXml2VideoModelBase(apiBase, xmlFututer);

  static Future<String> getM3U8Url(String ddPath, BuildContext context) async {
    if (ddPath.indexOf('\$ct') >= 0) {
      ddPath = "未命名\$${ddPath}";
    }
    print(ddPath);
    List<String> ddList = ddPath.split("\$");
    RegExp mobile = new RegExp(r"http[s]{0,1}:\/\/([\w.]+\/?)\S*?\.m3u8");
    String m3u8PathMatch =
        ddList.firstWhere((item) => mobile.hasMatch(item), orElse: () => "");
    String m3u8Path = m3u8PathMatch.isNotEmpty
        ? m3u8PathMatch
        : (ddList.length >= 2 ? ddList[1].trim() : "");
    String srcType = m3u8PathMatch.isNotEmpty
        ? "ckplayer"
        : (ddList.length >= 3 ? ddList[2].trim() : "");

    return await _getM3U8Path(m3u8Path, srcType, context);
  }

  static Future<String> _getM3U8Path(
      String m3u8Path, String srcType, BuildContext context) async {
    switch (srcType) {
      case "hjm3u8":
      case "ctm3u8":
      case "sym3u8":
      case "lym3u8":
      case "zkm3u8":
      case "tkm3u8":
      case "dadim3u8":
      case "88zym3u8":
      case "dbm3u8":
      case "mahua":
      case "123kum3u8":
      case "ckm3u8":
      case "lajiao":
      case "xhgzy":
      case "ckplayer":
      case "zkm3u8":
      case "wlm3u8":
      case "bjm3u8":
      case "ckm3u8":
      case "kkm3u8":
      case "yjm3u8":
      case "zuidam3u8":
      case "lbm3u8":
      case "605m3u8":
        {
          return m3u8Path;
        }
      case "ctyun":
      case "dbyun":
      case "dadi":
      case "zkyun":
      case "wlzy":
      case "bjyun":
      case "kuyun":
      case "kkyun":
      case "zuidall":
      case "yjyun":
        {
          return await getM3U8Page(m3u8Path);
        }
      case "qq":
      case "youku":
      case "tudou":
      case "bilibili":
      case "mgtv":
      case "qiyi":
      case "html":
        {
          return await getM3U8PageBBG(m3u8Path, context) ??
              "http://localhost/index.m3u8";
        }
      case "fanqie":
        {
          return await getM3U8PageFanqie(m3u8Path, context) ??
              "http://localhost/index.m3u8";
        }
      default:
        {
          return "http://localhost/index.m3u8";
        }
    }
  }

  static Future<String> getM3U8Page(String url) async {
    String htmlSrc = await NetUtil.loadAsyncDio(url);
    List<String> urlsp = url.split("://");
    List<String> urlPath = urlsp[1].split("/");
    String htmlMain = htmlSrc
        .replaceAll(" ", "")
        .replaceAll("\r", "")
        .replaceAll("\t", "")
        .split("\n")
        .firstWhere((String htmlLine) {
          return htmlLine.startsWith("varmain=");
        })
        .trim()
        .replaceFirst("varmain=", "")
        .replaceAll(";", "");
    return "${urlsp[0]}://${urlPath[0]}${htmlMain.substring(1, htmlMain.length - 1)}";
  }

  static Future<String?> getM3U8PageBBG(
      String url, BuildContext context) async {
    // 无广告 但是需要cookie
    // final String baseUrl = "https://www.newsaas.cn/jx/?url=";
    /*final String baseUrl = "https://chaxun.truechat365.com/?url=";
    return getM3U8PageBase(baseUrl,url, context);*/
    // TODO 视频网站 解析接口的选取
    return "";
  }

  static Future<String?> getM3U8PageFanqie(
      String url, BuildContext context) async {
    final String baseUrl = "https://jiexi.fqplayer.com/player/jx.php?url=";
    return getM3U8PageBase(baseUrl,url, context);
  }
  static Future<String?> getM3U8PageBase(
  String baseUrl, String url, BuildContext context) async {
    Uri uri = Uri.parse("$baseUrl${Uri.encodeFull(url)}");
    final completer = Completer<String?>();
    HeadlessInAppWebView? headlessWebView;
    headlessWebView = new HeadlessInAppWebView(
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              useOnLoadResource: true,
              javaScriptEnabled: true,
              userAgent:
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36 Edg/100.0.1185.39')
      ),
      initialUrlRequest: URLRequest(
          url: uri, headers: {
            'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="100", "Microsoft Edge";v="100"',
            'sec-ch-ua-platform': "Windows",
            'sec-ch-ua-mobile': "?0"
      }),
      onWebViewCreated: (controller) async {},
      onLoadResource: (controller, resource) async {
        print( "resource =========> ${resource.url.toString()}: \n -> ${(resource.url?.data?.contentText) ?? ""}");
      },
      onConsoleMessage: (controller, consoleMessage) {},
      onLoadStart: (controller, url) async {},
      onLoadStop: (controller, url) async {
        var result = await controller.evaluateJavascript(source: "config['url']");
        if (!completer.isCompleted &&
            (result.toString().isNotEmpty )) {
          // 当前没有返回结果 且请求为 M3U8
          completer.complete(result.toString());
          headlessWebView?.dispose();
        }
      },
    );
    headlessWebView.dispose();
    headlessWebView.run();
    Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      headlessWebView?.dispose();
    });
    return completer.future;
  }
}

class VideoListModel {
  int page;

  int pagecount;

  List<VideoModel> videoModelList;

  VideoListModel(this.page, this.pagecount, this.videoModelList);
}
