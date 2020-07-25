import 'package:wire/src/main.dart';

class TodoMiddleware extends WireMiddleware {
  @override
  void onAdd(Wire wire) {
    print('> TodoMiddleware -> onAdd: signal = ${wire.signal} | scope = ${wire.scope}');
  }

  @override
  void onData(String key, prevValue, nextValue) {
    print('> TodoMiddleware -> onData: key = ${key} | ${prevValue}-${nextValue}');
  }

  @override
  void onRemove(String signal, [Object scope, listener]) {
    print('> TodoMiddleware -> onRemove: signal = ${signal} | ${scope} | ${listener}');
  }

  @override
  void onSend(String signal, [data]) {
    print('> TodoMiddleware -> onSend: signal = ${signal} | data = ${data}');
  }
}