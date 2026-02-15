import 'dart:io' show Process, ProcessResult;

import 'package:developer_tools_network/network_inspector/helper/operating_system.dart';
import 'package:developer_tools_network/network_inspector/model/network_log.dart';
import 'package:rxdart/rxdart.dart';

/// Logger used to handle logs from application.
class NetworkLogger {
  /// Maximum logs size. If 0, logs will be not rotated.
  final int maximumSize;

  /// Subject which keeps logs.
  final BehaviorSubject<List<NetworkLog>> _logsSubject;

  NetworkLogger({required this.maximumSize})
    : _logsSubject = BehaviorSubject.seeded([]);

  /// Getter of stream of logs
  Stream<List<NetworkLog>> get logsStream => _logsSubject.stream;

  /// Getter of all logs
  List<NetworkLog> get logs => _logsSubject.value;

  /// Adds all logs.
  void addAll(Iterable<NetworkLog> logs) {
    for (var log in logs) {
      add(log);
    }
  }

  /// Add one log. It sorts logs after adding new element. If [maximumSize] is
  /// set and max size is reached, first log will be deleted.
  void add(NetworkLog log) {
    final values = _logsSubject.value;
    final count = values.length;
    if (maximumSize > 0 && count >= maximumSize) {
      values.removeAt(0);
    }

    values.add(log);
    values.sort((log1, log2) => log1.timestamp.compareTo(log2.timestamp));
    _logsSubject.add(values);
  }

  /// Clears all logs.
  void clearLogs() => _logsSubject.add([]);

  /// Returns raw logs from Android via ADB.
  Future<String> getAndroidRawLogs() async {
    if (OperatingSystem.isAndroid) {
      final ProcessResult process = await Process.run('logcat', [
        '-v',
        'raw',
        '-d',
      ]);
      return process.stdout as String;
    }
    return '';
  }

  /// Clears all raw logs.
  Future<void> clearAndroidRawLogs() async {
    if (OperatingSystem.isAndroid) {
      await Process.run('logcat', ['-c']);
    }
  }
}
