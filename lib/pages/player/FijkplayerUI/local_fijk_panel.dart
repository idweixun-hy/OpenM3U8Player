import 'dart:async';
import 'dart:math';

import 'package:open_m3u8_player/data/videomodelcache.dart';
import 'package:open_m3u8_player/pages/player/dlna/DlnaDeviceList.dart';
import 'package:wakelock/wakelock.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget defaultFijkMovToast(
    double value, Stream<double> emitter) {
  return _FijkMovToast(value, emitter);
}

class _FijkMovToast extends StatefulWidget {
  final Stream<double> emitter;
  final double initial;

  _FijkMovToast(this.initial, this.emitter);

  @override
  _FijkMovToastState createState() => _FijkMovToastState();
}

class _FijkMovToastState extends State<_FijkMovToast> {
  double value = 0;
  StreamSubscription? subs;
  String movPercentage = '';

  @override
  void initState() {
    super.initState();
    value = widget.initial;
    subs = widget.emitter.listen((v) {
      if (v == -999){
        setState(() {
          movPercentage = "";
          value = 0;
        });
      }
      int numTag = v < 0 ? -1 : 1;
      // 用百分比计算出当前的秒数
      String currentSecond = DateUtil.formatDateMs(
        ( numTag * v ).toInt(),
        isUtc: true,
        format: 'HH:mm:ss',
      );
      String tage = "";
      if (v >= 0) {
        tage = '快进至：';
      } else {
        tage = '快退至：';
      }
      setState(() {
        movPercentage = '$tage$currentSecond';
        value = v;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return movPercentage.isEmpty
        ? Container( color: Color(0x00000000), )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Text(
              movPercentage,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
        );
  }
}

class SpeedSelect extends StatefulWidget{
  final ValueChanged<double> onSelectChanged;
  final Stream<bool> hideStuffStream;
  const SpeedSelect({Key? key, required this.onSelectChanged, required this.hideStuffStream}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SpeedSelectState();
}
class _SpeedSelectState extends State<SpeedSelect>{
  bool _hideSpeedStu = true;
  bool get hideSpeedStu => _hideSpeedStu;

  void set hideSpeedStu ( bool value ){
    if (_hideSpeedStu == value) return;
    _hideSpeedStu = value;

    if (!_hideSpeedStu) {
      this._overlayEntry = this._createOverlayEntry();
      Overlay.of(context)!.insert(this._overlayEntry!);
    } else {
      this._overlayEntry?.remove();
    }
  }
  double _speed = 1.0;

  OverlayEntry? _overlayEntry ;

  Map<String, double> speedList = {
    "2.0": 2.0,
    "1.8": 1.8,
    "1.5": 1.5,
    "1.2": 1.2,
    "1.0": 1.0,
    "0.5": 0.5,
  };

  Ink get _ink => Ink(
    padding: EdgeInsets.all(5),
    child: InkWell(
      onTap: () {
        setState(() {
          hideSpeedStu = !hideSpeedStu;
        });
      },
      child: Container(
        alignment: Alignment.center,
        width: 40,
        height: 30,
        child: Text(
          _speed.toString() + " X", style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF))
        ),
      ),
    ),
  );


  @override
  void initState() {
    super.initState();
    widget.hideStuffStream.listen((v) {
      setState(() {
        hideSpeedStu = hideSpeedStu || v;
      });
    });
  } // build 倍数列表
  List<Widget> _buildSpeedListWidget() {
    List<Widget> columnChild = [];
    speedList.forEach((String mapKey, double speedVals) {
      columnChild.add(
        Ink(
          child: InkWell(
            onTap: () {
              setState(() {
                hideSpeedStu = true;
              });
              if (_speed == speedVals) return null;
              setState(() {
                _speed = speedVals;
              });
              widget.onSelectChanged.call(speedVals);
            },
            child: Container(
              alignment: Alignment.center,
              width: 18,
              height: 12,
              child: Text(
                mapKey + " X",
                style: TextStyle(
                fontSize: 8,
                  color: _speed == speedVals ? Colors.blue : Colors.orange,
                ),
              ),
            ),
          ),
        ),
      );
      columnChild.add(
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Container(
            width: 50,
            height: 1,
            color: Colors.white54,
          ),
        ),
      );
    });
    columnChild.removeAt(columnChild.length - 1);
    return columnChild;
  }

  OverlayEntry _createOverlayEntry() {

    RenderBox? renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy - size.height * 4 + 30.0,
          width: size.width,
          child: Material(
            elevation: 4.0,
            color: Color(0x00000000),
            child: Container(
              alignment: Alignment.center,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _buildSpeedListWidget(),
              ),
            )
          ),
        )
    );
  }

  @override
  Widget build(BuildContext c) {
    return _ink;
  }

  @override
  void dispose() {
    super.dispose();
    this._overlayEntry?.remove();
  }
}

