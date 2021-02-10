import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tagle/model/tag.dart';

TextField _makeTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: hint,
    ),
  );
}

Widget colorPickerLayout(
    BuildContext context, List<Color> colors, PickerItem child) {
  return Container(
    width: 300,
    height: 160,
    child: GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 5.0,
      mainAxisSpacing: 5.0,
      children: colors.map((Color color) => child(color)).toList(),
    ),
  );
}

RaisedButton _makeColorPickerButton(
    BuildContext context, int currentColor, Function(Color) onColorChanged) {
  return RaisedButton(
    elevation: 3.0,
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select a color'),
            content: BlockPicker(
              layoutBuilder: colorPickerLayout,
              availableColors: [
                Color(0XFFE49162),
                Color(0XFFC16069),
                Color(0XFFB58DAE),
                Color(0XFF3B4252),
                Color(0XFF87C0D1),
                Color(0XFF80A0C2),
                Color(0XFFA3BE8C),
                Color(0XFF2E3440),
              ],
              pickerColor: Color(currentColor),
              onColorChanged: onColorChanged,
            ),
          );
        },
      );
    },
    color: Color(currentColor),
  );
}

TableRow _makeTableRow(String header, Widget w) {
  return TableRow(
    children: [
      Container(
        height: 60,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            header,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      w,
    ],
  );
}

class TagEditPage extends StatefulWidget {
  final Tag tag;
  final int index;
  final bool isNew;

  TagEditPage(this.tag, {Key key, this.index})
      : isNew = tag.name == '',
        super(key: key);

  @override
  _TagEditPageState createState() => _TagEditPageState();
}

class _TagEditPageState extends State<TagEditPage> {
  TextEditingController textController;
  int currentColor;

  void onColorChanged(Color color) {
    setState(() => currentColor = color.value);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    textController = new TextEditingController(text: widget.tag.name);
    currentColor = widget.tag.color;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tags = context.read<Tags>();
    List<TableRow> tableRows = [
      _makeTableRow(
        'name',
        _makeTextField('name it', textController),
      ),
      _makeTableRow(
        'color',
        _makeColorPickerButton(context, currentColor, onColorChanged),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? "Add tag" : "Edit tag"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (textController.text == '') {
                // TODO: alert
                return;
              }
              widget.tag.name = textController.text;
              widget.tag.color = currentColor;
              if (widget.isNew) {
                tags.add(widget.tag);
              } else {
                tags[widget.index] = widget.tag;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {0: FractionColumnWidth(.3)},
          border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey[400])),
          children: tableRows,
        ),
      ),
    );
  }
}
