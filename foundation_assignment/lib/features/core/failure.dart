import 'package:flutter/foundation.dart';

abstract class Failures {
  debugPrintFailure(String failureMsg) {
    debugPrint(failureMsg);
  }
}

class ServerException extends Failures {
  String? exception;
  ServerException({this.exception});
}
