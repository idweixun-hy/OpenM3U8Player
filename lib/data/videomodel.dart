import 'package:json_annotation/json_annotation.dart';
import 'package:xml/xml.dart' as xml;

part 'videomodel.g.dart';

@JsonSerializable()
class VideoModel {
  // 影片来源地址
  String? apiBase;
  // 影片ID
  String? id;
  // 更新时间
  String? last;
  // 分类ID
  String? tid;
  // 分类名称
  String? type;
  // 影片名称
  String? name;
  // 标题图片
  String? pic;
  // 语种
  String? lang;
  // 地区
  String? area;
  // 上映年份
  String? year;
  String? state;
  String? keywords;
  String? len;
  String? total;
  String? jq;
  String? nickname;
  String? reweek;
  String? douban;
  String? mtime;
  String? imdb;
  String? tvs;
  String? company;
  String? ver;
  String? longtxt;
  // 备注
  String? note;
  // 主要演员
  String? actor;
  // 导演
  String? director;
  // 分集数据
  List<String>? dl;
  // 详情介绍
  String? des;
  String? reurl;
  VideoModel({this.apiBase,this.id,this.last,this.tid,this.type,
    this.name,this.pic,this.lang,this.area,this.year,
    this.state,this.keywords,this.len,this.total,this.jq,
    this.nickname,this.reweek,this.douban,this.mtime,this.imdb,this.tvs,
    this.company,this.ver,this.longtxt,this.note,this.actor,this.director,
    this.dl,this.des,this.reurl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  static List<String> dlInit(xml.XmlElement? xeDl){
    if (xeDl == null) {
      return <String>[];
    }
    return xeDl.findElements("dd").map(
            (xml.XmlElement dd) => dd.text.trim()
    ).toList();
  }
  static String fildValue(xml.XmlElement xe, String key){
    Iterable<xml.XmlElement> iterable = xe.findElements(key);
    if (iterable.isNotEmpty){
      return iterable.first.text.trim();
    }
    return "";
  }
}
