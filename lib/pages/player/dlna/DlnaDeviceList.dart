import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'DlnaDialog.dart';

Map<String, DLNADevice> cacheDeviceList = Map();

class DlnaDeviceList extends StatefulWidget {
  final String videoM3u8Url;
  DlnaDeviceList(this.videoM3u8Url);

  @override
  State<StatefulWidget> createState() => DlnaDeviceListState();
}

class DlnaDeviceListState extends State<DlnaDeviceList> {
  late DLNAManager searcher;
  late final DeviceManager m;
  Timer timer = Timer(Duration(seconds: 1), () {});
  Map<String, DLNADevice> deviceList = Map();
  late String videoM3u8Url = widget.videoM3u8Url;
  late FToast fToast;
  @override
  initState() {
    super.initState();
    Uri localUri = Uri.parse(widget.videoM3u8Url);
    Clipboard.setData(ClipboardData(text: "${localUri.scheme}://${localUri.host}:${localUri.hasPort?localUri.port:'80'}/player.html?url=${Uri.encodeComponent(widget.videoM3u8Url)}"));
    fToast = FToast();
    fToast.init(context);
    searcher = DLNAManager();
    init();
  }

  init() async {
    m = await searcher.start();
    timer.cancel();
    final callback = (timer) {
      m.deviceList.forEach((key, value) {
        cacheDeviceList[key] = value;
      });
      setState(() {
        deviceList = cacheDeviceList;
      });
    };
    timer = Timer.periodic(Duration(seconds: 5), callback);
    callback(null);
  }

  @override
  void dispose() {
    timer.cancel();
    searcher.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("投屏助手"),
        ),
        body:deviceList.length == 0
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(onRefresh: _pullToRefresh, child: _body())
        );
  }

  Future _pullToRefresh() async {
    m.deviceList.forEach((key, value) {
      cacheDeviceList[key] = value;
    });
    setState(() {
      deviceList = cacheDeviceList;
    });
  }

  Widget _body() {
    if (deviceList.length < 0) {
      return SizedBox(
        height: 200,
        child: CircularProgressIndicator(),
      );
    }
    final List<Widget> dlist = [];
    deviceList.forEach((uri, device) {
      dlist.add(buildItem(uri, device));
    });

    return ListView(
      children: dlist,
    );
  }

  Widget buildItem(String uri, DLNADevice device) {
    final title = device.info.friendlyName;
    final subtitle = uri + '\r\n' + device.info.deviceType;
    final s = subtitle.toLowerCase();
    var icon = Icons.wifi;
    final support = s.contains("mediarenderer") || s.contains("avtransport");
    if (!support) {
      icon = Icons.router;
    }
    final card = Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              bottom: 30,
            ),
            child: CircleAvatar(
              child: Icon(icon),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 100, 135),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          subtitle,
                          softWrap: false,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 100, 100, 135),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]));

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: InkWell(
        child: card,
        onTap: () {
          if (!support) {
            final msg = "该设备不支持投屏";
            fToast.showToast(
              gravity: ToastGravity.CENTER,
              child: Text(
                msg,
                style: TextStyle(
                  backgroundColor: Colors.blue,
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),);
            return;
          }
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  children: [
                    DlnaDialog(
                      device,
                      videoM3u8Url,
                    )
                  ],
                );
              });
        },
      ),
    );
  }
}
