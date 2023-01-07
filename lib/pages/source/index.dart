import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_m3u8_player/data/XmlDataGet.dart';
import 'package:open_m3u8_player/util/page_util.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/site_source_model.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/util/netUtil.dart';
import 'package:open_m3u8_player/pages/source/radioListRow.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SourceSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SourceSettingState();
}

class _SourceSettingState extends State<SourceSettingPage> {
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("数据源管理"),
        ),
        body: SafeArea(
          child: Builder(builder: (BuildContext context) {
            return FutureBuilder<List<SiteSourceModel>>(
              future: _temp_source_builder(),
              builder: (BuildContext buildContext,
                  AsyncSnapshot<List<SiteSourceModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  String inputText = "";
                  Widget widget = _temp_source_site_widget(
                      buildContext, snapshot.data as List<SiteSourceModel>);
                  List<Widget> widgetList = <Widget>[widget];
                  widgetList
                    ..addAll(<Widget>[
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          icon: Icon(Icons.text_fields),
                          labelText: '请输入地址',
                          helperText: '请输入要加载的配置文件地址',
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
                                  "从网络导入",
                                  style: TextStyle(fontSize: 14),
                                ),
                                onPressed: () async {
                                  // 加载网络数据
                                  if (inputText.isNotEmpty) {
                                    String loadJsonString =
                                        await NetUtil.loadAsync(inputText);
                                    List<dynamic> sourceSiteListDecode =
                                        json.decode(loadJsonString);
                                    List<SiteSourceModel> siteSourceModels =
                                        getSiteSourceModelList(
                                            sourceSiteListDecode);
                                    await _temp_source_site_merge(
                                        siteSourceModels);
                                    (context as Element).markNeedsBuild();
                                    fToast.showToast(
                                      gravity: ToastGravity.CENTER,
                                      child: Text(
                                        "加载成功~",
                                        style: TextStyle(
                                          backgroundColor: Colors.red,
                                          color: Colors.white,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    );
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
                                  "从本地导入",
                                  style: TextStyle(fontSize: 14),
                                ),
                                onPressed: () async {
                                  // 加载本地数据
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['json'],
                                  );
                                  if (result != null) {
                                    File file = File(result.paths.first!);
                                    String loadJsonString =
                                        await file.readAsStringSync();
                                    List<dynamic> sourceSiteListDecode =
                                        json.decode(loadJsonString);
                                    List<SiteSourceModel> siteSourceModels =
                                        getSiteSourceModelList(
                                            sourceSiteListDecode);
                                    await _temp_source_site_merge(
                                        siteSourceModels);
                                    (context as Element).markNeedsBuild();
                                    fToast.showToast(
                                      toastDuration:
                                          Duration(milliseconds: 1300),
                                      gravity: ToastGravity.CENTER,
                                      child: Text(
                                        "加载成功~",
                                        style: TextStyle(
                                          backgroundColor: Colors.blue,
                                          color: Colors.white,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    );
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.live_tv),
                            Expanded(
                              child: TextButton(
                                child: Text(
                                  "本地直播源（m3u）",
                                  style: TextStyle(fontSize: 14),
                                ),
                                onPressed: () async {
                                  // 加载本地数据
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['m3u'],
                                  );
                                  if (result != null) {
                                    List<SiteSourceModel> siteSourceModels = result
                                        .paths
                                        .map((path) => SiteSourceModel(
                                            path?.split("/").last,
                                            path,
                                            "live",
                                            "${XmlData.FILE_BASE_START}${path}",
                                            "",
                                            true))
                                        .toList();
                                    await _temp_source_site_merge(
                                        siteSourceModels);
                                    (context as Element).markNeedsBuild();
                                    fToast.showToast(
                                      toastDuration:
                                          Duration(milliseconds: 1300),
                                      gravity: ToastGravity.CENTER,
                                      child: Text(
                                        "加载成功~",
                                        style: TextStyle(
                                          backgroundColor: Colors.blue,
                                          color: Colors.white,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    );
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
                    ]);

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widgetList,
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text('等待加载源数据'),
                      CircularProgressIndicator()
                    ],
                  ),
                );
              },
            );
          }),
        ),
    );
  }

  Future<List<SiteSourceModel>> _temp_source_builder() async {
    String sourceSiteList = await VideoModelCache.tempSourceSiteCacheManager
            .getString(VideoModelCache.SOURCE_SITE_LIST_CACHE_KEY_TRY_CACHE) ??
        "[]";

    List<dynamic> sourceSiteListDecode = json.decode(sourceSiteList);
    List<SiteSourceModel> siteSourceModelList =
        getSiteSourceModelList(sourceSiteListDecode);

    return siteSourceModelList;
  }

  Widget _temp_source_site_widget(
      BuildContext context, List<SiteSourceModel> siteSourceModelList) {
    List<Widget> widgetList =
        siteSourceModelList.map((SiteSourceModel siteSourceModel) {
      return RadioListRow(
        siteSourceModel: siteSourceModel,
        groupValue: context.watch<XmlData>().apiBase,
        onChanged: (value) {
          context.read<XmlData>().title = siteSourceModel.name!;
          context.read<XmlData>().apiBase = siteSourceModel.url!;
          _temp_source_site_select([siteSourceModel]);
        },
        sourceEdit: (SiteSourceModel? value) async {},
        sourceCheck: (SiteSourceModel? value) async {
          value!.enable = await XmlData.sourceCheck(value.url ?? "");
          await _temp_source_site_merge([value]);
          (context as Element).markNeedsBuild();
          PageUtil.showAlertDialog(context, value.name! + "检测完成");
        },
        sourceRemove: (SiteSourceModel? value) async {
          int whereis = siteSourceModelList.indexWhere(
              (element) => element.url?.compareTo(value!.url!) == 0);
          if (whereis >= 0) {
            // 存在 移除
            siteSourceModelList.removeAt(whereis);
          }
          await _temp_source_site_remove([value!]);
          (context as Element).markNeedsBuild();
          PageUtil.showAlertDialog(context, value.name! + "移除完成");
        },
      );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgetList,
    );
  }

  Future<void> _temp_source_site_merge(
      List<SiteSourceModel> siteSourceModels) async {
    String sourceSiteList = await VideoModelCache.tempSourceSiteCacheManager
            .getString(VideoModelCache.SOURCE_SITE_LIST_CACHE_KEY_TRY_CACHE) ??
        "[]";

    List<dynamic> sourceSiteListDecode = json.decode(sourceSiteList);
    List<SiteSourceModel> siteSourceModelList =
        getSiteSourceModelList(sourceSiteListDecode);

    siteSourceModels.forEach((siteSourceModel) {
      int whereis = siteSourceModelList.indexWhere(
          (element) => element.url?.compareTo(siteSourceModel.url!) == 0);
      if (whereis < 0) {
        // 不存在 加入
        siteSourceModelList.add(siteSourceModel);
      } else {
        // 存在 进行修改
        siteSourceModelList[whereis] = siteSourceModel;
      }
    });
    String jsonEncode = json.encode(siteSourceModelList);
    await VideoModelCache.tempSourceSiteCacheManager.setString(
        VideoModelCache.SOURCE_SITE_LIST_CACHE_KEY_TRY_CACHE, jsonEncode);
  }

  Future<void> _temp_source_site_remove(
      List<SiteSourceModel> siteSourceModels) async {
    String sourceSiteList = await VideoModelCache.tempSourceSiteCacheManager
            .getString(VideoModelCache.SOURCE_SITE_LIST_CACHE_KEY_TRY_CACHE) ??
        "[]";

    List<dynamic> sourceSiteListDecode = json.decode(sourceSiteList);
    List<SiteSourceModel> siteSourceModelList =
        getSiteSourceModelList(sourceSiteListDecode);

    siteSourceModels.forEach((siteSourceModel) {
      int whereis = siteSourceModelList.indexWhere(
          (element) => element.url?.compareTo(siteSourceModel.url!) == 0);
      if (whereis >= 0) {
        // 存在 移除
        siteSourceModelList.removeAt(whereis);
      }
    });
    String jsonEncode = json.encode(siteSourceModelList);
    await VideoModelCache.tempSourceSiteCacheManager.setString(
        VideoModelCache.SOURCE_SITE_LIST_CACHE_KEY_TRY_CACHE, jsonEncode);
  }

  Future<void> _temp_source_site_select(
      List<SiteSourceModel> siteSourceModels) async {
    List<SiteSourceModel> siteSourceModelList = <SiteSourceModel>[];
    siteSourceModels.forEach((siteSourceModel) {
      siteSourceModelList.add(siteSourceModel);
    });

    String jsonEncode = json.encode(siteSourceModelList);
    await VideoModelCache.tempSourceSiteCacheManager.setString(
        VideoModelCache.SOURCE_SITE_CACHE_KEY_TRY_CACHE, jsonEncode);
  }
}
