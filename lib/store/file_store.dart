// 文件缓存管理
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
class FileStore {
  static FileStore? _fileStore;
  final Directory tempDir;

  static Future<FileStore> doInit () async{
    if (FileStore._fileStore == null){
      WidgetsFlutterBinding.ensureInitialized();
      FileStore._fileStore = new FileStore._makeStore(tempDir : await getTemporaryDirectory());
    }
    return FileStore._fileStore!;
  }

  FileStore._makeStore({required this.tempDir });

  Future<String?> getTempString(String key) async{
    String dirPath = this.tempDir.path;
    File tempFile = File("$dirPath${Platform.pathSeparator}$key");
    if (tempFile.existsSync()) {
      return tempFile.readAsStringSync();
    }
    return null;
  }

  Future<File?> getTempFile(String key) async{
    String dirPath = this.tempDir.path;
    return File("$dirPath${Platform.pathSeparator}$key");
  }

  Future<void> setTempString ( String key, String? value ) async{
    if (null == value) {
      return;
    }
    String dirPath = this.tempDir.path;
    String tempFilePath = "$dirPath${Platform.pathSeparator}$key";
    File tempFile = File(tempFilePath);
    if (!tempFile.existsSync()) {
      if (!tempFile.parent.existsSync()) {
        tempFile.parent.createSync();
      }
      tempFile.createSync();
    }
    tempFile.writeAsStringSync(value);
  }

  Future<void> removeTemp(String key) async{
    String dirPath = this.tempDir.path;
    File tempFile = File("$dirPath${Platform.pathSeparator}$key");
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  }

  Future<void> clearAllTemp(String baseKey) async {
    for (String key in await getTempKeys(baseKey)) {
      removeTemp(key);
    }
  }

  Future<Set<String>> getTempKeys(String baseKey) async {
    String dirPath = this.tempDir.path;
    String path = "$dirPath${Platform.pathSeparator}$baseKey";
    FileSystemEntity baseFile ;
    if (FileSystemEntity.isDirectorySync(path)) {
      baseFile = Directory(path);
    } else{
      baseFile = File(path);
    }
    List<String> filesPath = getFilePath(baseFile);
    return filesPath.map((element) => element.replaceFirst("$dirPath${Platform.pathSeparator}", "")).toSet();
  }

  List<String> getFilePath( FileSystemEntity keyFile ){
    List<String> initList = <String>[];
    if (keyFile is Directory){
      List<FileSystemEntity> children = keyFile.listSync();
      for (FileSystemEntity child in children) {
        initList.addAll(getFilePath(child));
      }
    }

    if (keyFile is File){
      initList.add(keyFile.path);
    }

    return initList;
  }

  Future<List<String?>> getTempValues(String baseKey) async {
    Set<String> keySet = await getTempKeys(baseKey);
    return Future.wait<String?>(keySet.map((key) async => await getTempString(key)));
  }

  Future<List<File?>> getTempFiles(String baseKey) async {
    Set<String> keySet = await getTempKeys(baseKey);
    return Future.wait<File?>(keySet.map((key) async => await getTempFile(key)));
  }

  Future<void> delTempValues(String baseKey) async {
    Set<String> keySet = await getTempKeys(baseKey);
    keySet
        .forEach(
            (key) async { await removeTemp(key);}
            );
  }

}

class FileCacheManager{

  final FileStore _fileStore;
  final String _baseKey;
  final String separator;

  FileCacheManager(this._fileStore, this._baseKey, {this.separator:"-"});

  String _keyBuild( String baseKey, String cacheKey ) => "${baseKey}${this.separator}${cacheKey}";

  String _keyStartBuild( String baseKey ) => "${baseKey}${this.separator}";

  Future<void> delete(String cacheKey) => _fileStore.removeTemp(_keyBuild( this._baseKey, cacheKey));

  Future<void> clearAll() => _fileStore.clearAllTemp(_keyStartBuild( this._baseKey));

  Future<void> setString(String cacheKey, String? value) => this._fileStore.setTempString( _keyBuild( this._baseKey, cacheKey), value );

  Future<String?> getString( String cacheKey ) => this._fileStore.getTempString( _keyBuild( this._baseKey, cacheKey) );

  Future<File?> getFile( String cacheKey ) => this._fileStore.getTempFile( _keyBuild( this._baseKey, cacheKey) );

  Future<Set<String>> getBaseCacheKeys() => this._fileStore.getTempKeys( _keyStartBuild( this._baseKey) );

  Future<List<String?>> getBaseCacheValues() => this._fileStore.getTempValues( _keyStartBuild( this._baseKey) );

  Future<List<File?>> getBaseCacheFiles() => this._fileStore.getTempFiles( _keyStartBuild( this._baseKey) );

  Future<void> delBaseCacheValues() => this._fileStore.delTempValues( _keyStartBuild( this._baseKey) );

  Future<Set<String>> getTempCacheKeys( String cacheKey ) => this._fileStore.getTempKeys( _keyBuild( this._baseKey, cacheKey) );

  Future<List<String?>> getTempCacheValues( String cacheKey ) => this._fileStore.getTempValues( _keyBuild( this._baseKey, cacheKey) );

  Future<List<File?>> getTempCacheFiles( String cacheKey ) => this._fileStore.getTempFiles( _keyBuild( this._baseKey, cacheKey) );

  Future<void> delTempCacheValues( String cacheKey ) => this._fileStore.delTempValues( _keyBuild( this._baseKey, cacheKey) );

}