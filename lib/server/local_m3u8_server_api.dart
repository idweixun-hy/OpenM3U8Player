import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/services.dart';
import 'package:open_m3u8_player/data/M3u8PointIsolate.dart';
import 'package:open_m3u8_player/data/m3u8CachePoint.dart';
import 'package:open_m3u8_player/data/m3u8TempPoint.dart';
import 'package:open_m3u8_player/util/IsolateUtil.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../data/videomodelcache.dart';

class LocalM3u8Server {
  static final List<String> _AD_DOMAIN = <String>[
    "ad.hjyedu88.com",
    "vip2.bfbfhao.com",
  ] ;

  static HttpServer? _localHttpServer ;
  static EventBus _eventBus = EventBus();
  static Map<String,Isolate> _isolateMap = <String,Isolate>{};

  static Future<HttpServer> _buildHttpServer(String manifestJson) async{
    if (null != _localHttpServer) {
      return _localHttpServer!;
    }
    _eventBus.on<M3u8PointIsolateStopEvent>().listen((event) {
      if (_isolateMap.containsKey(event.m3u8Id)) {
        _isolateMap[event.m3u8Id]?.kill();
      }
    });
    // return LocalM3u8Server._localHttpServer = await (await IsolateUtil.isolateCompute(LocalM3u8Server())).data;
    return LocalM3u8Server._localHttpServer = await shelfServerInit(manifestJson);
  }

  /**
   * 创建连接的 M3u8 文件链接地址
   */
  static Future<M3u8PointIsolateStopEvent> buildLocalM3u8( String manifestJson, String cacheType, String m3u8Id, String m3u8Url) async{

    // 首先清除当前观看缓存数据
    M3u8TempPoint m3u8tempPoint = M3u8TempPoint.creator(m3u8Id);
    if ((await m3u8tempPoint.dataSize) <= 0.0){
      // 如果缓存数据与当前观看数据不匹配
      await M3u8TempPoint.cleanAll();
    }

    HttpServer localHttpServer = await LocalM3u8Server._buildHttpServer(manifestJson);
    String baseUrl = "http://${localHttpServer.address.address}:${localHttpServer.port}";
    return M3u8PointIsolateStopEvent(m3u8Id,"$baseUrl/parser/$cacheType/$m3u8Id/${Uri.encodeComponent(m3u8Url)}");
  }
  static Future<void> busFire(M3u8PointIsolateStopEvent m3u8pointIsolateStopEvent) async{
    _eventBus.fire(m3u8pointIsolateStopEvent);
  }

  static Future<String> mkWebPlayerPath (String manifestJson, String title, String urlDate) async {
    HttpServer localHttpServer = await LocalM3u8Server._buildHttpServer(manifestJson);
    await VideoModelCache.appConfigJListKeyTryCacheManager.setString(VideoModelCache.APP_CONFIG_JLIST_KEY_TRY_CACHE, urlDate);
    String baseUrl = "http://${localHttpServer.address.address}:${localHttpServer.port}";
    return "$baseUrl/webPlayer/${Uri.encodeComponent(title)}/${VideoModelCache.APP_CONFIG_JLIST_KEY_TRY_CACHE}";
  }
}

