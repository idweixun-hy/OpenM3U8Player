import 'package:flutter/material.dart';



class PageUtil{

  static ShapeBorder shape = const RoundedRectangleBorder(
      side: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(50)));

  static Future<bool?> showQuestionAlertDialog(BuildContext context, String title, String msg){
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(msg),
          ],
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text('确定'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        MaterialButton(
          child: Text('取消'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
    //显示对话框
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlertDialog(BuildContext context, String msg) {
    //设置对话框
    AlertDialog alert = AlertDialog(
      title: Text("提示"),
      content: Text(msg),
      actions: [
        //设置按钮
        MaterialButton(
          child: Text("确定"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    //显示对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
