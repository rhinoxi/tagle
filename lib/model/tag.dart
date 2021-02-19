import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:tagle/global.dart';

// TODO:
// 已删除的但之前使用过的 tags
// 可以让用户选择清楚所有已删除的 tags 对应的 check
Tags deletedTagsInUse;

class Tags with ChangeNotifier {
  var _items = <int, Tag>{};
  // 被删除了但以前使用过的 tag
  var _invalidItems = <int, Tag>{};

  Map<int, Tag> get items => _items;

  Tags() {
    String tmp = localStorage.getString(ValidTagsKey) ?? '[]';
    List<dynamic> idList = jsonDecode(tmp);
    for (int id in idList) {
      Tag t =
          Tag.fromJson(jsonDecode(localStorage.getString('$TagKeyPrefix:$id')));
      _items[id] = t;
    }
  }

  operator [](int i) => _items[i];
  operator []=(int i, Tag tag) {
    _items[i] = tag;
    persistValid();
    notifyListeners();
  }

  void persistValid() {
    localStorage.setString(ValidTagsKey, jsonEncode(_items.keys.toList()));
  }

  void persistInvalid() {}

  List<Tag> getRootTags() {
    return _items.values.where((i) => i.parentID == null).toList();
  }

  void updateItem(int id, String name, int color) {
    _items[id].update(name: name, color: color);
    _items[id].persist();
    for (int childID in _items[id].children) {
      _items[childID].update(color: color);
      _items[childID].persist();
    }
    notifyListeners();
  }

  void addChild(int parentID, Tag t) {
    _addWithoutNotify(t);
    _items[parentID].addChild(t.id);
    notifyListeners();
  }

  void _addWithoutNotify(Tag t) {
    _items[t.id] = t;
    persistValid();
  }

  void add(Tag t) {
    _addWithoutNotify(t);
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
      _items[items[id].parentID].removeChild(id);
    }
    for (var childID in _items[id].children) {
      _items.remove(childID);
    }
    _items.remove(id);
    persistValid();
  }

  // TODO: 已经被使用过的 tag 不能轻易删除
  void remove(int id) {
    _removeWithoutNotify(id);
    notifyListeners();
  }
}

int nextID() {
  // TODO: persist
  lastID += 1;
  localStorage.setInt(LastIDKey, lastID);
  return lastID;
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

  void addChild(int id) {
    children.add(id);
    persist();
  }

  void removeChild(int id) {
    children.remove(id);
    persist();
  }

  Tag(this.name, this.color, {this.id, this.parentID});

  void persist() {
    if (id == null) {
      id = nextID();
    }
    // TODO: persist Tag
    localStorage.setString('$TagKeyPrefix:$id', jsonEncode(this));
  }

  void update({name, color}) {
    if (name != null) this.name = name;
    if (color != null) this.color = color;
  }

  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        color = json['color'],
        parentID = json['parent_id'],
        children = json['children'].cast<int>();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'parent_id': parentID,
        'children': children,
      };

  @override
  String toString() {
    // TODO: implement toString
    return name;
  }
}

class DailyTagRaw {}

class DailyTag extends DailyTagRaw with ChangeNotifier {
  DateTime today;
  DateTime tagDate;
  List<int> tagToday;

  DailyTag() {
    today = DateTime.now();
    Timer.periodic(
      Duration(seconds: 1),
      (Timer t) {
        var now = DateTime.now();
        if (today.year != now.year ||
            today.month != now.month ||
            today.day != now.day) {
          today = now;
          _load(today);
          notifyListeners();
        }
      },
    );
    _load(today);
  }

  String todayStr() {
    return formatter.format(tagDate);
  }

  void _load(DateTime dt) {
    tagDate = dt;
    tagToday = jsonDecode(
            localStorage.getString('$DailyTagPrefix:' + todayStr()) ?? '[]')
        .cast<int>();
  }

  bool get isToday => today.day == tagDate.day;

  void yesterday() {
    _load(tagDate.subtract(Duration(days: 1)));
    notifyListeners();
  }

  void tomorrow() {
    _load(tagDate.add(Duration(days: 1)));
    notifyListeners();
  }

  void tagleAdd(int id) {
    tagToday.add(id);
    localStorage.setString(
        '$DailyTagPrefix:' + todayStr(), jsonEncode(tagToday));
    notifyListeners();
  }

  void tagleRemove(int id) {
    tagToday.remove(id);
    localStorage.setString(
        '$DailyTagPrefix:' + todayStr(), jsonEncode(tagToday));
    notifyListeners();
  }
}

class ValidDates {
  List<String> values;

  ValidDates() {
    var tmp = localStorage.getString(ValidDatesKey) ?? '[]';
    values = jsonDecode(tmp).cast<String>();
  }

  void add(DateTime dt) {
    var dtStr = formatter.format(dt);
    for (int i = 0; i < values.length; i++) {
      if (dtStr == values[i]) {
        return;
      } else if (dtStr.compareTo(values[i]) > 0) {
        values.insert(i, dtStr);
        localStorage.setString(ValidDatesKey, jsonEncode(values));
        return;
      }
    }
    values.insert(values.length, dtStr);
    localStorage.setString(ValidDatesKey, jsonEncode(values));
  }
}

ValidDates vd = ValidDates();
