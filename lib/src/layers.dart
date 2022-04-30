part of wire;

///
/// Created by Vladimir Cores (Minkin) on 07/10/19.
/// Github: https://github.com/vladimircores
/// License: APACHE LICENSE, VERSION 2.0
///
class WireCommunicateLayer {
  final _wireById = <int, Wire>{};
  final _wireIdsBySignal = <String, List<int>>{};

  Wire add(Wire wire) {
    final wireId = wire.id;
    final signal = wire.signal;

    if (_wireById.containsKey(wireId)) {
      throw Exception(ERROR__WIRE_ALREADY_REGISTERED + wireId.toString());
    }

    _wireById[wireId] = wire;

    if (!_wireIdsBySignal.containsKey(signal)) {
      _wireIdsBySignal[signal] = <int>[];
    }

    _wireIdsBySignal[signal]!.add(wireId);

    return wire;
  }

  bool hasSignal(String signal) {
    return _wireIdsBySignal.containsKey(signal);
  }

  bool hasWire(Wire wire) {
    return _wireById.containsKey(wire.id);
  }

  Future<bool> send(String signal, [payload, scope]) async {
    bool noMoreSubscribers = true;
    // print('> Wire -> WireCommunicateLayer: send - hasSignal($signal) = ${hasSignal(signal)}');
    if (hasSignal(signal)) {
      final hasWires = _wireIdsBySignal.containsKey(signal);
      // print('> Wire -> WireCommunicateLayer: send - hasWires = ${hasWires}');
      if (hasWires) {
        final wiresToRemove = <Wire>[];
        final isLookingInScope = scope != null;
        await Future.forEach<int>(_wireIdsBySignal[signal]!, (wireId) async {
          Wire wire = _wireById[wireId]!;
          if (isLookingInScope && wire.scope != scope) return;
          noMoreSubscribers = wire.withReplies && --wire.replies == 0;
          // print('> \t\t wireId = ${wireId} | noMoreSubscribers = ${noMoreSubscribers}');
          if (noMoreSubscribers) wiresToRemove.add(wire);
          await wire.transfer(payload);
        });
        if (wiresToRemove.isNotEmpty) {
          await Future.forEach<Wire>(wiresToRemove, (wire) async {
            noMoreSubscribers = await _removeWire(wire);
          });
        }
      }
    }
    return noMoreSubscribers;
  }

  Future<bool> remove(String signal, [Object? scope, WireListener? listener]) async {
    var exists = hasSignal(signal);
    if (exists) {
      final toRemoveList = <Wire>[];
      final withScope = scope != null;
      final withListener = listener != null;
      await Future.forEach(_wireIdsBySignal[signal]!, (wireId) {
        if (_wireById.containsKey(wireId)) {
          final wire = _wireById[wireId];
          final isWrongScope = withScope && scope != wire!.scope;
          final isWrongListener = withListener && listener != wire!.listener;
          if (isWrongScope || isWrongListener) return;
          toRemoveList.add(wire!);
        }
      });
      await Future.forEach(toRemoveList, (Wire wireToRemove) => _removeWire(wireToRemove));
    }
    return exists;
  }

  Future<void> clear() async {
    var wiresToRemove = <Wire>[];
    _wireById.forEach((hash, wire) => wiresToRemove.add(wire));
    await Future.forEach(wiresToRemove, (Wire wire) => _removeWire(wire));

    _wireById.clear();
    _wireIdsBySignal.clear();
  }

  List<Wire> getBySignal(String signal) {
    return hasSignal(signal) ? _wireIdsBySignal[signal]!.map((wid) =>
      _wireById[wid]!).toList() : <Wire>[];
  }

  List<Wire> getByScope(Object scope) {
    var result = <Wire>[];
    _wireById.forEach((_, wire) => {if (wire.scope == scope) result.add(wire)});
    return result;
  }

  List<Wire> getByListener(WireListener listener) {
    final result = <Wire>[];
    _wireById.forEach((_, wire) => { if (wire.listener == listener) result.add(wire) });
    return result;
  }

  Wire? getByWireId(int wireId) {
    return _wireById.containsKey(wireId) ? _wireById[wireId] : null;
  }

  ///
  /// Exclude a Wire based on an signal.
  ///
  /// @param    The Wire to remove.
  /// @return If there is no ids (no Wires) for that SIGNAL stop future perform
  ///
  Future<bool> _removeWire(Wire wire) async {
    final wireId = wire.id;
    final signal = wire.signal;

    // Remove Wire by wid
    _wireById.remove(wireId);

    // Remove wid for Wire signal
    var wireIdsForSignal = _wireIdsBySignal[signal]!;
    wireIdsForSignal.remove(wireId);

    var noMoreSignals = wireIdsForSignal.isEmpty;
    if (noMoreSignals) _wireIdsBySignal.remove(signal);

    await wire.clear();

    return noMoreSignals;
  }
}

class WireDataContainerLayer {
  final Map<String, WireData> _dataMap = <String, WireData>{};

  bool      has(String key)     => _dataMap.containsKey(key);
  WireData  get(String key)     => _dataMap[key]!;
  WireData  create(String key)  => _dataMap[key] = WireData(key, remove);
  bool      remove(String key)  => _dataMap.remove(key) != null;

  Future<void> clear() async {
    var wireDataToRemove = <WireData>[];
    _dataMap.forEach((key, wireData) => wireDataToRemove.add(wireData));
    await Future.forEach(wireDataToRemove, (WireData wireData) async =>
    await wireData.remove(clean: true));

    _dataMap.clear();
  }
}
