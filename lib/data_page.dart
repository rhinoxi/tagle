import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;

import 'package:tagle/abstract_page.dart';
import 'package:tagle/model/tag.dart';
import 'package:tagle/global.dart';

class DataPage extends AbsPage {
  Widget getTitle() {
    return Text('Tagle');
  }

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
    return Container(
      child: DataContent(),
    );
  }
}

class DataContent extends StatefulWidget {
  @override
  _DataContentState createState() => _DataContentState();
}

class _DataContentState extends State<DataContent> {
  Tags tags;

  // 获取之前 n 天的数据，不包括今天和昨天，因为今天和昨天的数据还可以编辑，而再往前的数据已经归档
  List<StatInfo> getStatInfo(Tags tags, int n) {
    Map<int, StatInfo> m = {};
    var today = DateTime.now();
    // 左闭右开
    String endDateStr = formatter.format(today.subtract(Duration(days: 1)));
    String startDateStr =
        formatter.format(today.subtract(Duration(days: 1 + n)));
    for (String d in vd.values) {
      if (d.compareTo(endDateStr) >= 0) {
        continue;
      } else if (d.compareTo(startDateStr) < 0) {
        break;
      } else {
        List<int> tagIDs =
            jsonDecode(localStorage.getString('$DailyTagPrefix:$d') ?? '[]')
                .cast<int>();

        for (int id in tagIDs) {
          m[id] ??= StatInfo(tags[id].name, n, tags[id].color);
          m[id].inc();
        }
      }
    }
    var ret = m.values.toList();
    ret.sort((a, b) => b.count.compareTo(a.count));
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var tags = context.read<Tags>();
    List<StatInfo> weekly = getStatInfo(tags, 7);
    List<StatInfo> monthly = getStatInfo(tags, 30);
    List<StatInfo> yearly = getStatInfo(tags, 365);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text(
              "周",
              style: TextStyle(fontSize: 18),
            ),
          ),
          HorizontalBarLabelChart(
            _createSeriesData(weekly),
            animate: false,
          ),
          Divider(),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text(
              "月",
              style: TextStyle(fontSize: 18),
            ),
          ),
          HorizontalBarLabelChart(
            _createSeriesData(monthly),
            animate: false,
          ),
          Divider(),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text(
              "年",
              style: TextStyle(fontSize: 18),
            ),
          ),
          HorizontalBarLabelChart(
            _createSeriesData(yearly),
            animate: false,
          ),
        ],
      ),
    );
  }
}

class StatInfo {
  String name;
  int total;
  int count;
  int color;

  StatInfo(this.name, this.total, this.color) : count = 0;

  void inc() {
    count++;
  }
}

List<charts.Series<StatInfo, String>> _createSeriesData(List<StatInfo> data) {
  return [
    charts.Series<StatInfo, String>(
        id: 'Work',
        domainFn: (StatInfo info, _) => info.name,
        measureFn: (StatInfo info, _) => info.count / info.total,
        fillColorFn: (StatInfo info, _) => common.Color.fromHex(
            code: '#' + info.color.toRadixString(16).substring(2)),
        data: data,
        // Set a label accessor to control the text of the bar label.
        labelAccessorFn: (StatInfo info, _) => '${info.name}: ${info.count}'),
    charts.Series<StatInfo, String>(
      id: 'Rest',
      domainFn: (StatInfo info, _) => info.name,
      measureFn: (StatInfo info, _) => (info.total - info.count) / info.total,
      data: data,
      labelAccessorFn: (_, __) => '',
      fillColorFn: (_, __) => charts.MaterialPalette.gray.shade100.lighter,
    ),
  ];
}

class HorizontalBarLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalBarLabelChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (seriesList[0].data.length * 60).toDouble(),
      child: charts.BarChart(
        seriesList,
        animate: animate,
        vertical: false,
        // Set a bar label decorator.
        // Example configuring different styles for inside/outside:
        //       barRendererDecorator: new charts.BarLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        // Hide domain axis.
        domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
        primaryMeasureAxis:
            charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
        barGroupingType: charts.BarGroupingType.stacked,
        // Configures a [PercentInjector] behavior that will calculate measure
        // values as the percentage of the total of all data that shares a
        // domain value.
        behaviors: [
          charts.PercentInjector(
              totalType: charts.PercentInjectorTotalType.domain)
        ],
      ),
    );
  }
}
