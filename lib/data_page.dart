import 'package:flutter/material.dart';
import 'package:tagle/abstract_page.dart';

class DataPage extends AbsPage {
  Widget getBody() {
    return DataPageBody();
  }

  List<Widget> getActions(BuildContext context) {
    return null;
  }
}

class DataPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Data'),
    );
  }
}
