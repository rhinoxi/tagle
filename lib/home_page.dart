import 'package:flutter/material.dart';
import 'package:tagle/abstract_page.dart';

class HomePage extends AbsPage {
  Widget getBody() {
    return HomePageBody();
  }

  List<Widget> getActions(BuildContext context) {
    return null;
  }
}

class HomePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('home'),
    );
  }
}
