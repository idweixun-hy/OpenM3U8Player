import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/pages/home/video_list.dart';
import 'package:open_m3u8_player/util/page_util.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  String wd = "";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, "");
        } else {
          query = "";
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    VideoModelCache.tempSearchBarHistoryCacheManager
        .getString(VideoModelCache.SEARCH_CACHE_KEY_TRY_CACHE)
        .then((String? value) {
      String querysTemp = "";
      if (null != value) {
        Set<String> querySet = Set<String>();
        String querys = value;
        querys.split("@")
          ..add(query.trim())
          ..forEach((qText) {
            if (qText.trim().isNotEmpty && !querySet.contains(qText)) {
              querysTemp = querysTemp.isEmpty
                  ? (qText)
                  : (querysTemp + "@" + qText.trim());
              querySet.add(qText);
            }
          });
      } else {
        querysTemp = query;
      }
      VideoModelCache.tempSearchBarHistoryCacheManager
          .setString(VideoModelCache.SEARCH_CACHE_KEY_TRY_CACHE, querysTemp);
    }).catchError((onError) {});

    return VideoList(
      wd: query,
      tId: "",
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Suggestions(setQuery: (qText) {
      query = qText;
    });
  }
}

class Suggestions extends StatefulWidget {
  final Function setQuery;

  Suggestions({Key? key, required this.setQuery}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SuggestionsState();
}


class _SuggestionsState extends State<Suggestions> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: VideoModelCache.tempSearchBarHistoryCacheManager
          .getString(VideoModelCache.SEARCH_CACHE_KEY_TRY_CACHE),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String? value = snapshot.data as String;
          if (null == value) {
            return Text("没有搜索记录");
          }
          String querys = value;
          return SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2, //主轴上子控件的间距
              runSpacing: 5, //交叉轴上子控件之间的间距(
              children: querys.split("@").map((qText) {
                return MaterialButton(
                  shape: PageUtil.shape,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text(qText),
                  onPressed: () {
                    widget.setQuery(qText);
                  },
                );
              }).toList()
                ..add(MaterialButton(
                  shape: PageUtil.shape,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text("清除搜索历史"),
                  onPressed: () {
                    VideoModelCache.tempSearchBarHistoryCacheManager.clearAll();
                    setState(() {});
                  },
                )),
            ),
          );
        }
        return Text("没有历史记录");
      },
    );
  }
}
