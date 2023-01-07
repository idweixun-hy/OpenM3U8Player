import 'package:json_annotation/json_annotation.dart';

part 'site_source_model.g.dart';


List<SiteSourceModel> getSiteSourceModelList(List<dynamic> list){
	List<SiteSourceModel> result = [];
	list.forEach((item){
		result.add(SiteSourceModel.fromJson(item));
	});
	return result;
}
@JsonSerializable()
class SiteSourceModel extends Object {

	@JsonKey(name: 'name')
	String? name;

	@JsonKey(name: 'domain')
	String? domain;

	@JsonKey(name: 'type')
	String? type;

	@JsonKey(name: 'url')
	String? url;

	@JsonKey(name: 'analysis')
	String? analysis;

	@JsonKey(name: 'enable')
	bool? enable;

	SiteSourceModel(this.name,this.domain,this.type,this.url,this.analysis,this.enable,);

	factory SiteSourceModel.fromJson(Map<String, dynamic> srcJson) => _$SiteSourceModelFromJson(srcJson);

	Map<String, dynamic> toJson() => _$SiteSourceModelToJson(this);

}