Future<HttpServer> shelfServerInit(String manifestJson) async {
  String publicPath = "assets/web/";
  String address = "localhost";
  int port = 8888;

  List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: false, type: InternetAddressType.any);
  interfaces.forEach((interface) {
    if (address == 'localhost' && interface.addresses.isNotEmpty) {
      address = "${interface.addresses[0].address}";
    }
  });

  String baseUrl = "http://${address}:${port}";

  // final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
  final List<String> webFiles = List.from(json.decode(manifestJson).keys.where((String key) => key.startsWith(publicPath)));
  final Map<String,String> CONTENT_TYPE = {
    '.load': 'text/html',
    '.123': 'application/vnd.lotus-1-2-3',
    '.3ds': 'image/x-3ds',
    '.3g2': 'video/3gpp',
    '.3ga': 'video/3gpp',
    '.3gp': 'video/3gpp',
    '.3gpp': 'video/3gpp',
    '.602': 'application/x-t602',
    '.669': 'audio/x-mod',
    '.7z': 'application/x-7z-compressed',
    '.a': 'application/x-archive',
    '.aac': 'audio/mp4',
    '.abw': 'application/x-abiword',
    '.abw.crashed': 'application/x-abiword',
    '.abw.gz': 'application/x-abiword',
    '.ac3': 'audio/ac3',
    '.ace': 'application/x-ace',
    '.adb': 'text/x-adasrc',
    '.ads': 'text/x-adasrc',
    '.afm': 'application/x-font-afm',
    '.ag': 'image/x-applix-graphics',
    '.ai': 'application/illustrator',
    '.aif': 'audio/x-aiff',
    '.aifc': 'audio/x-aiff',
    '.aiff': 'audio/x-aiff',
    '.al': 'application/x-perl',
    '.alz': 'application/x-alz',
    '.amr': 'audio/amr',
    '.ani': 'application/x-navi-animation',
    '.anim[1-9j]': 'video/x-anim',
    '.anx': 'application/annodex',
    '.ape': 'audio/x-ape',
    '.arj': 'application/x-arj',
    '.arw': 'image/x-sony-arw',
    '.as': 'application/x-applix-spreadsheet',
    '.asc': 'text/plain',
    '.asf': 'video/x-ms-asf',
    '.asp': 'application/x-asp',
    '.ass': 'text/x-ssa',
    '.asx': 'audio/x-ms-asx',
    '.atom': 'application/atom+xml',
    '.au': 'audio/basic',
    '.avi': 'video/x-msvideo',
    '.aw': 'application/x-applix-word',
    '.awb': 'audio/amr-wb',
    '.awk': 'application/x-awk',
    '.axa': 'audio/annodex',
    '.axv': 'video/annodex',
    '.bak': 'application/x-trash',
    '.bcpio': 'application/x-bcpio',
    '.bdf': 'application/x-font-bdf',
    '.bib': 'text/x-bibtex',
    '.bin': 'application/octet-stream',
    '.blend': 'application/x-blender',
    '.blender': 'application/x-blender',
    '.bmp': 'image/bmp',
    '.bz': 'application/x-bzip',
    '.bz2': 'application/x-bzip',
    '.c': 'text/x-csrc',
    '.c++': 'text/x-c++src',
    '.cab': 'application/vnd.ms-cab-compressed',
    '.cb7': 'application/x-cb7',
    '.cbr': 'application/x-cbr',
    '.cbt': 'application/x-cbt',
    '.cbz': 'application/x-cbz',
    '.cc': 'text/x-c++src',
    '.cdf': 'application/x-netcdf',
    '.cdr': 'application/vnd.corel-draw',
    '.cer': 'application/x-x509-ca-cert',
    '.cert': 'application/x-x509-ca-cert',
    '.cgm': 'image/cgm',
    '.chm': 'application/x-chm',
    '.chrt': 'application/x-kchart',
    '.class': 'application/x-java',
    '.cls': 'text/x-tex',
    '.cmake': 'text/x-cmake',
    '.cpio': 'application/x-cpio',
    '.cpio.gz': 'application/x-cpio-compressed',
    '.cpp': 'text/x-c++src',
    '.cr2': 'image/x-canon-cr2',
    '.crt': 'application/x-x509-ca-cert',
    '.crw': 'image/x-canon-crw',
    '.cs': 'text/x-csharp',
    '.csh': 'application/x-csh',
    '.css': 'text/css',
    '.cssl': 'text/css',
    '.csv': 'text/csv',
    '.cue': 'application/x-cue',
    '.cur': 'image/x-win-bitmap',
    '.cxx': 'text/x-c++src',
    '.d': 'text/x-dsrc',
    '.dar': 'application/x-dar',
    '.dbf': 'application/x-dbf',
    '.dc': 'application/x-dc-rom',
    '.dcl': 'text/x-dcl',
    '.dcm': 'application/dicom',
    '.dcr': 'image/x-kodak-dcr',
    '.dds': 'image/x-dds',
    '.deb': 'application/x-deb',
    '.der': 'application/x-x509-ca-cert',
    '.desktop': 'application/x-desktop',
    '.dia': 'application/x-dia-diagram',
    '.diff': 'text/x-patch',
    '.divx': 'video/x-msvideo',
    '.djv': 'image/vnd.djvu',
    '.djvu': 'image/vnd.djvu',
    '.dng': 'image/x-adobe-dng',
    '.doc': 'application/msword',
    '.docbook': 'application/docbook+xml',
    '.docm': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.dot': 'text/vnd.graphviz',
    '.dsl': 'text/x-dsl',
    '.dtd': 'application/xml-dtd',
    '.dtx': 'text/x-tex',
    '.dv': 'video/dv',
    '.dvi': 'application/x-dvi',
    '.dvi.bz2': 'application/x-bzdvi',
    '.dvi.gz': 'application/x-gzdvi',
    '.dwg': 'image/vnd.dwg',
    '.dxf': 'image/vnd.dxf',
    '.e': 'text/x-eiffel',
    '.egon': 'application/x-egon',
    '.eif': 'text/x-eiffel',
    '.el': 'text/x-emacs-lisp',
    '.emf': 'image/x-emf',
    '.emp': 'application/vnd.emusic-emusic_package',
    '.ent': 'application/xml-external-parsed-entity',
    '.eps': 'image/x-eps',
    '.eps.bz2': 'image/x-bzeps',
    '.eps.gz': 'image/x-gzeps',
    '.epsf': 'image/x-eps',
    '.epsf.bz2': 'image/x-bzeps',
    '.epsf.gz': 'image/x-gzeps',
    '.epsi': 'image/x-eps',
    '.epsi.bz2': 'image/x-bzeps',
    '.epsi.gz': 'image/x-gzeps',
    '.epub': 'application/epub+zip',
    '.erl': 'text/x-erlang',
    '.es': 'application/ecmascript',
    '.etheme': 'application/x-e-theme',
    '.etx': 'text/x-setext',
    '.exe': 'application/x-ms-dos-executable',
    '.exr': 'image/x-exr',
    '.ez': 'application/andrew-inset',
    '.f': 'text/x-fortran',
    '.f90': 'text/x-fortran',
    '.f95': 'text/x-fortran',
    '.fb2': 'application/x-fictionbook+xml',
    '.fig': 'image/x-xfig',
    '.fits': 'image/fits',
    '.fl': 'application/x-fluid',
    '.flac': 'audio/x-flac',
    '.flc': 'video/x-flic',
    '.fli': 'video/x-flic',
    '.flv': 'video/x-flv',
    '.flw': 'application/x-kivio',
    '.fo': 'text/x-xslfo',
    '.for': 'text/x-fortran',
    '.g3': 'image/fax-g3',
    '.gb': 'application/x-gameboy-rom',
    '.gba': 'application/x-gba-rom',
    '.gcrd': 'text/directory',
    '.ged': 'application/x-gedcom',
    '.gedcom': 'application/x-gedcom',
    '.gen': 'application/x-genesis-rom',
    '.gf': 'application/x-tex-gf',
    '.gg': 'application/x-sms-rom',
    '.gif': 'image/gif',
    '.glade': 'application/x-glade',
    '.gmo': 'application/x-gettext-translation',
    '.gnc': 'application/x-gnucash',
    '.gnd': 'application/gnunet-directory',
    '.gnucash': 'application/x-gnucash',
    '.gnumeric': 'application/x-gnumeric',
    '.gnuplot': 'application/x-gnuplot',
    '.gp': 'application/x-gnuplot',
    '.gpg': 'application/pgp-encrypted',
    '.gplt': 'application/x-gnuplot',
    '.gra': 'application/x-graphite',
    '.gsf': 'application/x-font-type1',
    '.gsm': 'audio/x-gsm',
    '.gtar': 'application/x-tar',
    '.gv': 'text/vnd.graphviz',
    '.gvp': 'text/x-google-video-pointer',
    '.gz': 'application/x-gzip',
    '.h': 'text/x-chdr',
    '.h++': 'text/x-c++hdr',
    '.hdf': 'application/x-hdf',
    '.hh': 'text/x-c++hdr',
    '.hp': 'text/x-c++hdr',
    '.hpgl': 'application/vnd.hp-hpgl',
    '.hpp': 'text/x-c++hdr',
    '.hs': 'text/x-haskell',
    '.htm': 'text/html',
    '.html': 'text/html',
    '.hwp': 'application/x-hwp',
    '.hwt': 'application/x-hwt',
    '.hxx': 'text/x-c++hdr',
    '.ica': 'application/x-ica',
    '.icb': 'image/x-tga',
    '.icns': 'image/x-icns',
    '.ico': 'image/vnd.microsoft.icon',
    '.ics': 'text/calendar',
    '.idl': 'text/x-idl',
    '.ief': 'image/ief',
    '.iff': 'image/x-iff',
    '.ilbm': 'image/x-ilbm',
    '.ime': 'text/x-imelody',
    '.imy': 'text/x-imelody',
    '.ins': 'text/x-tex',
    '.iptables': 'text/x-iptables',
    '.iso': 'application/x-cd-image',
    '.iso9660': 'application/x-cd-image',
    '.it': 'audio/x-it',
    '.j2k': 'image/jp2',
    '.jad': 'text/vnd.sun.j2me.app-descriptor',
    '.jar': 'application/x-java-archive',
    '.java': 'text/x-java',
    '.jng': 'image/x-jng',
    '.jnlp': 'application/x-java-jnlp-file',
    '.jp2': 'image/jp2',
    '.jpc': 'image/jp2',
    '.jpe': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.jpf': 'image/jp2',
    '.jpg': 'image/jpeg',
    '.jpr': 'application/x-jbuilder-project',
    '.jpx': 'image/jp2',
    '.js': 'application/javascript',
    '.json': 'application/json',
    '.jsonp': 'application/jsonp',
    '.k25': 'image/x-kodak-k25',
    '.kar': 'audio/midi',
    '.karbon': 'application/x-karbon',
    '.kdc': 'image/x-kodak-kdc',
    '.kdelnk': 'application/x-desktop',
    '.kexi': 'application/x-kexiproject-sqlite3',
    '.kexic': 'application/x-kexi-connectiondata',
    '.kexis': 'application/x-kexiproject-shortcut',
    '.kfo': 'application/x-kformula',
    '.kil': 'application/x-killustrator',
    '.kino': 'application/smil',
    '.kml': 'application/vnd.google-earth.kml+xml',
    '.kmz': 'application/vnd.google-earth.kmz',
    '.kon': 'application/x-kontour',
    '.kpm': 'application/x-kpovmodeler',
    '.kpr': 'application/x-kpresenter',
    '.kpt': 'application/x-kpresenter',
    '.kra': 'application/x-krita',
    '.ksp': 'application/x-kspread',
    '.kud': 'application/x-kugar',
    '.kwd': 'application/x-kword',
    '.kwt': 'application/x-kword',
    '.la': 'application/x-shared-library-la',
    '.latex': 'text/x-tex',
    '.ldif': 'text/x-ldif',
    '.lha': 'application/x-lha',
    '.lhs': 'text/x-literate-haskell',
    '.lhz': 'application/x-lhz',
    '.log': 'text/x-log',
    '.ltx': 'text/x-tex',
    '.lua': 'text/x-lua',
    '.lwo': 'image/x-lwo',
    '.lwob': 'image/x-lwo',
    '.lws': 'image/x-lws',
    '.ly': 'text/x-lilypond',
    '.lyx': 'application/x-lyx',
    '.lz': 'application/x-lzip',
    '.lzh': 'application/x-lha',
    '.lzma': 'application/x-lzma',
    '.lzo': 'application/x-lzop',
    '.m': 'text/x-matlab',
    '.m15': 'audio/x-mod',
    '.m2t': 'video/mpeg',
    '.m3u': 'application/vnd.apple.mpegurl',
    '.m3u8': 'application/vnd.apple.mpegurl',
    '.m4': 'application/x-m4',
    '.m4a': 'audio/mp4',
    '.m4b': 'audio/x-m4b',
    '.m4v': 'video/mp4',
    '.mab': 'application/x-markaby',
    '.man': 'application/x-troff-man',
    '.mbox': 'application/mbox',
    '.md': 'application/x-genesis-rom',
    '.mdb': 'application/vnd.ms-access',
    '.mdi': 'image/vnd.ms-modi',
    '.me': 'text/x-troff-me',
    '.med': 'audio/x-mod',
    '.metalink': 'application/metalink+xml',
    '.mgp': 'application/x-magicpoint',
    '.mid': 'audio/midi',
    '.midi': 'audio/midi',
    '.mif': 'application/x-mif',
    '.minipsf': 'audio/x-minipsf',
    '.mka': 'audio/x-matroska',
    '.mkv': 'video/x-matroska',
    '.ml': 'text/x-ocaml',
    '.mli': 'text/x-ocaml',
    '.mm': 'text/x-troff-mm',
    '.mmf': 'application/x-smaf',
    '.mml': 'text/mathml',
    '.mng': 'video/x-mng',
    '.mo': 'application/x-gettext-translation',
    '.mo3': 'audio/x-mo3',
    '.moc': 'text/x-moc',
    '.mod': 'audio/x-mod',
    '.mof': 'text/x-mof',
    '.moov': 'video/quicktime',
    '.mov': 'video/quicktime',
    '.movie': 'video/x-sgi-movie',
    '.mp+': 'audio/x-musepack',
    '.mp2': 'video/mpeg',
    '.mp3': 'audio/mpeg',
    '.mp4': 'video/mp4',
    '.mpc': 'audio/x-musepack',
    '.mpe': 'video/mpeg',
    '.mpeg': 'video/mpeg',
    '.mpg': 'video/mpeg',
    '.mpga': 'audio/mpeg',
    '.mpp': 'audio/x-musepack',
    '.mrl': 'text/x-mrml',
    '.mrml': 'text/x-mrml',
    '.mrw': 'image/x-minolta-mrw',
    '.ms': 'text/x-troff-ms',
    '.msi': 'application/x-msi',
    '.msod': 'image/x-msod',
    '.msx': 'application/x-msx-rom',
    '.mtm': 'audio/x-mod',
    '.mup': 'text/x-mup',
    '.mxf': 'application/mxf',
    '.n64': 'application/x-n64-rom',
    '.nb': 'application/mathematica',
    '.nc': 'application/x-netcdf',
    '.nds': 'application/x-nintendo-ds-rom',
    '.nef': 'image/x-nikon-nef',
    '.nes': 'application/x-nes-rom',
    '.nfo': 'text/x-nfo',
    '.not': 'text/x-mup',
    '.nsc': 'application/x-netshow-channel',
    '.nsv': 'video/x-nsv',
    '.o': 'application/x-object',
    '.obj': 'application/x-tgif',
    '.ocl': 'text/x-ocl',
    '.oda': 'application/oda',
    '.odb': 'application/vnd.oasis.opendocument.database',
    '.odc': 'application/vnd.oasis.opendocument.chart',
    '.odf': 'application/vnd.oasis.opendocument.formula',
    '.odg': 'application/vnd.oasis.opendocument.graphics',
    '.odi': 'application/vnd.oasis.opendocument.image',
    '.odm': 'application/vnd.oasis.opendocument.text-master',
    '.odp': 'application/vnd.oasis.opendocument.presentation',
    '.ods': 'application/vnd.oasis.opendocument.spreadsheet',
    '.odt': 'application/vnd.oasis.opendocument.text',
    '.oga': 'audio/ogg',
    '.ogg': 'video/x-theora+ogg',
    '.ogm': 'video/x-ogm+ogg',
    '.ogv': 'video/ogg',
    '.ogx': 'application/ogg',
    '.old': 'application/x-trash',
    '.oleo': 'application/x-oleo',
    '.opml': 'text/x-opml+xml',
    '.ora': 'image/openraster',
    '.orf': 'image/x-olympus-orf',
    '.otc': 'application/vnd.oasis.opendocument.chart-template',
    '.otf': 'application/x-font-otf',
    '.otg': 'application/vnd.oasis.opendocument.graphics-template',
    '.oth': 'application/vnd.oasis.opendocument.text-web',
    '.otp': 'application/vnd.oasis.opendocument.presentation-template',
    '.ots': 'application/vnd.oasis.opendocument.spreadsheet-template',
    '.ott': 'application/vnd.oasis.opendocument.text-template',
    '.owl': 'application/rdf+xml',
    '.oxt': 'application/vnd.openofficeorg.extension',
    '.p': 'text/x-pascal',
    '.p10': 'application/pkcs10',
    '.p12': 'application/x-pkcs12',
    '.p7b': 'application/x-pkcs7-certificates',
    '.p7s': 'application/pkcs7-signature',
    '.pack': 'application/x-java-pack200',
    '.pak': 'application/x-pak',
    '.par2': 'application/x-par2',
    '.pas': 'text/x-pascal',
    '.patch': 'text/x-patch',
    '.pbm': 'image/x-portable-bitmap',
    '.pcd': 'image/x-photo-cd',
    '.pcf': 'application/x-cisco-vpn-settings',
    '.pcf.gz': 'application/x-font-pcf',
    '.pcf.z': 'application/x-font-pcf',
    '.pcl': 'application/vnd.hp-pcl',
    '.pcx': 'image/x-pcx',
    '.pdb': 'chemical/x-pdb',
    '.pdc': 'application/x-aportisdoc',
    '.pdf': 'application/pdf',
    '.pdf.bz2': 'application/x-bzpdf',
    '.pdf.gz': 'application/x-gzpdf',
    '.pef': 'image/x-pentax-pef',
    '.pem': 'application/x-x509-ca-cert',
    '.perl': 'application/x-perl',
    '.pfa': 'application/x-font-type1',
    '.pfb': 'application/x-font-type1',
    '.pfx': 'application/x-pkcs12',
    '.pgm': 'image/x-portable-graymap',
    '.pgn': 'application/x-chess-pgn',
    '.pgp': 'application/pgp-encrypted',
    '.php': 'application/x-php',
    '.php3': 'application/x-php',
    '.php4': 'application/x-php',
    '.pict': 'image/x-pict',
    '.pict1': 'image/x-pict',
    '.pict2': 'image/x-pict',
    '.pickle': 'application/python-pickle',
    '.pk': 'application/x-tex-pk',
    '.pkipath': 'application/pkix-pkipath',
    '.pkr': 'application/pgp-keys',
    '.pl': 'application/x-perl',
    '.pla': 'audio/x-iriver-pla',
    '.pln': 'application/x-planperfect',
    '.pls': 'audio/x-scpls',
    '.pm': 'application/x-perl',
    '.png': 'image/png',
    '.pnm': 'image/x-portable-anymap',
    '.pntg': 'image/x-macpaint',
    '.po': 'text/x-gettext-translation',
    '.por': 'application/x-spss-por',
    '.pot': 'text/x-gettext-translation-template',
    '.ppm': 'image/x-portable-pixmap',
    '.pps': 'application/vnd.ms-powerpoint',
    '.ppt': 'application/vnd.ms-powerpoint',
    '.pptm': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.ppz': 'application/vnd.ms-powerpoint',
    '.prc': 'application/x-palm-database',
    '.ps': 'application/postscript',
    '.ps.bz2': 'application/x-bzpostscript',
    '.ps.gz': 'application/x-gzpostscript',
    '.psd': 'image/vnd.adobe.photoshop',
    '.psf': 'audio/x-psf',
    '.psf.gz': 'application/x-gz-font-linux-psf',
    '.psflib': 'audio/x-psflib',
    '.psid': 'audio/prs.sid',
    '.psw': 'application/x-pocket-word',
    '.pw': 'application/x-pw',
    '.py': 'text/x-python',
    '.pyc': 'application/x-python-bytecode',
    '.pyo': 'application/x-python-bytecode',
    '.qif': 'image/x-quicktime',
    '.qt': 'video/quicktime',
    '.qtif': 'image/x-quicktime',
    '.qtl': 'application/x-quicktime-media-link',
    '.qtvr': 'video/quicktime',
    '.ra': 'audio/vnd.rn-realaudio',
    '.raf': 'image/x-fuji-raf',
    '.ram': 'application/ram',
    '.rar': 'application/x-rar',
    '.ras': 'image/x-cmu-raster',
    '.raw': 'image/x-panasonic-raw',
    '.rax': 'audio/vnd.rn-realaudio',
    '.rb': 'application/x-ruby',
    '.rdf': 'application/rdf+xml',
    '.rdfs': 'application/rdf+xml',
    '.reg': 'text/x-ms-regedit',
    '.rej': 'application/x-reject',
    '.rgb': 'image/x-rgb',
    '.rle': 'image/rle',
    '.rm': 'application/vnd.rn-realmedia',
    '.rmj': 'application/vnd.rn-realmedia',
    '.rmm': 'application/vnd.rn-realmedia',
    '.rms': 'application/vnd.rn-realmedia',
    '.rmvb': 'application/vnd.rn-realmedia',
    '.rmx': 'application/vnd.rn-realmedia',
    '.roff': 'text/troff',
    '.rp': 'image/vnd.rn-realpix',
    '.rpm': 'application/x-rpm',
    '.rss': 'application/rss+xml',
    '.rt': 'text/vnd.rn-realtext',
    '.rtf': 'application/rtf',
    '.rtx': 'text/richtext',
    '.rv': 'video/vnd.rn-realvideo',
    '.rvx': 'video/vnd.rn-realvideo',
    '.s3m': 'audio/x-s3m',
    '.sam': 'application/x-amipro',
    '.sami': 'application/x-sami',
    '.sav': 'application/x-spss-sav',
    '.scm': 'text/x-scheme',
    '.sda': 'application/vnd.stardivision.draw',
    '.sdc': 'application/vnd.stardivision.calc',
    '.sdd': 'application/vnd.stardivision.impress',
    '.sdp': 'application/sdp',
    '.sds': 'application/vnd.stardivision.chart',
    '.sdw': 'application/vnd.stardivision.writer',
    '.sgf': 'application/x-go-sgf',
    '.sgi': 'image/x-sgi',
    '.sgl': 'application/vnd.stardivision.writer',
    '.sgm': 'text/sgml',
    '.sgml': 'text/sgml',
    '.sh': 'application/x-shellscript',
    '.shar': 'application/x-shar',
    '.shn': 'application/x-shorten',
    '.siag': 'application/x-siag',
    '.sid': 'audio/prs.sid',
    '.sik': 'application/x-trash',
    '.sis': 'application/vnd.symbian.install',
    '.sisx': 'x-epoc/x-sisx-app',
    '.sit': 'application/x-stuffit',
    '.siv': 'application/sieve',
    '.sk': 'image/x-skencil',
    '.sk1': 'image/x-skencil',
    '.skr': 'application/pgp-keys',
    '.slk': 'text/spreadsheet',
    '.smaf': 'application/x-smaf',
    '.smc': 'application/x-snes-rom',
    '.smd': 'application/vnd.stardivision.mail',
    '.smf': 'application/vnd.stardivision.math',
    '.smi': 'application/x-sami',
    '.smil': 'application/smil',
    '.sml': 'application/smil',
    '.sms': 'application/x-sms-rom',
    '.snd': 'audio/basic',
    '.so': 'application/x-sharedlib',
    '.spc': 'application/x-pkcs7-certificates',
    '.spd': 'application/x-font-speedo',
    '.spec': 'text/x-rpm-spec',
    '.spl': 'application/x-shockwave-flash',
    '.spx': 'audio/x-speex',
    '.sql': 'text/x-sql',
    '.sr2': 'image/x-sony-sr2',
    '.src': 'application/x-wais-source',
    '.srf': 'image/x-sony-srf',
    '.srt': 'application/x-subrip',
    '.ssa': 'text/x-ssa',
    '.stc': 'application/vnd.sun.xml.calc.template',
    '.std': 'application/vnd.sun.xml.draw.template',
    '.sti': 'application/vnd.sun.xml.impress.template',
    '.stm': 'audio/x-stm',
    '.stw': 'application/vnd.sun.xml.writer.template',
    '.sty': 'text/x-tex',
    '.sub': 'text/x-subviewer',
    '.sun': 'image/x-sun-raster',
    '.sv4cpio': 'application/x-sv4cpio',
    '.sv4crc': 'application/x-sv4crc',
    '.svg': 'image/svg+xml',
    '.svgz': 'image/svg+xml-compressed',
    '.swf': 'application/x-shockwave-flash',
    '.sxc': 'application/vnd.sun.xml.calc',
    '.sxd': 'application/vnd.sun.xml.draw',
    '.sxg': 'application/vnd.sun.xml.writer.global',
    '.sxi': 'application/vnd.sun.xml.impress',
    '.sxm': 'application/vnd.sun.xml.math',
    '.sxw': 'application/vnd.sun.xml.writer',
    '.sylk': 'text/spreadsheet',
    '.t': 'text/troff',
    '.t2t': 'text/x-txt2tags',
    '.tar': 'application/x-tar',
    '.tar.bz': 'application/x-bzip-compressed-tar',
    '.tar.bz2': 'application/x-bzip-compressed-tar',
    '.tar.gz': 'application/x-compressed-tar',
    '.tar.lzma': 'application/x-lzma-compressed-tar',
    '.tar.lzo': 'application/x-tzo',
    '.tar.xz': 'application/x-xz-compressed-tar',
    '.tar.z': 'application/x-tarz',
    '.tbz': 'application/x-bzip-compressed-tar',
    '.tbz2': 'application/x-bzip-compressed-tar',
    '.tcl': 'text/x-tcl',
    '.tex': 'text/x-tex',
    '.texi': 'text/x-texinfo',
    '.texinfo': 'text/x-texinfo',
    '.tga': 'image/x-tga',
    '.tgz': 'application/x-compressed-tar',
    '.theme': 'application/x-theme',
    '.themepack': 'application/x-windows-themepack',
    '.tif': 'image/tiff',
    '.tiff': 'image/tiff',
    '.tk': 'text/x-tcl',
    '.tlz': 'application/x-lzma-compressed-tar',
    '.tnef': 'application/vnd.ms-tnef',
    '.tnf': 'application/vnd.ms-tnef',
    '.toc': 'application/x-cdrdao-toc',
    '.torrent': 'application/x-bittorrent',
    '.tpic': 'image/x-tga',
    '.tr': 'text/troff',
    '.ts': 'video/mp2t',
    '.tsv': 'text/tab-separated-values',
    '.tta': 'audio/x-tta',
    '.ttc': 'application/x-font-ttf',
    '.ttf': 'application/x-font-ttf',
    '.ttx': 'application/x-font-ttx',
    '.txt': 'text/plain',
    '.txz': 'application/x-xz-compressed-tar',
    '.tzo': 'application/x-tzo',
    '.ufraw': 'application/x-ufraw',
    '.ui': 'application/x-designer',
    '.uil': 'text/x-uil',
    '.ult': 'audio/x-mod',
    '.uni': 'audio/x-mod',
    '.uri': 'text/x-uri',
    '.url': 'text/x-uri',
    '.ustar': 'application/x-ustar',
    '.vala': 'text/x-vala',
    '.vapi': 'text/x-vala',
    '.vcf': 'text/directory',
    '.vcs': 'text/calendar',
    '.vct': 'text/directory',
    '.vda': 'image/x-tga',
    '.vhd': 'text/x-vhdl',
    '.vhdl': 'text/x-vhdl',
    '.viv': 'video/vivo',
    '.vivo': 'video/vivo',
    '.vlc': 'audio/x-mpegurl',
    '.vob': 'video/mpeg',
    '.voc': 'audio/x-voc',
    '.vor': 'application/vnd.stardivision.writer',
    '.vst': 'image/x-tga',
    '.wav': 'audio/x-wav',
    '.wax': 'audio/x-ms-asx',
    '.wb1': 'application/x-quattropro',
    '.wb2': 'application/x-quattropro',
    '.wb3': 'application/x-quattropro',
    '.wbmp': 'image/vnd.wap.wbmp',
    '.wcm': 'application/vnd.ms-works',
    '.wdb': 'application/vnd.ms-works',
    '.webm': 'video/webm',
    '.wk1': 'application/vnd.lotus-1-2-3',
    '.wk3': 'application/vnd.lotus-1-2-3',
    '.wk4': 'application/vnd.lotus-1-2-3',
    '.wks': 'application/vnd.ms-works',
    '.wma': 'audio/x-ms-wma',
    '.wmf': 'image/x-wmf',
    '.wml': 'text/vnd.wap.wml',
    '.wmls': 'text/vnd.wap.wmlscript',
    '.wmv': 'video/x-ms-wmv',
    '.wmx': 'audio/x-ms-asx',
    '.wp': 'application/vnd.wordperfect',
    '.wp4': 'application/vnd.wordperfect',
    '.wp5': 'application/vnd.wordperfect',
    '.wp6': 'application/vnd.wordperfect',
    '.wpd': 'application/vnd.wordperfect',
    '.wpg': 'application/x-wpg',
    '.wpl': 'application/vnd.ms-wpl',
    '.wpp': 'application/vnd.wordperfect',
    '.wps': 'application/vnd.ms-works',
    '.wri': 'application/x-mswrite',
    '.wrl': 'model/vrml',
    '.wv': 'audio/x-wavpack',
    '.wvc': 'audio/x-wavpack-correction',
    '.wvp': 'audio/x-wavpack',
    '.wvx': 'audio/x-ms-asx',
    '.x3f': 'image/x-sigma-x3f',
    '.xac': 'application/x-gnucash',
    '.xbel': 'application/x-xbel',
    '.xbl': 'application/xml',
    '.xbm': 'image/x-xbitmap',
    '.xcf': 'image/x-xcf',
    '.xcf.bz2': 'image/x-compressed-xcf',
    '.xcf.gz': 'image/x-compressed-xcf',
    '.xhtml': 'application/xhtml+xml',
    '.xi': 'audio/x-xi',
    '.xla': 'application/vnd.ms-excel',
    '.xlc': 'application/vnd.ms-excel',
    '.xld': 'application/vnd.ms-excel',
    '.xlf': 'application/x-xliff',
    '.xliff': 'application/x-xliff',
    '.xll': 'application/vnd.ms-excel',
    '.xlm': 'application/vnd.ms-excel',
    '.xls': 'application/vnd.ms-excel',
    '.xlsm': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.xlt': 'application/vnd.ms-excel',
    '.xlw': 'application/vnd.ms-excel',
    '.xm': 'audio/x-xm',
    '.xmf': 'audio/x-xmf',
    '.xmi': 'text/x-xmi',
    '.xml': 'application/xml',
    '.xpm': 'image/x-xpixmap',
    '.xps': 'application/vnd.ms-xpsdocument',
    '.xsl': 'application/xml',
    '.xslfo': 'text/x-xslfo',
    '.xslt': 'application/xml',
    '.xspf': 'application/xspf+xml',
    '.xul': 'application/vnd.mozilla.xul+xml',
    '.xwd': 'image/x-xwindowdump',
    '.xyz': 'chemical/x-pdb',
    '.xz': 'application/x-xz',
    '.w2p': 'application/w2p',
    '.z': 'application/x-compress',
    '.zabw': 'application/x-abiword',
    '.zip': 'application/zip',
    '.zoo': 'application/x-zoo',
  };
  var app = Router(notFoundHandler:(Request request) async{
    String urlPath = request.url.path;
    String filePath = "$publicPath$urlPath";
    Map<String, /* String | List<String> */ Object>? headers = {};
    String Content_Type = CONTENT_TYPE[".${filePath.split('.')[filePath.split('.').length - 1]}"]??"";
    if (Content_Type.isNotEmpty){
      headers.addAll({"Content-Type": Content_Type});
    }
    if (webFiles.indexOf(filePath) >= 0){
      return Response.ok((await rootBundle.load(filePath)).buffer.asUint8List(),headers: headers);
    }
    return Router.routeNotFound;
  });

  /**
   * 解析 m3u8文件 并将数据本地化
   * cacheType  使用的缓存类型  ‘temp’：当前播放使用的缓存位置  ‘cache’：系统缓存视频使用的缓存未知 ‘temp_cache’：播放的同时对数据进行缓存
   * m3u8Id     当前视频数据的唯一值
   * m3u8Url    需要解析的 m3u8数据文件
   *
   * cacheType 使用方法
   *    ‘temp’：           首先在‘cache’位置获取数据  不存在则在‘temp’位置获取数据 不存在则直接从网络位置获取
   *    ‘cache’：          首先在‘cache’位置获取数据  不存在则在‘temp’位置获取数据 不存在则直接从网络位置获取 存在则将数据存入cache相应位置
   *    ‘temp_cache’：     首先在‘cache’位置获取数据  不存在则在‘temp’位置获取数据 不存在则直接从网络位置获取 存在则将数据存入cache相应位置
   *
   */
  app.get('/parser/<cacheType>/<m3u8Id>/<m3u8Url>',
      (Request request, String cacheType, String m3u8Id, String m3u8Url) async {
        m3u8Url = Uri.decodeComponent(m3u8Url);
        print("m3u8Url:---->$m3u8Url");
    M3u8TempPoint m3u8tempPoint = M3u8TempPoint.creator(m3u8Id);
    M3u8CachePoint m3u8CachePoint = await M3u8CachePoint.creator(m3u8Id);

    String returnValue = "";
    // 解析m3u8文件 并重新在本地完成
    switch (cacheType) {
      case 'temp':
        {
          String? m3u8Value = (await m3u8CachePoint.getM3u8Data(m3u8Url));
          if (null != m3u8Value) {
            // cache 缓存 存在
            returnValue =
                _m3u8FileParse(baseUrl, cacheType, m3u8Id, m3u8Url, m3u8Value);
          } else {
            // cache 缓存不存在 取temp 缓存
            String m3u8Value = (await m3u8tempPoint.getM3u8Data(m3u8Url))!;
            returnValue =
                _m3u8FileParse(baseUrl, cacheType, m3u8Id, m3u8Url, m3u8Value);
          }
        }
        break;
      case 'cache':
        {
          String? m3u8Value = (await m3u8CachePoint.getM3u8Data(m3u8Url));
          if (null != m3u8Value) {
            // cache 缓存 存在
            returnValue =
                _m3u8FileParse(baseUrl, cacheType, m3u8Id, m3u8Url, m3u8Value);
          } else {
            // cache 缓存不存在 取temp 缓存
            String m3u8Value = (await m3u8tempPoint.getM3u8Data(m3u8Url))!;
            returnValue =
                _m3u8FileParse(baseUrl, cacheType, m3u8Id, m3u8Url, m3u8Value);
            m3u8CachePoint.setM3u8Data(m3u8Url, m3u8Value);
          }
        }
        break;
      case 'temp_cache':
        {
          String? m3u8Value = (await m3u8CachePoint.getM3u8Data(m3u8Url));
          if (null != m3u8Value) {
            // cache 缓存 存在
            returnValue =
                _m3u8FileParse(baseUrl, cacheType, m3u8Id, m3u8Url, m3u8Value);
          } else {
            // cache 缓存不存在 取temp 缓存
            String m3u8Value = (await m3u8tempPoint.getM3u8Data(m3u8Url))!;
            returnValue =
                _m3u8FileParse(baseUrl, cacheType, m3u8Id, m3u8Url, m3u8Value);
            m3u8CachePoint.setM3u8Data(m3u8Url, m3u8Value);
          }
        }
        break;
    }
    List<String> tsList = returnValue.split('\n').where((element) => element.endsWith('.ts')).toList();
    if (tsList.isNotEmpty){
      M3u8PointIsolate m3u8pointIsolate = M3u8PointIsolate(m3u8Id,tsList);
      IsolateComputeReturn isolateComputeReturn = await IsolateUtil.isolateCompute(m3u8pointIsolate);
      LocalM3u8Server._isolateMap.addAll(<String,Isolate>{
        m3u8Id: isolateComputeReturn.isolate
      });
    }
    Map<String, /* String | List<String> */ Object>? headers = {};
    String Content_Type = CONTENT_TYPE[".m3u8"]??"";
    if (Content_Type.isNotEmpty){
      headers.addAll({"Content-Type": Content_Type});
    }
    List<int> intList =  utf8.encode(returnValue);
    return Response.ok(intList,headers: headers);
  });

  /**
   * 解析 m3u8文件 并将数据本地化
   * cacheType  使用的缓存类型  ‘temp’：当前播放使用的缓存位置  ‘cache’：系统缓存视频使用的缓存未知
   * m3u8Id     当前视频数据的唯一值
   * keyUrl     key文件地址
   *
   */
  app.get('/key/<cacheType>/<m3u8Id>/<keyUrl>',
      (Request request, String cacheType, String m3u8Id, String keyUrl) async {
        keyUrl = Uri.decodeComponent(keyUrl);
        print("keyUrl:---->$keyUrl");
    M3u8TempPoint m3u8tempPoint = M3u8TempPoint.creator(m3u8Id);
    M3u8CachePoint m3u8CachePoint = await M3u8CachePoint.creator(m3u8Id);

    String returnValue = "";
    // 获取 key文件 或缓存 或直接网络获取
    switch (cacheType) {
      case 'temp':
        {
          String? keyValue = (await m3u8CachePoint.getKeyData(keyUrl));
          if (null != keyValue) {
            // cache 缓存 存在
            returnValue = keyValue;
          } else {
            // cache 缓存不存在 取temp 缓存
            String keyValue = (await m3u8tempPoint.getKeyData(keyUrl))!;
            returnValue = keyValue;
          }
        }
        break;
      case 'cache':
        {
          String? keyValue = (await m3u8CachePoint.getKeyData(keyUrl));
          if (null != keyValue) {
            // cache 缓存 存在
            returnValue = keyValue;
          } else {
            // cache 缓存不存在 取temp 缓存
            String keyValue = (await m3u8tempPoint.getKeyData(keyUrl))!;
            returnValue = keyValue;
            m3u8CachePoint.setKeyData(keyUrl, keyValue);
          }
        }
        break;
      case 'temp_cache':
        {
          String? keyValue = (await m3u8CachePoint.getKeyData(keyUrl));
          if (null != keyValue) {
            // cache 缓存 存在
            returnValue = keyValue;
          } else {
            // cache 缓存不存在 取temp 缓存
            String keyValue = (await m3u8tempPoint.getKeyData(keyUrl))!;
            returnValue = keyValue;
            m3u8CachePoint.setKeyData(keyUrl, keyValue);
          }
        }
        break;
    }
    return Response.ok(utf8.encode(returnValue));
  });

  /**
   * 解析 m3u8文件 并将数据本地化
   * cacheType  使用的缓存类型  ‘temp’：当前播放使用的缓存位置  ‘cache’：系统缓存视频使用的缓存未知
   * m3u8Id     当前视频数据的唯一值
   * tsUrl      tsUrl文件地址
   *
   */
  app.get('/ts/<cacheType>/<m3u8Id>/<tsUrl>',
          (Request request, String cacheType, String m3u8Id, String tsUrl) async {
        tsUrl = Uri.decodeComponent(tsUrl);
        M3u8TempPoint m3u8tempPoint = M3u8TempPoint.creator(m3u8Id);
        M3u8CachePoint m3u8CachePoint = await M3u8CachePoint.creator(m3u8Id);

        String cache = "";
        String returnValue = "";
        // 获取 key文件 或缓存 或直接网络获取
        switch (cacheType) {
          case 'temp':
            {
              String? tsValue = (await m3u8CachePoint.getTsData(tsUrl));
              if (null != tsValue) {
                // cache 缓存 存在
                returnValue = tsValue;
                cache = "---cache";
              } else {
                // cache 缓存不存在 取temp 缓存
                String tsValue = (await m3u8tempPoint.getTsData(tsUrl))!;
                returnValue = tsValue;
              }
            }
            break;
          case 'cache':
            {
              String? tsValue = (await m3u8CachePoint.getTsData(tsUrl));
              if (null != tsValue) {
                // cache 缓存 存在
                returnValue = tsValue;
                cache = "---cache";
              } else {
                // cache 缓存不存在 取temp 缓存
                String tsValue = (await m3u8tempPoint.getTsData(tsUrl))!;
                returnValue = tsValue;
                m3u8CachePoint.setTsData(tsUrl, tsValue);
              }
            }
            break;
          case 'temp_cache':
            {
              String? tsValue = (await m3u8CachePoint.getTsData(tsUrl));
              if (null != tsValue) {
                // cache 缓存 存在
                returnValue = tsValue;
                cache = "---cache";
              } else {
                // cache 缓存不存在 取temp 缓存
                String tsValue = (await m3u8tempPoint.getTsData(tsUrl))!;
                returnValue = tsValue;
                m3u8CachePoint.setTsData(tsUrl, tsValue);
              }
            }
            break;
        }
        Map<String, /* String | List<String> */ Object>? headers = {};
        String Content_Type = CONTENT_TYPE[".ts"]??"";
        if (Content_Type.isNotEmpty){
          headers.addAll({"Content-Type": Content_Type});
        }
        print("tsUrl:---->$tsUrl$cache");
        return Response.ok(Uint8List.fromList(returnValue.codeUnits),headers: headers);
      });


  /**
   * 播放列表页面
   * title      标题
   * urlDate    地址列表
   *
   */
  app.get('/webPlayer/<title>/<urlDate>',
          (Request request, String title, String urlDate) async {
        title=Uri.decodeComponent(title);
        urlDate= (await VideoModelCache.appConfigJListKeyTryCacheManager.getString(VideoModelCache.APP_CONFIG_JLIST_KEY_TRY_CACHE)??"");
        Map<String, /* String | List<String> */ Object>? headers = {};
        String Content_Type = CONTENT_TYPE[".html"]??"";
        if (Content_Type.isNotEmpty){
          headers.addAll({"Content-Type": Content_Type});
        }
        // print("title:---->$title");
        List<String> ddItemList = urlDate.split("#");
        String aTemp = ddItemList
            .where((ddItem) => ddItem.isNotEmpty)
            .toList()
            .asMap()
            .entries
            .map((ddItemEntry) {
          int index = ddItemEntry.key;
          String ddItem = ddItemEntry.value;
          if (ddItem.endsWith(".m3u8")) {
            List<String> ddSplit = ddItem.split("\$");
            ddItem =
            "${ddSplit.length > 1 ? ddSplit[0] : "第${index + 1}集"}\$${ddSplit[ddSplit.length - 1]}\$ckplayer";
          }
          if (ddItem.endsWith(".html")) {
            List<String> ddSplit = ddItem.split("\$");
            ddItem =
            "${ddSplit.length > 1 ? ddSplit[0] : "第${index + 1}集"}\$${ddSplit[ddSplit.length - 1]}\$html";
          }
          List<String> ddList = ddItem.split("\$");
          return "<a target=\"_blank\" href=\"${baseUrl+"/player.html?url="+Uri.encodeComponent(ddList.length >= 2 ? ddList[1].trim() : "")}\">${index + 1}</a><br />";
        }).toList().join();
        String returnValue = "<!DOCTYPE html> <html ><head><meta charset=\"UTF-8\" /><title>$title</title></head><body>$aTemp</body></html>";
        // print(returnValue);
        return Response.ok(utf8.encode(returnValue),headers: headers);
      });

  return await shelf_io.serve(app, address, port);
}

