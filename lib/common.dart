import 'package:flutter/material.dart';
import 'package:tagle/model/tag.dart';

Widget _makeTagContainer(Tag tag, VoidCallback onPressed) {
  return IntrinsicWidth(
    child: OutlineButton(
      highlightedBorderColor: Color(tag.color),
      borderSide: BorderSide(
        width: tag.parent == null ? 2 : 1,
        color: Color(tag.color),
      ),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Text(
          tag.name,
          style: TextStyle(fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onPressed: onPressed,
    ),
  );

  // return Container(
  //   height: 40,
  //   constraints: BoxConstraints(maxWidth: maxWidth),
  //   padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
  //   decoration: BoxDecoration(
  //     border: Border.all(
  //       color: borderColor,
  //       width: borderWidth,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(20)),
  //   ),
  //   child: IntrinsicWidth(
  //     child: Center(
  //       child: Text(
  //         text,
  //         style: TextStyle(fontSize: 20),
  //         overflow: TextOverflow.ellipsis,
  //       ),
  //     ),
  //   ),
  // );
}

typedef IndexVoidCallbackBuilder = VoidCallback Function(int);

Widget makeClickableItems(
    List<Tag> children, IndexVoidCallbackBuilder onPressedBuilder) {
  List<Widget> tags = [];
  for (var i = 0; i < children.length; i++) {
    // TODO:
    tags.add(_makeTagContainer(children[i], onPressedBuilder(i)));
  }
  return Wrap(
    spacing: 16,
    runSpacing: 8,
    children: tags,
  );
}
