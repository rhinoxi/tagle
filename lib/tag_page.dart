import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:tagle/abstract_page.dart';
import 'package:tagle/model/mode.dart';
import 'package:tagle/model/tag.dart';
import 'package:tagle/tag_edit_page.dart';

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

Widget _makeTagCard(
    BuildContext context,
    Tag item,
    Mode mode,
    VoidCallback onEdit,
    VoidCallback onDelete,
    VoidCallback onPlusChild,
    VoidCallback onPressedTagIcon,
    VoidCallback onLongPressedTagIcon) {
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
                    GestureDetector(
                      child: Container(
                        height: 24,
                        width: 24,
                        child: mode.value == TagleMode.normal
                            ? Icon(
                                Icons.loyalty,
                                size: 16,
                                color: Colors.grey[100],
                              )
                            : Checkbox(
                                value: false,
                                onChanged: (bool value) {},
                              ),
                      ),
                      onTap: onPressedTagIcon,
                      onLongPress: onLongPressedTagIcon,
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          item.children[index].name,
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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

class TagPageBody extends StatefulWidget {
  @override
  _TagPageBodyState createState() => _TagPageBodyState();
}

class _TagPageBodyState extends State<TagPageBody> {
  @override
  Widget build(BuildContext context) {
    Mode mode = context.watch<Mode>();
    // double _maxWidth = MediaQuery.of(context).size.width;
    double _maxHeight = MediaQuery.of(context).size.height;

    var tags = context.watch<Tags>();

    List<Widget> tagSliders = [];
    for (var i = 0; i < tags.items.length; i++) {
      Tag item = tags[i];
      VoidCallback onDelete = () => showDialog(
            context: context,
            builder: (BuildContext context) => _makeDeleteAlertDialog(
              context,
              () => tags.remove(item),
            ),
          );

      VoidCallback onEdit = () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TagEditPage(item, index: i)),
          );

      VoidCallback onPlusChild = () => showDialog(
            context: context,
            builder: (BuildContext context) => _makeChildDialog(
              context,
              (String name) {
                // TODO: add new tag, set parent
                var tag = Tag(name, item.color, parent: item);
                tags.addChild(i, tag);
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

      tagSliders.add(_makeTagCard(
        context,
        item,
        mode,
        onEdit,
        onDelete,
        onPlusChild,
        onPressedTagIcon,
        onLongPressedTagIcon,
      ));
    }

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
}

class TagPage extends AbsPage {
  Widget getBody() {
    return TagPageBody();
  }

  List<Widget> getActions(BuildContext context) {
    Mode mode = context.watch<Mode>();
    return mode.value == TagleMode.normal
        ? [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TagEditPage(Tag.empty())),
                );
              },
            )
          ]
        : [
            IconButton(
              icon: Icon(Icons.delete),
              // TODO:
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: () => mode.value = TagleMode.normal,
            ),
          ];
  }
}
