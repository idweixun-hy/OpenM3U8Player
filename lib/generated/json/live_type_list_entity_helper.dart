import 'package:open_m3u8_player/data/live_type_list_entity.dart';

liveTypeListEntityFromJson(LiveTypeListEntity data, Map<String, dynamic> json) {
	if (json['pingtai'] != null) {
		data.pingtai = (json['pingtai'] as List).map((v) => LiveTypeListPingtai().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> liveTypeListEntityToJson(LiveTypeListEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['pingtai'] =  entity.pingtai.map((v) => v.toJson()).toList();
	return data;
}

liveTypeListPingtaiFromJson(LiveTypeListPingtai data, Map<String, dynamic> json) {
	if (json['address'] != null) {
		data.address = json['address'].toString();
	}
	if (json['xinimg'] != null) {
		data.xinimg = json['xinimg'].toString();
	}
	if (json['Number'] != null) {
		data.number = json['Number'].toString();
	}
	if (json['title'] != null) {
		data.title = json['title'].toString();
	}
	return data;
}

Map<String, dynamic> liveTypeListPingtaiToJson(LiveTypeListPingtai entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['address'] = entity.address;
	data['xinimg'] = entity.xinimg;
	data['Number'] = entity.number;
	data['title'] = entity.title;
	return data;
}
