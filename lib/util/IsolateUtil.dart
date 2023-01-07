
import 'dart:isolate';

class IsolateUtil{

  static Future<IsolateComputeReturn> isolateCompute(IsolateCompute doCompute) async {
    final response = ReceivePort();
    Isolate isolate = await Isolate.spawn(_computeEvent, response.sendPort);
    final sendPort = await response.first;
    final answer = ReceivePort();
    sendPort.send([answer.sendPort, doCompute]);
    return IsolateComputeReturn( isolate, answer.first);
  }

  static void _computeEvent(SendPort port) {
    final rPort = ReceivePort();
    port.send(rPort.sendPort);
    rPort.listen((message) {
      final send = message[0] as SendPort;
      final n = message[1] as IsolateCompute ;
      send.send(n.doCompute());
    });
  }
}

class IsolateCompute{
  dynamic doCompute(){}
}

class IsolateComputeReturn{
  final Isolate isolate;
  final Future<dynamic> data;
  IsolateComputeReturn(this.isolate, this.data);
}