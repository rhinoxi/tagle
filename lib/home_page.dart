import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:tagle/abstract_page.dart';
import 'package:tagle/model/tag.dart';

class HomePage extends AbsPage {
  Widget getTitle() {
    return HomePageTitle();
  }

  Widget getBody() {
    return HomePageBody();
  }

  List<Widget> getActions(BuildContext context) {
    return [];
  }
}

class HomePageTitle extends StatefulWidget {
  @override
  _HomePageTitleState createState() => _HomePageTitleState();
}

class _HomePageTitleState extends State<HomePageTitle> {
  @override
  Widget build(BuildContext context) {
    var dailyTag = context.read<DailyTag>();
    return Selector<DailyTag, bool>(
      builder: (context, isToday, child) {
        return Container(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Visibility(
                visible: isToday,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    dailyTag.yesterday();
                    setState(() {});
                  },
                ),
              ),
              Text(isToday ? 'Today' : 'Yesterday'),
              Visibility(
                visible: !isToday,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    dailyTag.tomorrow();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      },
      selector: (_, model) => model.isToday,
    );
  }
}

class HomePageBody extends StatefulWidget {
  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TagleShow(),
        Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey[300],
        ),
        TaglePick(),
      ],
    );
  }
}

Widget _makeTagItem(Tag t) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      color: Color(t.color),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Text(
      t.name,
      style: TextStyle(color: Colors.grey[100]),
    ),
  );
}

class TagleShow extends StatefulWidget {
  @override
  _TagleShowState createState() => _TagleShowState();
}

class _TagleShowState extends State<TagleShow> {
  @override
  Widget build(BuildContext context) {
    double _maxHeight = MediaQuery.of(context).size.height;
    double _maxWidth = MediaQuery.of(context).size.width;
    List<Widget> tagChildren = [];

    var dailyTag = context.watch<DailyTag>();
    var tags = context.read<Tags>();
    for (int id in dailyTag.tagToday) {
      if (tags[id] != null) {
        tagChildren.add(_makeTagItem(tags[id]));
      }
    }

    return Container(
      width: _maxWidth,
      height: _maxHeight / 3,
      padding: EdgeInsets.all(10),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: tagChildren,
        ),
      ),
    );
  }
}

class TaglePick extends StatefulWidget {
  @override
  _TaglePickState createState() => _TaglePickState();
}

class _TaglePickState extends State<TaglePick> {
  Tags tags;
  DailyTag dailyTag;
  Map<int, bool> isChecked = {};

  @override
  Widget build(BuildContext context) {
    tags = context.watch<Tags>();
    dailyTag = context.watch<DailyTag>();
    tags.items.forEach((int k, Tag t) {
      if (t.parentID != null) {
        isChecked[k] = dailyTag.tagToday.contains(k);
      }
    });
    var rootTags = tags.getRootTags();
    return Expanded(
      child: Theme(
        data: ThemeData(
          accentColor: Colors.grey[100],
        ),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: rootTags.length,
          itemBuilder: (context, i) {
            return new ExpansionTile(
              backgroundColor: Color(rootTags[i].color),
              title: new Text(
                rootTags[i].name,
                style: new TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: <Widget>[
                new Column(
                  children: _buildExpandableContent(rootTags[i]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildExpandableContent(Tag t) {
    List<Widget> columnContent = [];

    for (int id in t.children) {
      columnContent.add(CheckboxListTile(
        activeColor: Colors.black,
        value: isChecked[id],
        title: Text(
          tags[id].name,
          style: TextStyle(
            color: Colors.grey[100],
            fontSize: 16.0,
          ),
        ),
        onChanged: (bool value) {
          if (value) {
            dailyTag.tagleAdd(id);
          } else {
            dailyTag.tagleRemove(id);
          }
          isChecked[id] = !isChecked[id];
          setState(() {});
        },
      ));
    }
    return columnContent;
  }
}
