import 'package:open_m3u8_player/store/temp_store.dart';

class VideoModelCache {

  /** 视频详情 与 播放进度 缓存 */
  static const VIDEO_HISTORY_CACHE_KEY_TRY_CACHE =
      "video_history_cache_try_cache";
  static const VIDEO_CONTEXT_NAME_CACHE_KEY_TRY_CACHE =
      "video_context_name_cache_try_cache";
  static TempCacheManager tempHistoryCacheManager = TempCacheManager(TempStore.init(), "VideoHistoryCache");

  /** 搜索记录缓存 */
  static const SEARCH_CACHE_KEY_TRY_CACHE = "search_cache_try_cache";
  static TempCacheManager tempSearchBarHistoryCacheManager = TempCacheManager( TempStore.init(), "SearchCache");

  /** 数据源数据缓存 当前选中数据源缓存 */
  static const SOURCE_SITE_LIST_CACHE_KEY_TRY_CACHE = "source_site_list_cache_try_cache";
  static const SOURCE_SITE_CACHE_KEY_TRY_CACHE = "source_site_cache_try_cache";
  static TempCacheManager tempSourceSiteCacheManager = TempCacheManager( TempStore.init(), "SourceSiteCache");

  static const M3U8_CURRENT_POS_CACHE_KEY_TRY_CACHE = "m3u8_current_pos_cache_try_cache";
  static TempCacheManager m3u8CurrentPosCacheManager = TempCacheManager( TempStore.init(), "M3u8CurrentPosCache");

  static const APP_CONFIG_JLIST_KEY_TRY_CACHE = "app_config_jlist_key_try_cache";
  static TempCacheManager appConfigJListKeyTryCacheManager= TempCacheManager( TempStore.init(), "AppConfigJListKeyTryCache");
}
