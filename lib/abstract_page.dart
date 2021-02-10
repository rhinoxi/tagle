import 'package:flutter/material.dart';

abstract class AbsPage {
  Widget getBody();
  List<Widget> getActions(BuildContext context);
}
