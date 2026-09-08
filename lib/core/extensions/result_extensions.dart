import '../error/failure.dart';
import '../error/result.dart';

extension FutureResultX<T> on Future<Result<T>> {
  /// Await, then run one of the callbacks.
  Future<R> thenWhen<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) async => (await this).when(ok: ok, err: err);

  /// Await and map the success value.
  Future<Result<R>> mapOk<R>(R Function(T value) transform) async =>
      (await this).map(transform);
}

extension ResultIterableX<T> on Iterable<Result<T>> {
  /// `Ok([...])` if every element is `Ok`, else the first `Err`.
  Result<List<T>> collect() {
    final values = <T>[];
    for (final r in this) {
      switch (r) {
        case Ok<T>(:final value):
          values.add(value);
        case Err<T>(:final failure):
          return Err<List<T>>(failure);
      }
    }
    return Ok<List<T>>(values);
  }
}
