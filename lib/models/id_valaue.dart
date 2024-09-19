import 'package:get/get.dart';

class IdAndValue<T> {
  String id;
  T value;

  IdAndValue({required this.id, required this.value});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdAndValue &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ value.hashCode;

  @override
  String toString() {
    return this.value.toString();
  }
}

extension RxObjectMixinExt<T> on RxObjectMixin<T> {
  void valueFromLast(T Function(T) onCopy) {
    value = onCopy(value);
  }
}
