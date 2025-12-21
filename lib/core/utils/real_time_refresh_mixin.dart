import 'dart:async';
import 'package:flutter/material.dart';

mixin RealTimeRefreshMixin<T extends StatefulWidget> on State<T> {
  Timer? _refreshTimer;
  bool _hasDataChanged = false;
  DateTime? _lastRefresh;

  void startRealTimeRefresh({Duration interval = const Duration(seconds: 30)}) {
    _refreshTimer = Timer.periodic(interval, (timer) {
      if (mounted && _shouldRefresh()) {
        refreshData();
        _lastRefresh = DateTime.now();
      }
    });
  }

  bool _shouldRefresh() {
    if (_lastRefresh == null) return true;
    return DateTime.now().difference(_lastRefresh!).inSeconds > 25;
  }

  void markDataChanged() {
    _hasDataChanged = true;
  }

  void stopRealTimeRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopRealTimeRefresh();
    super.dispose();
  }

  void refreshData();
}
