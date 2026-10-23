import 'package:chart_barchart_app/model/developer_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late List<DeveloperData> data;
  late TooltipBehavior tooltipBehavior;

  @override
  void initState() {
    super.initState();
    data = [];
    addData();
    tooltipBehavior = TooltipBehavior(enable: true);
  }

  void addData(){
    data.add(DeveloperData(
      year: 2017, 
      developers: 19000
      )
    );
    data.add(DeveloperData(
      year: 2018, 
      developers: 40000
      )
    );
    data.add(DeveloperData(
      year: 2019, 
      developers: 35000
      )
    );
    data.add(DeveloperData(
      year: 2020, 
      developers: 37000
      )
    );
    data.add(DeveloperData(
      year: 2021, 
      developers: 45000
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bar Chart"),
      ),
      body: Center(
        child: SizedBox(
          width: 380,
          height: 600,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Yearly Growth in the Flutter Community'
            ),
            legend: Legend(isVisible: true),
            tooltipBehavior: tooltipBehavior,
            series: [
              // BarSeries : 가로축 막대 그래프 
              // ColumnSeries : 세로축 막대 그래프
              // LineSeries : 선 그래프
              // ScatterSeries : 산점도
              ScatterSeries<DeveloperData, int>(
                color: Theme.of(context).colorScheme.primaryContainer,
                name: 'Developer Community',
                dataSource: data,
                xValueMapper: (DeveloperData developers, _) => developers.year, 
                yValueMapper: (DeveloperData developers, _) => developers.developers,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                enableTooltip: true,
              ),
            ],
            // x축을 Category로 표현
            primaryXAxis: CategoryAxis(
              title: AxisTitle(text: "년도"),
            ),
            // y축을 숫자로 표현
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: "인원 수"),
            )
          ),
        ),
      ),
    );
  }
}