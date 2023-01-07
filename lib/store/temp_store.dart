// 临时缓存管理
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TempStore {
  static TempStore? _tempStore;
  final Future<SharedPreferences> prefs ;

  factory TempStore.init (){
    if (TempStore._tempStore == null){
      WidgetsFlutterBinding.ensureInitialized();
      TempStore._tempStore = new TempStore._makeStore(prefs : SharedPreferences.getInstance());
    }
    return TempStore._tempStore!;
  }

  TempStore._makeStore({required this.prefs });

  Future<String?> getTempString(String key) async{
    return (await prefs) .getString(key);
  }

  Future<void> setTempString ( String key, String? value ) async{ (await prefs) .setString( key, value!);}

  Future<void> removeTemp(String key) async{
    (await prefs) .remove(key);
  }

  Future<void> clearAllTemp(String baseKey) async {
    Set<String> keySet = (await prefs) .getKeys();
    keySet.forEach((key) { 
      if (key.startsWith(baseKey))
        removeTemp(key);
    });
  }

  Future<Set<String>> getTempKeys(String baseKey) async {
    Set<String> keySet = (await prefs) .getKeys();
    return keySet.where((key) => key.startsWith(baseKey)).toSet();
  }

  Future<List<String?>> getTempValues(String baseKey) async {
    Set<String> keySet = (await prefs) .getKeys();
    return Future.wait<String?>(keySet.where((key) => key.startsWith(baseKey)).map((key) async => (await prefs) .getString(key)));
  }

  Future<void> delTempValues(String baseKey) async {
    Set<String> keySet = (await prefs) .getKeys();
    keySet
        .where((key) => key.startsWith(baseKey))
        .toList()
        .forEach(
            (key) async { await removeTemp(key);}
            );
  }

}

class TempCacheManager{

  final TempStore _tempStore;
  final String _baseKey;
  final String separator;

  TempCacheManager(this._tempStore, this._baseKey, {this.separator:"-"});

  String _keyBuild( String baseKey, String cacheKey ) => "${baseKey}${this.separator}${cacheKey}";

  String _keyStartBuild( String baseKey ) => "${baseKey}${this.separator}";

  Future<void> delete(String cacheKey) => _tempStore.removeTemp(_keyBuild( this._baseKey, cacheKey));

  Future<void> clearAll() => _tempStore.clearAllTemp(_keyStartBuild( this._baseKey));

  Future<void> setString(String cacheKey, String? value) => this._tempStore.setTempString( _keyBuild( this._baseKey, cacheKey), value );

  Future<String?> getString( String cacheKey ) => this._tempStore.getTempString( _keyBuild( this._baseKey, cacheKey) );

  Future<Set<String>> getBaseCacheKeys() => this._tempStore.getTempKeys( _keyStartBuild( this._baseKey) );

  Future<List<String?>> getBaseCacheValues() => this._tempStore.getTempValues( _keyStartBuild( this._baseKey) );

  Future<void> delBaseCacheValues() => this._tempStore.delTempValues( _keyStartBuild( this._baseKey) );

  Future<Set<String>> getTempCacheKeys( String cacheKey ) => this._tempStore.getTempKeys( _keyBuild( this._baseKey, cacheKey) );

  Future<List<String?>> getTempCacheValues( String cacheKey ) => this._tempStore.getTempValues( _keyBuild( this._baseKey, cacheKey) );

  Future<void> delTempCacheValues( String cacheKey ) => this._tempStore.delTempValues( _keyBuild( this._baseKey, cacheKey) );

}