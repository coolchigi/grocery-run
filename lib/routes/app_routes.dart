import 'package:flutter/material.dart';
import '../presentation/grocery_run_detail/grocery_run_detail.dart';
import '../presentation/ocr_review/ocr_review.dart';
import '../presentation/add_grocery_run/add_grocery_run.dart';
import '../presentation/receipt_scanner/receipt_scanner.dart';
import '../presentation/dashboard_home/dashboard_home.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String groceryRunDetail = '/grocery-run-detail';
  static const String ocrReview = '/ocr-review';
  static const String addGroceryRun = '/add-grocery-run';
  static const String addGroceryRunManual = '/add-grocery-run-manual';
  static const String receiptScanner = '/receipt-scanner';
  static const String dashboardHome = '/dashboard-home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const DashboardHome(),
    groceryRunDetail: (context) => const GroceryRunDetail(),
    ocrReview: (context) => const OcrReview(),
    addGroceryRun: (context) => const AddGroceryRun(),
    addGroceryRunManual: (context) =>
        const AddGroceryRun(manualEntryOnly: true),
    receiptScanner: (context) => const ReceiptScanner(),
    dashboardHome: (context) => const DashboardHome(),
    // TODO: Add your other routes here
  };
}
