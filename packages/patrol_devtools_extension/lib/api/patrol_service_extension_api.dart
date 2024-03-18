import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';
import 'package:vm_service/vm_service.dart';

sealed class ApiResult<T> extends Equatable {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;

  bool get isFailure => this is ApiFailure<T>;
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];
}

class PatrolServiceExtensionApi {
  const PatrolServiceExtensionApi({
    required VmService service,
    required ValueListenable<IsolateRef?> isolate,
  })  : _isolate = isolate,
        _service = service;

  final VmService _service;
  final ValueListenable<IsolateRef?> _isolate;

  Future<ApiResult<GetNativeUITreeRespone>> getNativeUITree({
    required bool useNativeViewHierarchy,
  }) {
    return _callServiceExtension(
      'patrol.getNativeUITree',
      {'useNativeViewHierarchy': useNativeViewHierarchy ? 'yes' : 'no'},
      (dynamic json) =>
          GetNativeUITreeRespone.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<TResult>> _callServiceExtension<TResult>(
    String methodName,
    Map<String, dynamic> args,
    TResult Function(dynamic json) resultFactory,
  ) async {
    try {
      final extensionName = 'ext.flutter.$methodName';
      final r = await _service.callServiceExtension(
        extensionName,
        isolateId: _isolate.value!.id,
        args: args,
      );

      final json = r.json!;
      if (json['success'] != true) {
        return ApiFailure(json['success'] as String, null);
      }

      final res = resultFactory(json['result']);

      return ApiSuccess(res);
    } catch (err, st) {
      return ApiFailure(err, st);
    }
  }
}
