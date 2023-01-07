

import 'dart:isolate';

import "package:collection/collection.dart";
import 'package:open_m3u8_player/util/IsolateUtil.dart';
import 'package:open_m3u8_player/util/netUtil.dart';

class M3u8PointIsolate extends IsolateCompute{
  final String m3u8Id;
  final List<String> tsList;

  M3u8PointIsolate( this.m3u8Id, this.tsList) : super();

  @override
  dynamic doCompute(){
    Map<int,List<String>> map = groupBy(this.tsList ,(ts) => this.tsList.indexOf(ts as String)%8);
    Future.wait(map.values.map((list) async{
      List<String> _tsList = await this._tsListByNet(list);
      while(_tsList.isNotEmpty){
        _tsList = await this._tsListByNet(_tsList);
      }
    }));
  }

  Future<List<String>> _tsListByNet( List<String> tsList ) async{
    List<String> _tsList = <String>[];
    for (var tsUrl in tsList) {
      try{
        await NetUtil.loadAsyncUint8List(tsUrl);
      }catch(e) {
        _tsList.add(tsUrl);
      }
    }
    return _tsList;
  }
}

class M3u8PointIsolateStopEvent{
  final String m3u8Id;
  final String m3u8Url;

  M3u8PointIsolateStopEvent( this.m3u8Id, this.m3u8Url);
}
