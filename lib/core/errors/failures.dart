import 'exceptions.dart';

/// Base failure class for the application
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;
  
  const Failure(this.message, {this.code, this.details});
  
  @override
  String toString() => 'Failure: $message';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && 
           other.message == message && 
           other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class NoInternetFailure extends NetworkFailure {
  const NoInternetFailure() : super('Sem conexão com a internet');
}

class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure() : super('Tempo limite excedido');
}

class ServerFailure extends NetworkFailure {
  const ServerFailure(super.message, {super.code, super.details});
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Credenciais inválidas');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('Usuário não encontrado');
}

class EmailAlreadyExistsFailure extends AuthFailure {
  const EmailAlreadyExistsFailure() : super('Email já está em uso');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('Senha muito fraca');
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('Email inválido');
}

class UserDisabledFailure extends AuthFailure {
  const UserDisabledFailure() : super('Usuário desabilitado');
}

class TooManyRequestsFailure extends AuthFailure {
  const TooManyRequestsFailure() : super('Muitas tentativas. Tente novamente mais tarde');
}

class RequiresRecentLoginFailure extends AuthFailure {
  const RequiresRecentLoginFailure() : super('Requer login recente');
}

/// Data related failures
class DataFailure extends Failure {
  const DataFailure(super.message, {super.code, super.details});
}

class NotFoundFailure extends DataFailure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends DataFailure {
  const ValidationFailure(super.message, {super.code, super.details});
}

class DuplicateFailure extends DataFailure {
  const DuplicateFailure(super.message);
}

class PermissionDeniedFailure extends DataFailure {
  const PermissionDeniedFailure() : super('Permissão negada');
}

class QuotaExceededFailure extends DataFailure {
  const QuotaExceededFailure() : super('Cota excedida');
}

/// File related failures
class FileFailure extends Failure {
  const FileFailure(super.message, {super.code, super.details});
}

class FileNotFoundFailure extends FileFailure {
  const FileNotFoundFailure() : super('Arquivo não encontrado');
}

class FileTooLargeFailure extends FileFailure {
  const FileTooLargeFailure() : super('Arquivo muito grande');
}

class UnsupportedFileTypeFailure extends FileFailure {
  const UnsupportedFileTypeFailure() : super('Tipo de arquivo não suportado');
}

class FileUploadFailure extends FileFailure {
  const FileUploadFailure(super.message);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}

class CacheNotFoundFailure extends CacheFailure {
  const CacheNotFoundFailure() : super('Dados não encontrados no cache');
}

class CacheExpiredFailure extends CacheFailure {
  const CacheExpiredFailure() : super('Dados do cache expirados');
}

/// Business logic failures
class BusinessFailure extends Failure {
  const BusinessFailure(super.message, {super.code, super.details});
}

class InsufficientPermissionsFailure extends BusinessFailure {
  const InsufficientPermissionsFailure() : super('Permissões insuficientes');
}

class ResourceNotFoundFailure extends BusinessFailure {
  const ResourceNotFoundFailure() : super('Recurso não encontrado');
}

class OperationNotAllowedFailure extends BusinessFailure {
  const OperationNotAllowedFailure() : super('Operação não permitida');
}

class RateLimitExceededFailure extends BusinessFailure {
  const RateLimitExceededFailure() : super('Limite de taxa excedido');
}

/// External service failures
class ExternalServiceFailure extends Failure {
  const ExternalServiceFailure(super.message, {super.code, super.details});
}

class GoogleMapsFailure extends ExternalServiceFailure {
  const GoogleMapsFailure(super.message);
}

class WeatherServiceFailure extends ExternalServiceFailure {
  const WeatherServiceFailure(super.message);
}

class TranslationServiceFailure extends ExternalServiceFailure {
  const TranslationServiceFailure(super.message);
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.details});
}

/// Failure factory
class FailureFactory {
  static Failure fromException(AppException exception) {
    switch (exception) {
      case NoInternetException _:
        return const NoInternetFailure();
      case TimeoutException _:
        return const TimeoutFailure();
      case ServerException _:
        return ServerFailure(exception.message, code: exception.code, details: exception.details);
      case InvalidCredentialsException _:
        return const InvalidCredentialsFailure();
      case UserNotFoundException _:
        return const UserNotFoundFailure();
      case EmailAlreadyExistsException _:
        return const EmailAlreadyExistsFailure();
      case WeakPasswordException _:
        return const WeakPasswordFailure();
      case InvalidEmailException _:
        return const InvalidEmailFailure();
      case UserDisabledException _:
        return const UserDisabledFailure();
      case TooManyRequestsException _:
        return const TooManyRequestsFailure();
      case RequiresRecentLoginException _:
        return const RequiresRecentLoginFailure();
      case NotFoundException _:
        return NotFoundFailure(exception.message);
      case ValidationException _:
        return ValidationFailure(exception.message, code: exception.code, details: exception.details);
      case DuplicateException _:
        return DuplicateFailure(exception.message);
      case PermissionDeniedException _:
        return const PermissionDeniedFailure();
      case QuotaExceededException _:
        return const QuotaExceededFailure();
      case FileNotFoundException _:
        return const FileNotFoundFailure();
      case FileTooLargeException _:
        return const FileTooLargeFailure();
      case UnsupportedFileTypeException _:
        return const UnsupportedFileTypeFailure();
      case FileUploadException _:
        return FileUploadFailure(exception.message);
      case CacheNotFoundException _:
        return const CacheNotFoundFailure();
      case CacheExpiredException _:
        return const CacheExpiredFailure();
      case InsufficientPermissionsException _:
        return const InsufficientPermissionsFailure();
      case ResourceNotFoundException _:
        return const ResourceNotFoundFailure();
      case OperationNotAllowedException _:
        return const OperationNotAllowedFailure();
      case RateLimitExceededException _:
        return const RateLimitExceededFailure();
      case GoogleMapsException _:
        return GoogleMapsFailure(exception.message);
      case WeatherServiceException _:
        return WeatherServiceFailure(exception.message);
      case TranslationServiceException _:
        return TranslationServiceFailure(exception.message);
      case UnknownException _:
        return UnknownFailure(exception.message, code: exception.code, details: exception.details);
      default:
        return UnknownFailure(exception.message, code: exception.code, details: exception.details);
    }
  }
  
  static Failure fromError(dynamic error) {
    if (error is AppException) {
      return fromException(error);
    }
    
    if (error is Exception) {
      return UnknownFailure(error.toString());
    }
    
    return UnknownFailure(error.toString());
  }
}

/// Result class for handling success and failure states
abstract class Result<T> {
  const Result();
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  Failure? get failure => isFailure ? (this as FailureResult<T>).failure : null;
  
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (isSuccess) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as FailureResult<T>).failure);
    }
  }
  
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(Failure failure)? failure,
    required R Function() orElse,
  }) {
    if (isSuccess && success != null) {
      return success((this as Success<T>).data);
    } else if (isFailure && failure != null) {
      return failure((this as FailureResult<T>).failure);
    } else {
      return orElse();
    }
  }
}

class Success<T> extends Result<T> {
  @override
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success($data)';
}

class FailureResult<T> extends Result<T> {
  @override
  final Failure failure;
  
  const FailureResult(this.failure);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FailureResult<T> && other.failure == failure;
  }
  
  @override
  int get hashCode => failure.hashCode;
  
  @override
  String toString() => 'FailureResult($failure)';
}