String _duration2String(Duration duration) {
  if (duration.inMilliseconds < 0) return "-: negtive";

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  int inHours = duration.inHours;
  return inHours > 0
      ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
      : "$twoDigitMinutes:$twoDigitSeconds";
}

class LocalFijkDataStatic {
  static String _fijkViewPanelVolume = "__fijkview_panel_init_volume";
  static String _fijkViewPanelBrightness = "__fijkview_panel_init_brightness";
  static String _fijkViewPanelSeekto = "__fijkview_panel_sekto_position";
}

FijkPanelWidgetBuilder localFijkPanel2Builder(
    {Key? key,
    final String title = "",
    required final String m3u8Url,
    final bool fill = false,
    final int duration = 4000,
    final bool doubleTap = true,
    final bool snapShot = false,
    final bool isLive = false,
    final VoidCallback? callDrawer,
    final VoidCallback? onBack}) {
  return (FijkPlayer player, FijkData data, BuildContext context, Size viewSize,
      Rect texturePos) {
    return _FijkPanel2(
      key: key,
      title: title,
      m3u8Url: m3u8Url,
      player: player,
      data: data,
      onBack: onBack,
      viewSize: viewSize,
      texPos: texturePos,
      fill: fill,
      doubleTap: doubleTap,
      snapShot: snapShot,
      hideDuration: duration,
      isLive: isLive
    );
  };
}

class _FijkPanel2 extends StatefulWidget {
  final String title;
  final String m3u8Url;
  final bool isLive;
  final FijkPlayer player;
  final FijkData data;
  final VoidCallback? onBack;
  final Size viewSize;
  final Rect texPos;
  final bool fill;
  final bool doubleTap;
  final bool snapShot;
  final int hideDuration;

  const _FijkPanel2(
      {Key? key,
      required this.title,
      required this.m3u8Url,
      required this.player,
      required this.data,
      this.fill = false,
      this.onBack,
      required this.viewSize,
      this.hideDuration = 4000,
      this.doubleTap = false,
      this.snapShot = false,
      required this.texPos,
      this.isLive = false,
      })
      : assert(hideDuration > 0 && hideDuration < 10000),
        super(key: key);

  @override
  __FijkPanel2State createState() => __FijkPanel2State();
}

class __FijkPanel2State extends State<_FijkPanel2> {

  final double _min = 0.0;
  late double _max = 1.0;

  FijkPlayer get player => widget.player;

  bool _isLock = false;
  Timer? _hideTimer;
  bool __hideStuff = true;
  bool get _hideStuff => __hideStuff;
  set _hideStuff (bool value) {
    if (__hideStuff == value) return;
    __hideStuff = value;
    _hideStuffController.add(!(_dragging || (!__hideStuff)));
  }

  Timer? _statelessTimer;
  bool _prepared = false;
  bool _playing = false;
  bool _controllerWasPlaying = false;
  bool __dragging = false;
  bool get _dragging => __dragging;
  set _dragging (bool value) {
    if (__dragging == value) return;
    __dragging = value;
    _hideStuffController.add(!(__dragging || (!_hideStuff)));
  }
  double dxBase = 0.0;
  double dragValue = 0.0;
  static const double margin = 2.0;

  bool _dragLeft = false;
  double? _volume;
  double? _brightness;

