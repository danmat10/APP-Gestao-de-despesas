import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_8/models/expense_model.dart';
import 'package:flutter_application_8/models/user_model.dart';
import 'package:flutter_application_8/services/expense_service.dart';

class ViewExpensePage extends StatefulWidget {
  final UserModel user;
  ViewExpensePage({required this.user});
  @override
  _ViewExpensePageState createState() => _ViewExpensePageState();
}

class _ViewExpensePageState extends State<ViewExpensePage> {
  ExpenseService expenseService = ExpenseService();
  double _finalBalance = 0.0;
  bool _showRecentTransactions = true;

  double _calculateTotal(List<ExpenseModel> expenses) {
    return expenses.fold(0, (sum, item) => sum + item.amount);
  }

  Stream<List<ExpenseModel>> getExpensesStream() {
    if (_showRecentTransactions) {
      return expenseService
          .getExpensesStream(widget.user.id)
          .map((expenses) => expenses.where((expense) {
                return expense.date
                    .toDate()
                    .isAfter(DateTime.now().subtract(Duration(days: 30)));
              }).toList());
    } else {
      return expenseService.getExpensesStream(widget.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Saldo',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                          .format(_finalBalance),
                      style: TextStyle(
                        color: _finalBalance < 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _showRecentTransactions = true;
                  });
                },
                child: Text(
                  'Últimas',
                  style: TextStyle(
                    color: _showRecentTransactions ? Colors.blue : Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showRecentTransactions = false;
                  });
                },
                child: Text(
                  'Todas',
                  style: TextStyle(
                    color: !_showRecentTransactions ? Colors.blue : Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<ExpenseModel>>(
              stream: expenseService.getExpensesStream(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Ocorreu um erro'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _finalBalance = 0.0;
                      });
                    }
                  });
                  return Center(child: Text('Nenhuma despesa encontrada'));
                }

                List<ExpenseModel> expenses = snapshot.data!;
                expenses.sort((a, b) => b.date.compareTo(a.date));
                double newBalance = _calculateTotal(expenses);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _finalBalance != newBalance) {
                    setState(() {
                      _finalBalance = newBalance;
                    });
                  }
                });
                int itemCount = _showRecentTransactions
                    ? expenses.length > 15
                        ? 2
                        : expenses.length
                    : expenses.length;
                return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    String formattedDate = DateFormat('dd MMM, yyyy')
                        .format(expense.date.toDate());
                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text(expense.category,
                          style: TextStyle(fontSize: 15)),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: 'R\$',
                            ).format(expense.amount),
                            style: TextStyle(
                              color: expense.amount < 0
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