/**
 * 判断当前ts 是否为广告数据
 */
bool _isAd(String tsLine){
  return LocalM3u8Server._AD_DOMAIN.fold<bool>(false, (previousValue, domain) {
    return previousValue || (tsLine.lastIndexOf(domain) >= 0);
  });
}

String _m3u8FileParse(String baseUrl, String cacheType, String m3u8Id,
    String m3u8Url, String m3u8Value) {
  Uri uri = Uri.parse(m3u8Url);
  Map<String,dynamic> contextMap = <String,dynamic>{
    "m3u8Data":<String>[],
    "targetduration-max":0,
    "targetduration-index":0,
    "last-line":"",
    "ext-x-discontinuity":"",
    "ext-x-key":"",
    "extinf":"",
  };
  return m3u8Value.split("\n")
  // 尝试去掉其中广告
      .fold<Map<String,dynamic>>(contextMap, (previousValue, line) {
    String _line = line;
    if (_line.lastIndexOf("?") >= 0){
      _line = _line.substring(0,_line.lastIndexOf("?"));
    }
    // 最大的媒体段时间长（秒） 则 缓存指针
    if (_line.startsWith('#EXT-X-TARGETDURATION:')) {
      previousValue['targetduration-index'] = (previousValue['m3u8Data'] as List<String>).length;
    }
    // 如果是切换信息 则 缓存 并直接处理下一行
    if (_line.startsWith('#EXT-X-DISCONTINUITY')) {
      previousValue['ext-x-discontinuity'] = line;
      return previousValue;
    }
    // 如果是key信息 则 缓存 并直接处理下一行
    if (_line.startsWith('#EXT-X-KEY')) {
      previousValue['ext-x-key'] = line;
      return previousValue;
    }
    // 如果是ts扩展信息 则 缓存 并直接处理下一行
    if (_line.startsWith('#EXTINF')) {
      double ds = double.parse(line.split(":").last.replaceFirst(",", ""));
      if ((previousValue['targetduration-max'] as int) < ds){
        previousValue['targetduration-max'] =  ((ds) + 1)~/1;
        (previousValue['m3u8Data'] as List<String>)[previousValue['targetduration-index'] as int] = "#EXT-X-TARGETDURATION:${previousValue['targetduration-max']}";
      }
      previousValue['extinf'] = line;
      return previousValue;
    }
    // 如果当前行为 ts 并且 是广告数据 则 删除之前的ts扩展数据缓存 并且直接处理下一行
    if (_line.trim().endsWith(".ts") && _isAd(_line) ) {
      previousValue['ext-x-discontinuity'] = "";
      previousValue['ext-x-key'] = "";
      previousValue['extinf'] = "";
      return previousValue;
    }
    // 不是 #EXTINF 行数据 和 ts 非广告数据将会通过上面的过滤

    // 如果 当前行 包含 上下文切换数据 则 将缓存数据移动到m3u8数据中
    if((previousValue['ext-x-discontinuity'] as String).isNotEmpty ){
      String _last = previousValue['last-line'] as String;
      if (_last.lastIndexOf("?") >= 0){
        _last = _last.substring(0,_last.lastIndexOf("?"));
      }
      if (_last.trim().endsWith(".ts")) {
        (previousValue['m3u8Data'] as List<String>).add(previousValue['ext-x-discontinuity']);
      }
      previousValue['ext-x-discontinuity'] = "";
    }

    // 如果 当前行 包含 key数据 则 将缓存数据移动到m3u8数据中
    if((previousValue['ext-x-key'] as String).isNotEmpty){
      (previousValue['m3u8Data'] as List<String>).add(previousValue['ext-x-key']);
      previousValue['ext-x-key'] = "";
    }

    // 如果 当前行 包含 extinf ts扩展数据 则 将缓存数据移动到m3u8数据中
    if((previousValue['extinf'] as String).isNotEmpty){
      (previousValue['m3u8Data'] as List<String>).add(previousValue['extinf']);
      previousValue['extinf'] = "";
    }
    // 将当前行添加进 m3u8数据中
    (previousValue['m3u8Data'] as List<String>).add(line);
    previousValue['last-line'] = line;
    return previousValue;
  })['m3u8Data'].map((String line) {
    if (line.startsWith("#EXT-X-KEY")&& line.lastIndexOf("URI=") >= 0) {
      List<String> lineSplit =
          line.replaceAll(line.substring(line.length - 1), "").split("URI=");
      String keyUrl = lineSplit.last;

      String _localKeyUrl =
          "$baseUrl/key/$cacheType/$m3u8Id/${Uri.encodeComponent(_urlAutoCompletion(uri, keyUrl))}";
      return line.replaceFirst(keyUrl, _localKeyUrl);
    }
    String _line = line;
    if (_line.lastIndexOf("?") >= 0){
      _line = _line.substring(0,_line.lastIndexOf("?"));
    }
    if (_line.trim().endsWith(".ts")) {
      return "$baseUrl/ts/$cacheType/$m3u8Id/${Uri.encodeComponent(_urlAutoCompletion(uri, line))}";
    }
    if (_line.trim().endsWith(".m3u8")) {
      return "$baseUrl/parser/$cacheType/$m3u8Id/${Uri.encodeComponent(_urlAutoCompletion(uri, line))}";
    }
    return line;
  }).join("\n");
}

// Url 进行补全
String _urlAutoCompletion(Uri uriBase, String url) {
  if (url.startsWith("http")) {
    return url;
  }
  if (url.startsWith("/")) {
    return "${uriBase.scheme}://${uriBase.host}${uriBase.port == 80 ? '' : ':${uriBase.port}'}${url}";
  }
  return "${uriBase.scheme}://${uriBase.host}${uriBase.port == 80 ? '' : ':${uriBase.port}'}/${uriBase.pathSegments.sublist(0, uriBase.pathSegments.length - 1).join("/")}/${url}";
}