  double _seekPos = -1.0;
  Duration __duration = Duration();
  Duration get _duration {
    return __duration;
  }
  set _duration (Duration value ){
    __duration = value;
    // 同时更新 max值
    _max = dura2double(_duration);
  }
  Duration __currentPos = Duration();
  Duration get _currentPos => __currentPos;
  set _currentPos (Duration value){
    __currentPos = value;
    if (!widget.isLive){
      // 非直播环境 更新当前的播放记录进度
      VideoModelCache.m3u8CurrentPosCacheManager
          .setString("${VideoModelCache.M3U8_CURRENT_POS_CACHE_KEY_TRY_CACHE}@${player.dataSource}", "${dura2double(value)}");
    }
  }
  Duration _bufferPos = Duration();

  StreamSubscription? _currentPosSubs;
  StreamSubscription? _bufferPosSubs;

  late StreamController<double> _valController;
  late StreamController<double> _valueController;
  late StreamController<bool> _hideStuffController;

  // snapshot
  ImageProvider? _imageProvider;
  Timer? _snapshotTimer;

  // Is it needed to clear seek data in FijkData (widget.data)
  bool _needClearSeekData = true;

  bool get videoInit => player.isPlayable();

  static const FijkSliderColors sliderColors = FijkSliderColors(
      cursorColor: Color.fromARGB(240, 250, 100, 10),
      playedColor: Color.fromARGB(200, 240, 90, 50),
      baselineColor: Color.fromARGB(100, 20, 20, 20),
      bufferedColor: Color.fromARGB(180, 200, 200, 200));

