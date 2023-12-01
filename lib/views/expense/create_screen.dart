import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/expense_model.dart';
import 'package:flutter_application_8/models/user_model.dart';
import 'package:flutter_application_8/services/expense_service.dart';

class CreateExpensePage extends StatefulWidget {
  final UserModel user;
  CreateExpensePage({required this.user});
  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  List<String> _expenseTypes = ['Despesa', 'Receita'];
  String _selectedExpenseType = 'Despesa';
  late ExpenseService expenseService = ExpenseService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _dateController = TextEditingController();
    _amountController = TextEditingController();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Movimentação'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedExpenseType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedExpenseType = newValue!;
                    });
                  },
                  items: _expenseTypes.map((expenseType) {
                    return DropdownMenuItem(
                      value: expenseType,
                      child: Text(expenseType),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Tipo'),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Categoria'),
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Data'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma data';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectDate(context);
                  },
                  readOnly: true,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um valor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      double amount = double.parse(_amountController.text);
                      if (_selectedExpenseType == 'Despesa') {
                        amount *= -1;
                      }
                      final expense = ExpenseModel(
                        title: _titleController.text,
                        date: Timestamp.fromDate(
                            DateTime.parse(_dateController.text)),
                        amount: amount,
                        category: _categoryController.text,
                        userId: widget.user.id,
                      );
                      try {
                        await expenseService.addExpense(expense);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Despesa adicionada com sucesso!')),
                        );
                        _formKey.currentState!.reset();
                        _selectedExpenseType = 'Despesa';
                        _titleController.clear();
                        _dateController.clear();
                        _amountController.clear();
                        _categoryController.clear();
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erro ao adicionar despesa: $error')),
                        );
                      }
                    }
                  },
                  child: Text('Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
