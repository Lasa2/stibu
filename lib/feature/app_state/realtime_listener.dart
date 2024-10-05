import 'package:appwrite/appwrite.dart';
import 'package:stibu/main.dart';

class RealtimeListener {
  final Realtime _realtime;
  final _listeners = <String, Function(RealtimeMessage message)>{};
  Set<String> get channels => _listeners.keys.toSet();
  RealtimeSubscription? _subscription;

  set subscription(RealtimeSubscription? value) {
    if (value != null) {
      _subscription?.close();
      _subscription = value;

      // start listening to the new subscription
      _subscription?.stream.listen((message) {
        final messageChannels = Set.from(message.channels);
        final intersection = messageChannels.intersection(channels);
        log..info("Received message for on channel $intersection")
        ..info("Event: ${message.events.first}")
        ..info("Message: ${message.payload}");

        // check if the message is for any of the channels we are listening to
        for (var channel in intersection) {
          _listeners[channel]?.call(message);
        }
      });
    } else {
      _subscription?.close();
      _subscription = value;
    }
  }

  void addSubscription(
    String channel,
    Function(RealtimeMessage message) callback,
  ) {
    _listeners[channel] = callback;
    subscription = _realtime.subscribe(_listeners.keys.toList());
  }

  void removeSubscription(String channel) {
    _listeners.remove(channel);
    subscription = _realtime.subscribe(_listeners.keys.toList());
  }

  void addSubscriptions(
    Map<String, Function(RealtimeMessage message)> channels,
  ) {
    _listeners.addAll(channels);
    subscription = _realtime.subscribe(_listeners.keys.toList());
  }

  void removeSubscriptions(List<String> channels) {
    for (var channel in channels) {
      _listeners.remove(channel);
    }
    subscription = _realtime.subscribe(_listeners.keys.toList());
  }

  RealtimeListener(this._realtime);
}
