import 'package:open_m3u8_player/generated/json/base/json_convert_content.dart';

class LiveHostListEntity with JsonConvert<LiveHostListEntity> {
	late List<LiveHostListZhubo> zhubo;
}

class LiveHostListZhubo with JsonConvert<LiveHostListZhubo> {
	late String address;
	late String img;
	late String title;
}
