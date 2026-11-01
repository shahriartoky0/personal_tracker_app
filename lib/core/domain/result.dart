enum FailureCode { validation, notFound, conflict, forbidden, unexpected }

class Failure {
  const Failure(this.code, this.message, {this.fields = const {}});
  final FailureCode code;
  final String message;
  final Map<String, String> fields;

  factory Failure.validation(String message, {Map<String, String> fields = const {}}) =>
      Failure(FailureCode.validation, message, fields: fields);
  factory Failure.notFound(String message) => Failure(FailureCode.notFound, message);
  factory Failure.unexpected([String message = 'Something went wrong. Please try again.']) =>
      Failure(FailureCode.unexpected, message);

  @override
  String toString() => 'Failure($code, $message)';
}

sealed class Result<T> {
  const Result();
  bool get isOk => this is Ok<T>;
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };
  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final failure) => failure,
      };
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
