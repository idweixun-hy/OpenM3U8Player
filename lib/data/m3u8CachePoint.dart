import 'dart:io';

import 'package:open_m3u8_player/store/file_store.dart';

/**
 * 当前视频播放的缓存
 *
 * Uri.encodeComponent(url); // To encode url
 * Uri.decodeComponent(encodedUrl); // To decode url
 *
 * 缓存key
 *    $cache_point<@>$m3u8Id<@>m3u8Url<@>$m3u8Url:m3u8Date<size@1024b>     m3u8    地址
 *    $cache_point<@>$m3u8Id<@>keyUrl<@>$keyUrl:keyDate<size@1024b>        key     地址
 *    $cache_point<@>$m3u8Id<@>tsList<@>$tsUrl:tsData<size@1024b>          tsData  数据<size@数据长度b>
 *
 */
class M3u8CachePoint {
  static final String _M3U8_CACHE_POINT = "_m3u8_cache_point";
  static final String _SEPARATOR = "${Platform.pathSeparator}";

  static Future<FileCacheManager> get _m3u8fileCacheManager async {
    return FileCacheManager(await FileStore.doInit(), _M3U8_CACHE_POINT,
        separator: _SEPARATOR);
  }

  static Future<void> cleanAll() async {
    (await _m3u8fileCacheManager).clearAll();
  }

  static Future<double> allSize() async {
    List<File?> fileList =
        await (await _m3u8fileCacheManager).getBaseCacheFiles();
    List<double> doubleList = await Future.wait<double>(fileList.map((file) async{
      if (null != file && file.existsSync()) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      return 0.0;
    }));

    return _file_size_get(doubleList);
  }

  static Future<String> allSizeStr() async {
    return renderSize(await allSize());
  }

  //格式化文件大小
  static String renderSize(double value) {
    if (null == value) {
      return '0B';
    }
    List<String> unitArr = []..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  final String m3u8Id;

  Future<double> get dataSize async {
    List<File?> fileList =
        await (await _m3u8fileCacheManager).getTempCacheFiles(m3u8Id);
    List<double> doubleList = await Future.wait<double>(fileList.map((file) async{
      if (null != file && file.existsSync()) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      return 0.0;
    }));

    return _file_size_get(doubleList);
  }

  Future<String> dataSizeStr() async {
    return renderSize(await this.dataSize);
  }

  Future<String> _getM3u8Key(String m3u8Url) async {
    return "$m3u8Id<@>m3u8Url<@>${Uri.encodeComponent((m3u8Url))}";
  }

  Future<String> _getTsKey(String tsUrl) async {
    return "$m3u8Id<@>tsList<@>${Uri.encodeComponent((tsUrl))}";
  }

  Future<String> _getKeyKey(String keyUrl) async {
    return "$m3u8Id<@>keyUrl<@>${Uri.encodeComponent((keyUrl))}";
  }

  /**
   * 获取 ts 缓存数据
   */
  Future<String?> getTsData(String tsUrl) async {
    String tsKey = await _getTsKey(tsUrl);
    String? tsData = await (await _m3u8fileCacheManager).getString(tsKey);
    return tsData;
  }

  /**
   * 添加 ts 缓存数据
   */
  Future<void> setTsData(String tsUrl, String tsData) async {
    String tsKey = await _getTsKey(tsUrl);
    return await (await _m3u8fileCacheManager)
        .setString(tsKey, tsData);
  }

  /**
   * 获取 key 缓存数据
   */
  Future<String?> getKeyData(String keyUrl) async {
    String keyKey = await _getKeyKey(keyUrl);
    String? keyData = await (await _m3u8fileCacheManager).getString(keyKey);
    return keyData;
  }

  /**
   * 添加 key 缓存数据
   */
  Future<void> setKeyData(String keyUrl, String keyData) async {
    String keyKey = await _getKeyKey(keyUrl);
    return await (await _m3u8fileCacheManager)
        .setString(keyKey, keyData);
  }

  Future<String?> getM3u8Data(String m3u8Url) async {
    String m3u8Key = await _getM3u8Key(m3u8Url);
    String? m3u8DataAndSize =
        await (await _m3u8fileCacheManager).getString(m3u8Key);
    return m3u8DataAndSize;
  }

  /**
   * 添加 m3u8 缓存数据
   */
  Future<void> setM3u8Data(String m3u8Url, String m3u8Data) async {
    String m3u8Key = await _getM3u8Key(m3u8Url);
    return await (await _m3u8fileCacheManager)
        .setString(m3u8Key, m3u8Data);
  }

  static double _file_size_get(List<double?> sizeList) => sizeList
      .fold<double>(0.0, (value, element) => value + (element??0.0));

  static M3u8CachePoint creator(String m3u8Id) {
    return M3u8CachePoint._init(m3u8Id);
  }

  M3u8CachePoint._init(this.m3u8Id);

  Future<void> cleanTempAll() async {
    (await _m3u8fileCacheManager).delTempCacheValues(m3u8Id);
  }
}
