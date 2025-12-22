import 'dart:async';
import 'package:flutter/material.dart';

mixin RealTimeRefreshMixin<T extends StatefulWidget> on State<T> {
  Timer? _refreshTimer;
  
  void startRealTimeRefresh({Duration interval = const Duration(seconds: 30)}) {
    _refreshTimer = Timer.periodic(interval, (_) {
      if (mounted) {
        refreshData();
      }
    });
  }
  
  void stopRealTimeRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  void refreshData() {
    // Override this method in implementing classes
  }
  
  @override
  void dispose() {
    stopRealTimeRefresh();
    super.dispose();
  }
}