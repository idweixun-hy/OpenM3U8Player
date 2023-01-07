import 'package:open_m3u8_player/generated/json/base/json_convert_content.dart';
import 'package:open_m3u8_player/generated/json/base/json_field.dart';

class LiveTypeListEntity with JsonConvert<LiveTypeListEntity> {
	late List<LiveTypeListPingtai> pingtai;
}

class LiveTypeListPingtai with JsonConvert<LiveTypeListPingtai> {
	late String address;
	late String xinimg;
	@JSONField(name: "Number")
	late String number;
	late String title;
}
