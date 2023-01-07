// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_source_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteSourceModel _$SiteSourceModelFromJson(Map<String, dynamic> json) {
  return SiteSourceModel(
    json['name'] as String?,
    json['domain'] as String?,
    json['type'] as String?,
    json['url'] as String?,
    json['analysis'] as String?,
    json['enable'] as bool?,
  );
}

Map<String, dynamic> _$SiteSourceModelToJson(SiteSourceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'domain': instance.domain,
      'type': instance.type,
      'url': instance.url,
      'analysis': instance.analysis,
      'enable': instance.enable,
    };
