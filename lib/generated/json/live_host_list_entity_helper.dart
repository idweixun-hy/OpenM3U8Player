import 'package:open_m3u8_player/data/live_host_list_entity.dart';

liveHostListEntityFromJson(LiveHostListEntity data, Map<String, dynamic> json) {
	if (json['zhubo'] != null) {
		data.zhubo = (json['zhubo'] as List).map((v) => LiveHostListZhubo().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> liveHostListEntityToJson(LiveHostListEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['zhubo'] =  entity.zhubo.map((v) => v.toJson()).toList();
	return data;
}

liveHostListZhuboFromJson(LiveHostListZhubo data, Map<String, dynamic> json) {
	if (json['address'] != null) {
		data.address = json['address'].toString();
	}
	if (json['img'] != null) {
		data.img = json['img'].toString();
	}
	if (json['title'] != null) {
		data.title = json['title'].toString();
	}
	return data;
}

Map<String, dynamic> liveHostListZhuboToJson(LiveHostListZhubo entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['address'] = entity.address;
	data['img'] = entity.img;
	data['title'] = entity.title;
	return data;
}
