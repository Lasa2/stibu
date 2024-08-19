import 'package:stibu_api/src/models/common.dart';

class Collector<T extends AppwriteModel> {
  final _items = <String, T>{};

  List<T> get items => _items.values.toList();

  void addItems(List<T> items) {
    for (final item in items) {
      _items[item.$id] = item;
    }
  }

  void addItem(T item) {
    _items[item.$id] = item;
  }

  void removeItem(String id) {
    _items.remove(id);
  }

  void clear() {
    _items.clear();
  }
}