  @override
  void initState() {
    super.initState();

    _valController = StreamController.broadcast();
    _valueController = StreamController.broadcast();
    _hideStuffController = StreamController.broadcast();
    _prepared = player.state.index >= FijkState.prepared.index;
    _playing = player.state == FijkState.started;
    _duration = player.value.duration;

    _bufferPos = player.bufferPos;
    _max = dura2double(_duration);
    if (!widget.isLive){
      // 直播不适用缓存
      VideoModelCache.m3u8CurrentPosCacheManager
          .getString("${VideoModelCache.M3U8_CURRENT_POS_CACHE_KEY_TRY_CACHE}@${player.dataSource}")
          .then((value){
        if (null != value){
          Timer(Duration(milliseconds: 3*1000), () {
            _controllerWasPlaying = _playing;
            if (_controllerWasPlaying) {
              player.pause();
            }
            setState(() {
              _dragging = true;
            });
            _hideTimer?.cancel();

            setState(() {
              _dragging = false;
            });
            if (_controllerWasPlaying) {
              player.start();
            }
            dragValue = double.parse(value);
            setState(() {
              _seekPos = dragValue;
              player.seekTo(dragValue.toInt());
              _currentPos = Duration(milliseconds: _seekPos.toInt());
              widget.data
                  .setValue(LocalFijkDataStatic._fijkViewPanelSeekto, _seekPos);
              _needClearSeekData = true;
              _seekPos = -1.0;
            });
            _restartHideTimer();
          });
        } else{
          setState(() {
            _currentPos = player.currentPos;
          });
        }
      });
    }
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      if (_hideStuff == false) {
        setState(() {
          _currentPos = v;
        });
      } else {
        _currentPos = v;
      }
      if (_needClearSeekData) {
        widget.data.clearValue(LocalFijkDataStatic._fijkViewPanelSeekto);
      }
      _needClearSeekData = false;
    });

    if (widget.data.contains(LocalFijkDataStatic._fijkViewPanelSeekto)) {
      var pos = widget.data.getValue(LocalFijkDataStatic._fijkViewPanelSeekto)
          as double;
      _currentPos = Duration(milliseconds: pos.toInt());
    }

    _bufferPosSubs = player.onBufferPosUpdate.listen((v) {
      if (_hideStuff == false) {
        setState(() {
          _bufferPos = v;
        });
      } else {
        _bufferPos = v;
      }
    });

    player.addListener(_playerValueChanged);
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    _valController.close();
    _valueController.close();
    _hideStuffController.close();
    _hideTimer?.cancel();
    _statelessTimer?.cancel();
    _snapshotTimer?.cancel();
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    player.removeListener(_playerValueChanged);
  }

  double dura2double(Duration d) {
    return d.inMilliseconds.toDouble();
  }

  void _playerValueChanged() {
    FijkValue value = player.value;

    if (value.duration != _duration) {
      if (_hideStuff == false) {
        setState(() {
          _duration = value.duration;
        });
      } else {
        _duration = value.duration;
      }
    }
    bool playing = (value.state == FijkState.started);
    bool prepared = value.prepared;
    if (playing != _playing ||
        prepared != _prepared ||
        value.state == FijkState.asyncPreparing) {
      setState(() {
        playing ? Wakelock.enable() : Wakelock.disable();
        _playing = playing;
        _prepared = prepared;
      });
    }
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(milliseconds: widget.hideDuration), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void onTapFun() {
    if (_hideStuff == true) {
      _restartHideTimer();
    }
    setState(() {
      _hideStuff = !_hideStuff;
    });
  }

  void playOrPause() {
    if (player.isPlayable() || player.state == FijkState.asyncPreparing) {
      if (player.state == FijkState.started) {
        player.pause();
      } else {
        player.start();
      }
    } else if (player.state == FijkState.initialized) {
      player.start();
    } else {
      FijkLog.w("Invalid state ${player.state} ,can't perform play or pause");
    }
  }

  void onDoubleTapFun() {
    if(widget.isLive || _isLock) return;
    playOrPause();
  }

  void onVerticalDragStartFun(DragStartDetails d) {
    if (!videoInit) {
      return;
    }
    if(_isLock) return;
    if (d.localPosition.dx > panelWidth() / 2) {
      // right, volume
      _dragLeft = false;
      FijkVolume.getVol().then((v) {
        if (!widget.data.contains(LocalFijkDataStatic._fijkViewPanelVolume)) {
          widget.data.setValue(LocalFijkDataStatic._fijkViewPanelVolume, v);
        }
        setState(() {
          _volume = v;
          _valController.add(v);
        });
      });
    } else {
      // left, brightness
      _dragLeft = true;
      FijkPlugin.screenBrightness().then((v) {
        if (!widget.data
            .contains(LocalFijkDataStatic._fijkViewPanelBrightness)) {
          widget.data.setValue(LocalFijkDataStatic._fijkViewPanelBrightness, v);
        }
        setState(() {
          _brightness = v;
          _valController.add(v);
        });
      });
    }
    _statelessTimer?.cancel();
    _statelessTimer = _statelessTimerCreator();
  }

  Timer _statelessTimerCreator({VoidCallback? call}) {
    return Timer(const Duration(milliseconds: 2000), () {
      if (null != _volume || null != _brightness) {
        _statelessTimer?.cancel();
        _statelessTimer = _statelessTimerCreator();
      }
      setState(call ?? (() {}));
    });
  }

  void onVerticalDragUpdateFun(DragUpdateDetails d) {
    if (!videoInit) {
      return;
    }
    if(_isLock) return;
    double delta = d.primaryDelta! / panelHeight();
    delta = -delta.clamp(-1.0, 1.0);
    if (_dragLeft == false) {
      var volume = _volume;
      if (volume != null) {
        volume += delta;
        volume = volume.clamp(0.0, 1.0);
        _volume = volume;
        FijkVolume.setVol(volume);
        setState(() {
          _valController.add(volume!);
        });
      }
    } else if (_dragLeft == true) {
      var brightness = _brightness;
      if (brightness != null) {
        brightness += delta;
        brightness = brightness.clamp(0.0, 1.0);
        _brightness = brightness;
        FijkPlugin.setScreenBrightness(brightness);
        setState(() {
          _valController.add(brightness!);
        });
      }
    }
  }

  void onVerticalDragEndFun(DragEndDetails e) {
    if (!videoInit) {
      return;
    }
    if(_isLock) return;
    _volume = null;
    _brightness = null;
    _statelessTimer?.cancel();
    _statelessTimer = _statelessTimerCreator();
  }

  void onHorizontalDragStart(DragStartDetails details) {
    if(widget.isLive || _isLock) return;
    double duration = dura2double(_duration);
    double currentValue = _seekPos > 0 ? _seekPos : dura2double(_currentPos);
    currentValue = currentValue.clamp(0.0, duration);
    dragValue = currentValue;
    if (!videoInit) {
      return;
    }

    dxBase = details.localPosition.dx;
    _controllerWasPlaying = _playing;
    if (_controllerWasPlaying) {
      player.pause();
    }
    setState(() {
      _dragging = true;
    });
    _hideTimer?.cancel();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if(widget.isLive || _isLock) return;
    final box = context.findRenderObject() as RenderBox;
    final dx = details.localPosition.dx - dxBase;
    if (!videoInit) {
      return;
    }
    int numTag = dx < 0 ? -1 : 1;

    // 取消符号信息 正值
    dragValue = (numTag * dx) / (box.size.width - 2 * margin);
    dragValue = max(0, min(1, dragValue));
    // 添加符号信息 进行加减
    dragValue = ( numTag * dragValue * (_max - _min) ) + dura2double(_currentPos);
    // 不得超越最大值
    if (_duration.inMilliseconds < dragValue){
      dragValue = _duration.inMilliseconds*1.0;
    }
    // 不得小于最小值
    if (0 > dragValue){
      dragValue = 0.0;
    }
    // 添加符号信息
    dragValue = numTag * dragValue;
    _valueController.add(dragValue);
    setState(() {
      // 取消符号信息 正值
      _seekPos = numTag * dragValue;
    });
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if(widget.isLive || _isLock) return;
    setState(() {
      _dragging = false;
    });
    if (_controllerWasPlaying) {
      player.start();
    }
    int numTag = dragValue < 0 ? -1 : 1;
    _valueController.add(dragValue);
    // 取消符号信息
    dragValue = numTag * dragValue;
    setState(() {
      _dragging = false;
      if (_duration.inMilliseconds < dragValue){
        dragValue = _duration.inMilliseconds*1.0;
      }
      player.seekTo(dragValue.toInt());
      _currentPos = Duration(milliseconds: _seekPos.toInt());
      widget.data
          .setValue(LocalFijkDataStatic._fijkViewPanelSeekto, _seekPos);
      _needClearSeekData = true;
      _seekPos = -1.0;
    });
    _restartHideTimer();
  }

  void onLongPressStart(LongPressStartDetails details) {
    if(widget.isLive || _isLock) return;
    if (!videoInit) {
      return;
    }
    player.setSpeed(2.0);
  }

  void onLongPressEnd(LongPressEndDetails details) {
    if(widget.isLive || _isLock) return;
    player.setSpeed(1.0);
  }

  Widget buildPlayButton(BuildContext context, double height) {
    Icon icon = (player.state == FijkState.started)
        ? Icon(Icons.pause)
        : Icon(Icons.play_arrow);
    bool fullScreen = player.value.fullScreen;
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: playOrPause,
    );
  }

  Widget buildLockButton() {
    Icon icon = widget.isLive
        ? Icon(Icons.album_outlined)
        : (_isLock)
          ? Icon(Icons.lock_outlined)
          : Icon(Icons.lock_open_outlined);
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.all(0),
            color: Color(0xFFFFFFFF),
            icon: icon,
            onPressed: (){
              setState(() {
                _isLock=!_isLock;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSelectButton() {
    return Builder(builder: (BuildContext context){
      return SpeedSelect(
        onSelectChanged: (double value) => player.setSpeed(value),
        hideStuffStream: _hideStuffController.stream,
      );
    }) ;
  }

  Widget buildFullScreenButton(BuildContext context, double height) {
    bool fullScreen = player.value.fullScreen;
    Icon icon = fullScreen
        ? Icon(Icons.fullscreen_exit)
        : Icon(Icons.fullscreen);
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: () {
        fullScreen
            ? player.exitFullScreen()
            : player.enterFullScreen();
      },
    );
  }

  Widget buildCallDrawerButton(BuildContext context, double height) {
    bool fullScreen = player.value.fullScreen;
    return fullScreen ? IconButton(
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: Icon(Icons.menu),
      onPressed: () {
        // TODO  添加全屏选集功能
      },
    ): Container();
  }

  Widget buildTimeText(BuildContext context, double height) {
    String text =
        "${_duration2String(_currentPos)}" + "/${_duration2String(_duration)}";
    return Text(text, style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)));
  }

  Widget buildSlider(BuildContext context) {
    double duration = dura2double(_duration);

    double currentValue = _seekPos > 0 ? _seekPos : dura2double(_currentPos);
    currentValue = currentValue.clamp(0.0, duration);

    double bufferPos = dura2double(_bufferPos);
    bufferPos = bufferPos.clamp(0.0, duration);

    return Padding(
      padding: EdgeInsets.only(left: 3),
      child: FijkSlider(
        colors: sliderColors,
        value: currentValue,
        cacheValue: bufferPos,
        min: 0.0,
        max: duration,
        onChangeStart: (v) {
          if (!videoInit) {
            return;
          }
          _controllerWasPlaying = _playing;
          if (_controllerWasPlaying) {
            player.pause();
          }
          setState(() {
            _dragging = true;
          });
          _hideTimer?.cancel();
        },
        onChanged: (v) {
          if (!videoInit) {
            return;
          }
          if (_duration.inMilliseconds < v){
            v = _duration.inMilliseconds*1.0;
          }
          setState(() {
            _seekPos = v;
          });
        },
        onChangeEnd: (v) {
          if (_controllerWasPlaying) {
            player.start();
          }
          setState(() {
            _dragging = false;
            if (_duration.inMilliseconds < v){
              v = _duration.inMilliseconds*1.0;
            }
            player.seekTo(v.toInt());
            _currentPos = Duration(milliseconds: _seekPos.toInt());
            widget.data
                .setValue(LocalFijkDataStatic._fijkViewPanelSeekto, _seekPos);
            _needClearSeekData = true;
            _seekPos = -1.0;
          });
          _restartHideTimer();
        },
      ),
    );
  }

  Widget buildBottom(BuildContext context, double height) {
    if(widget.isLive){
      return Row(
        children: <Widget>[
          Text("直播", style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF))),
          Expanded(child: Container()),
          buildFullScreenButton(context, height),
        ],
      );
    }
    if (_duration.inMilliseconds > 0) {
      return Row(
        children: <Widget>[
          buildPlayButton(context, height),
          buildTimeText(context, height),
          Expanded(child: buildSlider(context)),
          _buildSpeedSelectButton(),
          buildFullScreenButton(context, height),
          buildCallDrawerButton(context, height),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          buildPlayButton(context, height),
          Expanded(child: Container()),
          _buildSpeedSelectButton(),
          buildFullScreenButton(context, height),
          buildCallDrawerButton(context, height),
        ],
      );
    }
  }

  void takeSnapshot() {
    player.takeSnapShot().then((v) {
      var provider = MemoryImage(v);
      precacheImage(provider, context).then((_) {
        setState(() {
          _imageProvider = provider;
        });
      });
      FijkLog.d("get snapshot succeed");
    }).catchError((e) {
      FijkLog.d("get snapshot failed");
    });
  }

  Widget buildPanel(BuildContext context) {
    double height = panelHeight();

    bool fullScreen = player.value.fullScreen;
    Widget topWidget = Container(
      color: Color(0x00000000),
    );

    Widget centerWidget = Container(
      color: Color(0x00000000),
    );

    Widget centerChild = Container(
      color: Color(0x00000000),
    );

    List<Widget> wslist = <Widget>[];
    if ( fullScreen ) {
      topWidget = Row(
        children: <Widget>[
          Expanded(
            flex: 1,
              child: IconButton(
                padding: EdgeInsets.all(0),
                color: Color(0xFFFFFFFF),
                icon: Icon(Icons.keyboard_arrow_left_outlined),
                onPressed: () {
                  setState(() {
                    _isLock = false;
                  });
                  player.exitFullScreen();
                },
              )
          ),
          Expanded(
            flex: 10,
            child:Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF))
            ),
          ),
          Expanded(
              flex: 1,
              child: IconButton(
                padding: EdgeInsets.all(0),
                color: Color(0xFFFFFFFF),
                icon: Icon(Icons.airplay_outlined),
                onPressed: () {
                  player.pause();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DlnaDeviceList(widget.m3u8Url)),
                  );
                },
              )
          ),
        ],
      );

      wslist
        ..add(buildLockButton())
        ..add(Expanded(child: centerChild));
      if (widget.snapShot){
        wslist.add(Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.all(0),
                color: Color(0xFFFFFFFF),
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  takeSnapshot();
                },
              ),
            ],
          ),
        )
        );
      }
      centerWidget = Row(
        children: wslist,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: height > 200 ? 80 : height / 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88000000), Color(0x00000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.topLeft,
          child: Container(
            height: height > 80 ? 45 : height / 2,
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 5),
            child: topWidget,
          ),
        ),
        Expanded(
          child: _dragging ? defaultFijkMovToast(0.0,_valueController.stream): centerWidget,
        ),
        Container(
          height: height > 80 ? 80 : height / 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88000000), Color(0x00000000)],
              end: Alignment.topCenter,
              begin: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height > 80 ? 45 : height / 2,
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 5),
            child: (_isLock) ? centerChild: buildBottom(context, height > 80 ? 40 : height / 2),
          ),
        )
      ],
    );
  }

  GestureDetector buildGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: onTapFun,
      onDoubleTap: widget.doubleTap ? onDoubleTapFun : null,
      onVerticalDragUpdate: onVerticalDragUpdateFun,
      onVerticalDragStart: onVerticalDragStartFun,
      onVerticalDragEnd: onVerticalDragEndFun,
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: AbsorbPointer(
        absorbing: !(_dragging || (!_hideStuff)),
        child: AnimatedOpacity(
          opacity: _dragging || (!_hideStuff) ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: buildPanel(context),
        ),
      ),
    );
  }

  Rect panelRect() {
    Rect rect = player.value.fullScreen || (true == widget.fill)
        ? Rect.fromLTWH(0, 0, widget.viewSize.width, widget.viewSize.height)
        : Rect.fromLTRB(
            min(0.0, widget.texPos.left),
            max(0.0, widget.texPos.top),
            max(widget.viewSize.width, widget.texPos.right),
            min(widget.viewSize.height, widget.texPos.bottom));
    return rect;
  }

  double panelHeight() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.height;
    } else {
      return min(widget.viewSize.height, widget.texPos.bottom) -
          max(0.0, widget.texPos.top);
    }
  }

  double panelWidth() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.width;
    } else {
      return max(widget.viewSize.width, widget.texPos.right) -
          min(0.0, widget.texPos.left);
    }
  }

  Widget buildBack(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.only(left: 5),
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xDDFFFFFF),
      ),
      onPressed: widget.onBack,
    );
  }

  Widget buildStateless() {
    var volume = _volume;
    var brightness = _brightness;
    if (volume != null || brightness != null) {
      Widget toast = brightness != null
          ? defaultFijkBrightnessToast(brightness, _valController.stream)
          : defaultFijkVolumeToast(volume!, _valController.stream);
      return IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 500),
          child: toast,
        ),
      );
    } else if (player.state == FijkState.asyncPreparing) {
      return Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white)),
        ),
      );
    } else if (player.state == FijkState.error) {
      return Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.error,
          size: 30,
          color: Color(0x99FFFFFF),
        ),
      );
    } else if (_imageProvider != null) {
      _snapshotTimer?.cancel();
      _snapshotTimer = Timer(Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _imageProvider = null;
          });
        }
      });
      return Center(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.yellowAccent, width: 3)),
            child:
                Image(height: 200, fit: BoxFit.contain, image: _imageProvider!),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Rect rect = panelRect();

    List ws = <Widget>[];

    if (_statelessTimer != null && _statelessTimer!.isActive) {
      ws.add(buildStateless());
    } else if (player.state == FijkState.asyncPreparing) {
      ws.add(buildStateless());
    } else if (player.state == FijkState.error) {
      ws.add(buildStateless());
    } else if (_imageProvider != null) {
      ws.add(buildStateless());
    }
    ws.add(buildGestureDetector(context));
    if (widget.onBack != null) {
      ws.add(buildBack(context));
    }
    return Positioned.fromRect(
      rect: rect,
      child: Stack(children: ws as List<Widget>),
    );
  }
}
