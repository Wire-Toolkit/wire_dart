part of wire;

///
/// Created by Vladimir Cores (Minkin) on 12/06/20.
/// Github: https://github.com/DQvsRA
/// License: APACHE LICENSE, VERSION 2.0
///
typedef WireDataListener = void Function(dynamic value);

class WireData {
  Function _onRemove;
  final _listeners = <WireDataListener>{};

  /// This property needed to distinguish between newly created and not set WireData which has value of null at the beginning
  /// And with WireData at time when it's removed, because when removing the value also set to null
  bool _isSet = false;
  bool get isSet => _isSet;

  String _key;
  String get key => _key;

  dynamic _value; // initial value is null
  dynamic get value => _value;
  set value(dynamic input) {
    _value = input;
    _isSet = true;
    refresh();
  }

  WireData(this._key, this._onRemove);

  void refresh() {
    _listeners.forEach((listener) => listener(_value));
  }

  void remove() {
    _onRemove(_key);
    _onRemove = null;

    _key = null;
    // null value means remove element that listening on change (unsubscribe)
    value = null;

    _listeners.clear();
  }

  WireData subscribe(WireDataListener listener) {
    if (!hasListener(listener)) _listeners.add(listener);
    return this;
  }

  WireData unsubscribe([WireDataListener listener]) {
    if (listener != null) {
      if (hasListener(listener)) _listeners.remove(listener);
    } else {
      _listeners.clear();
    }
    return this;
  }

  bool hasListener(WireDataListener listener) {
    return _listeners.contains(listener);
  }
}
