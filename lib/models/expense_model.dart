import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String title;
  Timestamp date;
  double amount;
  String category;
  String userId;

  ExpenseModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.userId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      title: json['title'],
      date: json['date'] as Timestamp,
      amount: json['amount'].toDouble(),
      category: json['category'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'amount': amount,
      'category': category,
      'userId': userId,
    };
  }
}
