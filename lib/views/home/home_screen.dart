import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/views/auth/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_8/models/expense_model.dart';
import 'package:flutter_application_8/models/user_model.dart';
import 'package:flutter_application_8/services/expense_service.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  HomePage({required this.user});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ExpenseService expenseService = ExpenseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Adicionar movimentação'),
              onTap: () async {},
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Ver meus gastos'),
              onTap: () async {},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
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
                  return Center(child: Text('Nenhuma despesa encontrada'));
                }

                List<ExpenseModel> expenses = snapshot.data!;

                return ListView.builder(
                  itemCount: expenses.length,
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
