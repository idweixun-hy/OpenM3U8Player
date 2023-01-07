import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:open_m3u8_player/util/RandomUtil.dart';

Map<String, String> headersMap = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36 Edg/91.0.864.41",
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
  "Accept-Encoding": "gzip, deflate",
  "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
};

List<String> user_agents = <String>[
  "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
  "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:30.0) Gecko/20100101 Firefox/30.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14",
  "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)",
  'Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11',
  'Opera/9.25 (Windows NT 5.1; U; en)',
  'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
  'Mozilla/5.0 (compatible; Konqueror/3.5; Linux) KHTML/3.5.5 (like Gecko) (Kubuntu)',
  'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.12) Gecko/20070731 Ubuntu/dapper-security Firefox/1.5.0.12',
  'Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 GNUTLS/1.2.9',
  "Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.7 (KHTML, like Gecko) Ubuntu/11.04 Chromium/16.0.912.77 Chrome/16.0.912.77 Safari/535.7",
  "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:10.0) Gecko/20100101 Firefox/10.0",
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36 Edg/100.0.1185.39'
];

/// Efficiently converts the response body of an [HttpClientResponse] into a [Uint8List].
///
/// The future returned will forward all errors emitted by [response].
Future<Uint8List> consolidateHttpClientResponseBytes(
    HttpClientResponse response) {
  // response.contentLength is not trustworthy when GZIP is involved
  // or other cases where an intermediate transformer has been applied
  // to the stream.
  final Completer<Uint8List> completer = Completer<Uint8List>.sync();
  final List<int> chunks = <int>[];
  response.forEach(
          (element) {
        chunks.addAll(element);
      }
  ).then((value){
      final Uint8List bytes = Uint8List.fromList(chunks);
      completer.complete(bytes);
  }).catchError(
      completer.completeError
  );


  /*  final List<List<int>> chunks = <List<int>>[];
  int contentLength = 0;
  response.listen((List<int> chunk) {
    chunks.add(chunk);
    contentLength += chunk.length;
  }, onDone: () {

    final Uint8List bytes = Uint8List(contentLength);
    int offset = 0;
    for (List<int> chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    completer.complete(bytes);
  }, onError: completer.completeError, cancelOnError: true);*/
  return completer.future;
}

class NetUtil {
  static final Map<String, String> headers = {};
  static final HttpClient _httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) =>true;
  static final Dio _dio = Dio()..interceptors.add(DioCacheManager(CacheConfig(defaultMaxAge:Duration(minutes: 30))).interceptor);
  static final Options _options = Options(headers: headersMap);

  static Future<String> loadAsyncUint8ListByDio(String url) async{
    return (await loadAsyncDynamicByDio(url)).toString();
  }

  static Future<dynamic> loadAsyncDynamicByDio(String url,{ResponseType? responseType}) async{
    return (await loadAsyncResponseByDio(url,responseType: responseType)).data;
  }

  static Future<Response> loadAsyncResponseByDio(String url,{ResponseType? responseType}) async{
    _options.responseType = responseType??_options.responseType;
    _options.followRedirects = true;

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      /*
      client.findProxy = (url) {
        ///设置代理 电脑ip地址
        return "PROXY 192.168.0.103:8888";

        ///不设置代理
//          return 'DIRECT';
      };
      */
      ///忽略证书
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    };
    Response response = await _dio.get(url,options: buildCacheOptions(Duration(minutes: 30),options:  _options));
    if (response.statusCode != HttpStatus.ok)
      throw Exception(
          'HTTP request failed, statusCode: ${response.statusCode}, ${url}'
      );
    return response;
  }

  static Future<Uint8List> loadAsyncUint8List(String url) async {
    final Uri resolved = Uri.base.resolve(url);
    return loadAsyncUint8ListUri(resolved);
  }
  static Future<Uint8List> loadAsyncUint8ListUri(Uri resolved) async {
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    int next = RandomUtil.next(0, user_agents.length);
    headersMap.forEach((String name, String value) {
      request.headers.set(name, name == "User-Agent" ? user_agents[next]: value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw Exception(
          'HTTP request failed, statusCode: ${response.statusCode}, $resolved');

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0)
      throw Exception('NetworkImage is an empty file: $resolved');

    return bytes;
  }

  static Future<String> loadAsync(String url) async {
    print("loadAsync-url:${url}");
    final Uint8List bytes = await loadAsyncUint8List(url);
    return utf8.decode(bytes);
  }

  static Future<String> loadAsyncDio(String url) async {
    print("url:${url}");
    return await loadAsyncUint8ListByDio(url);
  }
}
