import 'dart:async';
import 'package:app.callme/models/socket_message.dart';
import 'package:app.callme/models/user_model.dart';
import 'package:app.callme/screens/main/bloc/bloc.dart';
import 'package:app.callme/services/socket_connection.dart';
import 'package:bloc/bloc.dart';
import 'package:provider/provider.dart';
import './bloc.dart';

class CallingBloc extends Bloc<CallingEvent, CallingState> {
  
  final MainBloc mainBloc;
  final User user;
  final bool isRequest;
  StreamSubscription<SocketMessage> _streamSubscription;
  StreamController<String> _noticeCtl = StreamController();
  Timer _timer;

  SocketConnection get socketConn => mainBloc.socketConnection;
  Stream<String> get noticeStream => _noticeCtl.stream;

  static CallingBloc of(context) {
    return Provider.of<CallingBloc>(context, listen: false);
  }

  @override
  CallingState get initialState => InitialCallingState();

  CallingBloc({this.isRequest = false, this.mainBloc, this.user}) {
    _streamSubscription = socketConn.stream.listen(_socketListener);
    
    if (!isRequest) {
      socketConn.emit('call_start', {'target': user.socketId});
    }
  }

  @override
  Future<void> close() async {
    super.close();
    _streamSubscription.cancel();
    _noticeCtl.close();
    _timer.cancel();
  }

  @override
  Stream<CallingState> mapEventToState(CallingEvent event) async* {
    if (event is CallNotAvailable) {
      await Future.delayed(Duration(seconds: 2));
      yield CallNotAvailableState();
    } else if (event is CallTargetBusy) {
      await Future.delayed(Duration(seconds: 2));
      yield CallTargetBusyState();
    } else if (event is CallEnded) {
      if (event.emit) {
        socketConn.emit('call_end', {'target': user.socketId});
      }
      yield CallEndedState();
    } else if (event is CallAccepted) {
      if (event.emit) {
        socketConn.emit('call_accepted', {'target': user.socketId});
      }
      yield CallAcceptedState();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _noticeCtl.sink.add(timer.tick.toString());
      });
    }
  }

  void _socketListener(SocketMessage message) {
    switch(message.action) {
      case 'call_not_available': 
        this.add(CallNotAvailable());
      break;
      case 'call_busy':
        this.add(CallTargetBusy());
      break;
      case 'call_end':
        this.add(CallEnded(false));
      break;
      case 'call_accepted':
        this.add(CallAccepted(false));
      break;
    }
  }

}
