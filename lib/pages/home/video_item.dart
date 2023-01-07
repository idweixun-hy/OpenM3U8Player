



import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/videomodel.dart';
import 'package:open_m3u8_player/pages/video_detail/index.dart';

class VideoItem extends StatelessWidget {

  final Size size;

  final String? imageSrc;

  final String videoTitle;

  final String? videoId;

  final VideoModel videoData;

  VideoItem(
      {Key? key,
        this.imageSrc,
        required this.videoTitle,
        this.videoId,
        required this.videoData, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VideoDetail(videoData: this.videoData, isLive: this.videoData.type == 'live',)),
        );
      },
      child: Center(
        child: Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15.0,
              bottom: 15.0,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: AspectRatio(
                      aspectRatio: 0.82, // 宽高比
                      child: CachedNetworkImage(
                        imageUrl: this.imageSrc!,
                        imageBuilder: (context, imageProvider) =>
                            Image(image: imageProvider, fit: BoxFit.fitHeight, width: size.width / 3,),
                        placeholder: (context, url) =>
                            Center(child:
                              Container(
                                alignment: Alignment.center,
                                child: SizedBox(
                                    width: size.width / 10,
                                    height: size.width / 10,
                                    child:CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Colors.black38)
                                    )
                                ),
                                width: size.width / 3,
                              )
                            ),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/fp.png",width: size.width / 3,),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 8, top: 2, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            this.videoTitle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            '${this.videoData.area} / ${this.videoData.type} / ${this.videoData.year} / ${this.videoData.lang}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            (this.videoData.des ?? "")
                                .replaceAll(RegExp(r"<\/?.+?\/?>"), ""),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        /*
        Column(
          children: <Widget>[
            Expanded(
              child: CachedNetworkImage(
                imageUrl: this.imageSrc!,
                imageBuilder: (context, imageProvider) =>
                    Image(image: imageProvider, fit: BoxFit.fitHeight),
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/fp.png"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: Text(
                this.videoTitle.length>12?this.videoTitle.substring(0,12)+"...":this.videoTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
        */
      ),
    );
  }
}
