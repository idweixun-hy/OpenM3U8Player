import 'package:flutter/material.dart';
import 'package:open_m3u8_player/data/site_source_model.dart';
import 'package:open_m3u8_player/util/page_util.dart';

ShapeBorder shape = PageUtil.shape;

class RadioListRow extends StatefulWidget {
  final String groupValue;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<SiteSourceModel?>? sourceCheck;
  final ValueChanged<SiteSourceModel?>? sourceEdit;
  final ValueChanged<SiteSourceModel?>? sourceRemove;
  final SiteSourceModel siteSourceModel;

  const RadioListRow(
      {Key? key,
      required this.siteSourceModel,
      required this.groupValue,
      required this.onChanged, required this.sourceCheck, required this.sourceEdit, required this.sourceRemove})
      : super(key: key);

  @override
  State createState() => _RadioListRowState();
}

class _RadioListRowState extends State<RadioListRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  MediaQuery.of(context).size.width * 0.4,
          height: 50,
          color: Colors.black12,
          child: Center(
            child: RadioListTile<String>(
              value: widget.siteSourceModel.url!,
              title: Text(
                widget.siteSourceModel.name!,
                style: TextStyle(fontSize: 14),
              ),
              groupValue: widget.groupValue,
              onChanged: widget.onChanged,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: 50,
          color: widget.siteSourceModel.enable?? false ?Colors.green: Colors.red,
          child: Center(child: Text(widget.siteSourceModel.enable?? false ? "正常": "异常")),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 50,
          color: Colors.black12,
          child: Center(
              child: Row(
              children: [
                Expanded(
                  child: Center(
                      child: MaterialButton(
                        shape: shape,
                        color: Theme.of(context).textTheme.button!.color,
                        textColor: Colors.white,
                        child: new Text('检测'),
                        onPressed: () async {
                          widget.sourceCheck!(widget.siteSourceModel);
                        },
                      )
                  ),
                ),
                Expanded(
                  child: Center(
                      child: MaterialButton(
                        shape: shape,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: new Text('编辑'),
                        onPressed: () async {
                          widget.sourceEdit!(widget.siteSourceModel);
                          PageUtil.showAlertDialog(context,"功能建设中……");
                        },
                      )
                  ),
                ),
                Expanded(
                  child: Center(
                      child: MaterialButton(
                        shape: shape,
                        color: Colors.red,
                        textColor: Colors.white,
                        child: new Text('移除'),
                        onPressed: () async {
                          if (await PageUtil.showQuestionAlertDialog(context, "移除资源", "确定要移除资源吗？\n移除后不可恢复！")??false){
                            widget.sourceRemove!(widget.siteSourceModel);
                          }
                        },
                      )
                  ),
                )
              ],
            )
          ),
        ),
      ],
    );
  }
}
