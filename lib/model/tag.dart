import 'package:flutter/material.dart';

// TODO:
// 已删除的但之前使用过的 tags
// 可以让用户选择清楚所有已删除的 tags 对应的 check
Tags deletedTagsInUse;

class Tags with ChangeNotifier {
  var _items = <int, Tag>{};
  // List<Tag> _items = [];
  // 被删除了但以前使用过的 tag
  // List<Tag> _invalidItems = [];
  var _invalidItems = <int, Tag>{};

  Map<int, Tag> get items => _items;

  operator [](int i) => _items[i];
  operator []=(int i, Tag tag) {
    _items[i] = tag;
    notifyListeners();
  }

  List<Tag> getRootTags() {
    return _items.values.where((i) => i.parentID == null).toList();
  }

  void updateItem(int id, String name, int color) {
    _items[id].name = name;
    _items[id].color = color;
    for (int childID in _items[id].children) {
      _items[childID].color = color;
    }
    notifyListeners();
  }

  void addChild(int parentID, Tag t) {
    _items[t.id] = t;
    _items[parentID].children.add(t.id);
    notifyListeners();
  }

  void add(Tag t) {
    _items[t.id] = (t);
    notifyListeners();
  }

  void removeMulti(Iterable<int> ids) {
    for (int id in ids) {
      _removeWithoutNotify(id);
    }
    notifyListeners();
  }

  void _removeWithoutNotify(int id) {
    if (_items[id].parentID != null) {
      _items[items[id].parentID].children.remove(id);
    }
    for (var childID in _items[id].children) {
      _items.remove(childID);
    }
    _items.remove(id);
  }

  // TODO: 已经被使用过的 tag 不能轻易删除
  void remove(int id) {
    _removeWithoutNotify(id);
    notifyListeners();
  }
}

int incID = 0;
int nextID() {
  return incID++;
}

class Tag {
  // TODO: 自增，需要记录 last id
  int id;
  String name;
  int color;
  int parentID;
  List<int> children = [];

  static Tag empty() {
    return Tag('', 0XFFC16069);
  }

  Tag(this.name, this.color, {this.id, this.parentID}) {
    if (id == null) {
      id = nextID();
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return name;
  }
}
