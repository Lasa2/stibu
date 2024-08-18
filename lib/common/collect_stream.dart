import 'dart:async';

import 'package:stibu/common/model.dart';

class CollectStream<T extends RefModel> {
  final _collection = <String, T>{};
  final currentListeners = <StreamController<List<T>>>{};

  late Stream<List<T>> stream = Stream.multi((controller) {
    currentListeners.add(controller);
    controller.add(_collection.values.toList());

    controller.onCancel = () {
      currentListeners.remove(controller);
    };
  });

  void addItem(T item) {
    _collection[item.ref] = item;
    final latest = _collection.values.toList(growable: false);
    for (var controller in currentListeners) {
      if (controller.isPaused) continue;
      controller.add(latest);
    }
  }

  void addItems(List<T> items) {
    for (var item in items) {
      _collection[item.ref] = item;
    }
    final latest = _collection.values.toList(growable: false);
    for (var controller in currentListeners) {
      if (controller.isPaused) continue;
      controller.add(latest);
    }
  }

  void removeItem(String ref) {
    _collection.remove(ref);
    final latest = _collection.values.toList(growable: false);
    for (var controller in currentListeners) {
      if (controller.isPaused) continue;
      controller.add(latest);
    }
  }

  void clear() {
    _collection.clear();
    for (var controller in currentListeners) {
      if (controller.isPaused) continue;
      controller.add([]);
    }
  }
}
