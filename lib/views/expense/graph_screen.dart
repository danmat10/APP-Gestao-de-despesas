import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_application_8/models/expense_model.dart';
import 'package:flutter_application_8/models/user_model.dart';
import 'package:flutter_application_8/services/expense_service.dart';

class GraphPage extends StatefulWidget {
  final UserModel user;

  GraphPage({required this.user});
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  ExpenseService expenseService = ExpenseService();
  Map<String, double> expenseDataMap = {
    "Alimentação": 1,
    "Outros": 1,
  };
  Map<String, double> incomeDataMap = {
    "Salário": 1,
    "Outros": 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análise de Movimentações'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<ExpenseModel>>(
              stream: expenseService.getExpensesStream(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No expenses found'));
                }

                List<ExpenseModel> expenses = snapshot.data!;
                expenseDataMap = _createExpensesDataMap(expenses);
                incomeDataMap = _createIncomeDataMap(expenses);

                return Column(
                  children: [
                    SizedBox(height: 30.0),
                    Text(
                      'Receitas',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    PieChart(
                      dataMap: incomeDataMap,
                      animationDuration: Duration(milliseconds: 800),
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      chartType: ChartType.disc,
                      colorList: [
                        Colors.green,
                        Colors.blue,
                        Colors.yellow,
                        Colors.cyan,
                        Colors.orange,
                      ],
                      legendOptions: LegendOptions(
                        showLegends: true,
                        legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chartValuesOptions: ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true),
                    ),
                    SizedBox(height: 50.0),
                    Text(
                      'Despesas',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    PieChart(
                      dataMap: expenseDataMap,
                      animationDuration: Duration(milliseconds: 800),
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      chartType: ChartType.disc,
                      colorList: [
                        Colors.red,
                        Colors.purple,
                        Colors.blueGrey,
                        Colors.pink,
                        Colors.deepPurple,
                      ],
                      legendOptions: LegendOptions(
                        showLegends: true,
                        legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chartValuesOptions: ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesInPercentage: false,
                          showChartValuesOutside: true),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _createExpensesDataMap(List<ExpenseModel> expenses) {
    final Map<String, double> categoryAmounts = {};
    for (var expense in expenses) {
      if (expense.amount < 0) {
        String category = expense.category;
        double amount = expense.amount.abs();
        categoryAmounts.update(category, (value) => value + amount,
            ifAbsent: () => amount);
      }
    }
    final totalExpenses =
        categoryAmounts.values.fold(0.0, (sum, amount) => sum + amount);

    categoryAmounts.forEach((key, value) {
      categoryAmounts[key] = (value / totalExpenses) * 100;
    });
    final sortedCategories = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <String, double>{};
    double otherCategoriesValue = 0;
    for (var i = 0; i < sortedCategories.length; i++) {
      if (i < 5 || sortedCategories[i].key.isEmpty) {
        if (sortedCategories[i].key.isNotEmpty) {
          result[sortedCategories[i].key] = sortedCategories[i].value;
        }
        otherCategoriesValue += sortedCategories[i].value;
      }
    }
    result['Outras'] = otherCategoriesValue;
    return result;
  }

  Map<String, double> _createIncomeDataMap(List<ExpenseModel> expenses) {
    final Map<String, double> categoryAmounts = {};

    for (var income in expenses) {
      if (income.amount > 0) {
        String category = income.category;
        double amount = income.amount.abs();
        categoryAmounts.update(category, (value) => value + amount,
            ifAbsent: () => amount);
      }
    }

    final sortedCategories = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <String, double>{};
    double otherCategoriesValue = 0;

    for (var i = 0; i < sortedCategories.length; i++) {
      if (i < 5) {
        result[sortedCategories[i].key] = sortedCategories[i].value;
      } else {
        if (sortedCategories[i].key.isNotEmpty) {
          otherCategoriesValue += sortedCategories[i].value;
        }
      }
    }

    if (otherCategoriesValue > 0) {
      result['Outras'] = otherCategoriesValue;
    }

    return result;
  }
}
