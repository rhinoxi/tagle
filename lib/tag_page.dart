import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:tagle/abstract_page.dart';
import 'package:tagle/model/mode.dart';
import 'package:tagle/model/tag.dart';
import 'package:tagle/tag_edit_page.dart';

HashSet<int> _selectedTags = new HashSet<int>();

AlertDialog _makeChildDialog(BuildContext context, Function(String) plusFunc) {
  var textController = new TextEditingController();
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text(
      "OK",
      style: TextStyle(color: Colors.white),
    ),
    color: Colors.green[300],
    onPressed: () {
      plusFunc(textController.text);
      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    title: Text(''),
    content: TextField(
      controller: textController,
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  return alert;
}

AlertDialog _makeDeleteAlertDialog(BuildContext context, Function deleteFunc) {
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text(
      "DELETE",
      style: TextStyle(color: Colors.white),
    ),
    color: Colors.red[400],
    onPressed: () {
      deleteFunc();
      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    content: Text("Delete?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  return alert;
}

class TagPageBody extends StatefulWidget {
  @override
  _TagPageBodyState createState() => _TagPageBodyState();
}

class _TagPageBodyState extends State<TagPageBody> {
  Map<int, List<bool>> isChecked;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isChecked = new Map();
  }

  @override
  Widget build(BuildContext context) {
    Mode mode = context.watch<Mode>();
    // double _maxWidth = MediaQuery.of(context).size.width;
    double _maxHeight = MediaQuery.of(context).size.height;

    Tags tags = context.watch<Tags>();

    // List<Widget> tagSliders = [];
    List<Widget> tagSliders = tags.getRootTags().map((Tag item) {
      if (mode.value == TagleMode.normal) {
        isChecked[item.id] = List<bool>.filled(item.children.length, false);
      }
      VoidCallback onDelete = () => showDialog(
            context: context,
            builder: (BuildContext context) => _makeDeleteAlertDialog(
              context,
              () => tags.remove(item.id),
            ),
          );

      VoidCallback onEdit = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TagEditPage(id: item.id)),
          );

      VoidCallback onPlusChild = () => showDialog(
            context: context,
            builder: (BuildContext context) => _makeChildDialog(
              context,
              (String name) {
                // TODO: add new tag, set parent
                var tag = Tag(name, item.color, parentID: item.id);
                tags.addChild(item.id, tag);
              },
            ),
          );

      VoidCallback onPressedTagIcon = () {
        if (mode.value == TagleMode.child) {}
      };

      VoidCallback onLongPressedTagIcon = () {
        if (mode.value == TagleMode.normal) {
          mode.value = TagleMode.child;
        }
      };

      return _makeTagCard(
        context,
        item,
        mode,
        onEdit,
        onDelete,
        onPlusChild,
        onPressedTagIcon,
        onLongPressedTagIcon,
        tags,
      );
    }).toList();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: false,
          height: _maxHeight,
          aspectRatio: 2,
          enlargeCenterPage: true,
        ),
        items: tagSliders,
      ),
    );
  }

  Widget _makeTagCard(
    BuildContext context,
    Tag item,
    Mode mode,
    VoidCallback onEdit,
    VoidCallback onDelete,
    VoidCallback onPlusChild,
    VoidCallback onPressedTagIcon,
    VoidCallback onLongPressedTagIcon,
    Tags tags,
  ) {
    return Container(
      decoration: new BoxDecoration(
        color: Color(item.color),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[100],
                  ),
                ),
              ),
              Visibility(
                visible: mode.value == TagleMode.normal,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  color: Colors.grey[100],
                  onPressed: onEdit,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: item.children.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      mode.value == TagleMode.normal
                          ? GestureDetector(
                              child: Container(
                                  height: 24,
                                  width: 24,
                                  child: Icon(
                                    Icons.loyalty,
                                    size: 16,
                                    color: Colors.grey[100],
                                  )),
                              onTap: onPressedTagIcon,
                              onLongPress: onLongPressedTagIcon,
                            )
                          : Container(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: isChecked[item.id][index],
                                onChanged: (bool value) {
                                  setState(() {
                                    isChecked[item.id][index] = value;
                                    int id = item.children[index];
                                    if (value) {
                                      _selectedTags.add(id);
                                    } else {
                                      _selectedTags.remove(id);
                                    }
                                  });
                                },
                              ),
                            ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            tags[item.children[index]].name,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[100],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: mode.value == TagleMode.normal,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.grey[100],
                    onPressed: onDelete,
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.grey[100],
                    onPressed: onPlusChild,
                  ),
                ]),
          )
        ],
      ),
    );
  }
}

class TagPage extends AbsPage {
  Widget getBody() {
    return TagPageBody();
  }

  List<Widget> getActions(BuildContext context) {
    Mode mode = context.watch<Mode>();
    Tags tags = context.read<Tags>();
    return mode.value == TagleMode.normal
        ? [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TagEditPage()),
                );
              },
            )
          ]
        : [
            IconButton(
              icon: Icon(Icons.delete),
              // TODO:
              onPressed: () {
                tags.removeMulti(_selectedTags);
                _selectedTags.clear();
                mode.value = TagleMode.normal;
              },
            ),
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: () => mode.value = TagleMode.normal,
            ),
          ];
  }
}
