class ControllerResponse {
  final String? message;
  final ResponseStatusCode statusCode;
  final dynamic data;

  ControllerResponse({this.message, required this.statusCode, this.data});

  Map<String, dynamic> toJson() {
    return {'message': message, 'statusCode': statusCode, 'data': data};
  }

  T getData<T>() {
    if (data is T) {
      return data as T;
    } else {
      throw Exception(
        'Data type mismatch: expected $T, got ${data.runtimeType}',
      );
    }
  }
}

enum ResponseStatusCode { success, error, validationError }
