import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_8/models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').add(expense.toJson());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  Stream<List<ExpenseModel>> getExpensesStream(String userId) {
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      return ExpenseModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> updateExpense(String expenseId, ExpenseModel expense) async {
    await _firestore
        .collection('expenses')
        .doc(expenseId)
        .update(expense.toJson());
  }
}
