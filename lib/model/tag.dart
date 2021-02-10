import 'package:flutter/material.dart';

// TODO:
// 已删除的但之前使用过的 tags
// 可以让用户选择清楚所有已删除的 tags 对应的 check
Tags deletedTagsInUse;

class Tags with ChangeNotifier {
  List<Tag> _items = [];

  List<Tag> get items => _items;

  operator [](int i) => _items[i];
  operator []=(int i, Tag tag) {
    _items[i] = tag;
    notifyListeners();
  }

  List<Tag> getRootTags() {
    return _items.where((i) => i.parent == null).toList();
  }

  void addChild(int index, Tag t) {
    _items[index].children.add(t);
    notifyListeners();
  }

  void add(Tag t) {
    _items.add(t);
    notifyListeners();
  }

  // TODO: 已经被使用过的 tag 不能轻易删除
  void remove(Tag t) {
    _items.remove(t);
    for (var child in t.children) {
      _items.remove(child);
    }
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
  int _color;
  Tag parent;
  List<Tag> children = [];

  int get color => _color;

  set color(int c) {
    _color = c;
    for (var child in children) {
      child.color = c;
    }
  }

  static Tag empty() {
    return Tag('', 0XFFC16069);
  }

  Tag(this.name, this._color, {this.id, this.parent}) {
    if (id == null) {
      id = nextID();
    }
  }
}
