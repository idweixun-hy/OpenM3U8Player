// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videomodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) {
  return VideoModel(
    apiBase: json['apiBase'] as String?,
    id: json['id'] as String?,
    last: json['last'] as String?,
    tid: json['tid'] as String?,
    type: json['type'] as String?,
    name: json['name'] as String?,
    pic: json['pic'] as String?,
    lang: json['lang'] as String?,
    area: json['area'] as String?,
    year: json['year'] as String?,
    state: json['state'] as String?,
    keywords: json['keywords'] as String?,
    len: json['len'] as String?,
    total: json['total'] as String?,
    jq: json['jq'] as String?,
    nickname: json['nickname'] as String?,
    reweek: json['reweek'] as String?,
    douban: json['douban'] as String?,
    mtime: json['mtime'] as String?,
    imdb: json['imdb'] as String?,
    tvs: json['tvs'] as String?,
    company: json['company'] as String?,
    ver: json['ver'] as String?,
    longtxt: json['longtxt'] as String?,
    note: json['note'] as String?,
    actor: json['actor'] as String?,
    director: json['director'] as String?,
    dl: (json['dl'] as List<dynamic>?)?.map((e) => e as String).toList(),
    des: json['des'] as String?,
    reurl: json['reurl'] as String?,
  );
}

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'apiBase': instance.apiBase,
      'id': instance.id,
      'last': instance.last,
      'tid': instance.tid,
      'type': instance.type,
      'name': instance.name,
      'pic': instance.pic,
      'lang': instance.lang,
      'area': instance.area,
      'year': instance.year,
      'state': instance.state,
      'keywords': instance.keywords,
      'len': instance.len,
      'total': instance.total,
      'jq': instance.jq,
      'nickname': instance.nickname,
      'reweek': instance.reweek,
      'douban': instance.douban,
      'mtime': instance.mtime,
      'imdb': instance.imdb,
      'tvs': instance.tvs,
      'company': instance.company,
      'ver': instance.ver,
      'longtxt': instance.longtxt,
      'note': instance.note,
      'actor': instance.actor,
      'director': instance.director,
      'dl': instance.dl,
      'des': instance.des,
      'reurl': instance.reurl,
    };
