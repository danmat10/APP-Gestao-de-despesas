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
    "Alimentação": 5,
    "Outros": 2,
  };
  Map<String, double> incomeDataMap = {
    "Salário": 5,
    "Outros": 2,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análise de Movimentações'),
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

                return Column(
                  children: [
                    PieChart(
                      dataMap: expenseDataMap,
                      animationDuration: Duration(milliseconds: 800),
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      chartType: ChartType.disc,
                      legendOptions: LegendOptions(
                        showLegends: true,
                        legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Despesas',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    PieChart(
                      dataMap: incomeDataMap,
                      animationDuration: Duration(milliseconds: 800),
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      chartType: ChartType.disc,
                      legendOptions: LegendOptions(
                        showLegends: true,
                        legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                      ),
                    )
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

    return categoryAmounts;
  }

  Map<String, double> _createIncomeDataMap(List<ExpenseModel> expenses) {
    final Map<String, double> categoryAmounts = {};
    for (var expense in expenses) {
      if (expense.amount > 0) {
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

    return categoryAmounts;
  }
}
