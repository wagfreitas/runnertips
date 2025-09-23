/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const AppException(this.message, {this.code, this.details});
  
  @override
  String toString() => 'AppException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class NoInternetException extends NetworkException {
  const NoInternetException() : super('Sem conexão com a internet');
}

class TimeoutException extends NetworkException {
  const TimeoutException() : super('Tempo limite excedido');
}

class ServerException extends NetworkException {
  const ServerException(super.message, {super.code, super.details});
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Credenciais inválidas');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('Usuário não encontrado');
}

class EmailAlreadyExistsException extends AuthException {
  const EmailAlreadyExistsException() : super('Email já está em uso');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException() : super('Senha muito fraca');
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('Email inválido');
}

class UserDisabledException extends AuthException {
  const UserDisabledException() : super('Usuário desabilitado');
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException() : super('Muitas tentativas. Tente novamente mais tarde');
}

class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException() : super('Requer login recente');
}

/// Data related exceptions
class DataException extends AppException {
  const DataException(super.message, {super.code, super.details});
}

class NotFoundException extends DataException {
  const NotFoundException(super.message);
}

class ValidationException extends DataException {
  const ValidationException(super.message, {super.code, super.details});
}

class DuplicateException extends DataException {
  const DuplicateException(super.message);
}

class PermissionDeniedException extends DataException {
  const PermissionDeniedException() : super('Permissão negada');
}

class QuotaExceededException extends DataException {
  const QuotaExceededException() : super('Cota excedida');
}

/// File related exceptions
class FileException extends AppException {
  const FileException(super.message, {super.code, super.details});
}

class FileNotFoundException extends FileException {
  const FileNotFoundException() : super('Arquivo não encontrado');
}

class FileTooLargeException extends FileException {
  const FileTooLargeException() : super('Arquivo muito grande');
}

class UnsupportedFileTypeException extends FileException {
  const UnsupportedFileTypeException() : super('Tipo de arquivo não suportado');
}

class FileUploadException extends FileException {
  const FileUploadException(super.message);
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});
}

class CacheNotFoundException extends CacheException {
  const CacheNotFoundException() : super('Dados não encontrados no cache');
}

class CacheExpiredException extends CacheException {
  const CacheExpiredException() : super('Dados do cache expirados');
}

/// Business logic exceptions
class BusinessException extends AppException {
  const BusinessException(super.message, {super.code, super.details});
}

class InsufficientPermissionsException extends BusinessException {
  const InsufficientPermissionsException() : super('Permissões insuficientes');
}

class ResourceNotFoundException extends BusinessException {
  const ResourceNotFoundException() : super('Recurso não encontrado');
}

class OperationNotAllowedException extends BusinessException {
  const OperationNotAllowedException() : super('Operação não permitida');
}

class RateLimitExceededException extends BusinessException {
  const RateLimitExceededException() : super('Limite de taxa excedido');
}

/// External service exceptions
class ExternalServiceException extends AppException {
  const ExternalServiceException(super.message, {super.code, super.details});
}

class GoogleMapsException extends ExternalServiceException {
  const GoogleMapsException(super.message);
}

class WeatherServiceException extends ExternalServiceException {
  const WeatherServiceException(super.message);
}

class TranslationServiceException extends ExternalServiceException {
  const TranslationServiceException(super.message);
}

/// Unknown exception
class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.details});
}

/// Exception factory
class ExceptionFactory {
  static AppException fromError(dynamic error) {
    if (error is AppException) {
      return error;
    }
    
    if (error is Exception) {
      final message = error.toString();
      
      // Network errors
      if (message.contains('SocketException') || message.contains('NetworkException')) {
        return const NoInternetException();
      }
      
      if (message.contains('TimeoutException')) {
        return const TimeoutException();
      }
      
      if (message.contains('ServerException')) {
        return ServerException(message);
      }
      
      // Auth errors
      if (message.contains('InvalidCredentialsException')) {
        return const InvalidCredentialsException();
      }
      
      if (message.contains('UserNotFoundException')) {
        return const UserNotFoundException();
      }
      
      if (message.contains('EmailAlreadyExistsException')) {
        return const EmailAlreadyExistsException();
      }
      
      if (message.contains('WeakPasswordException')) {
        return const WeakPasswordException();
      }
      
      if (message.contains('InvalidEmailException')) {
        return const InvalidEmailException();
      }
      
      if (message.contains('UserDisabledException')) {
        return const UserDisabledException();
      }
      
      if (message.contains('TooManyRequestsException')) {
        return const TooManyRequestsException();
      }
      
      if (message.contains('RequiresRecentLoginException')) {
        return const RequiresRecentLoginException();
      }
      
      // Data errors
      if (message.contains('NotFoundException')) {
        return NotFoundException(message);
      }
      
      if (message.contains('ValidationException')) {
        return ValidationException(message);
      }
      
      if (message.contains('DuplicateException')) {
        return DuplicateException(message);
      }
      
      if (message.contains('PermissionDeniedException')) {
        return const PermissionDeniedException();
      }
      
      if (message.contains('QuotaExceededException')) {
        return const QuotaExceededException();
      }
      
      // File errors
      if (message.contains('FileNotFoundException')) {
        return const FileNotFoundException();
      }
      
      if (message.contains('FileTooLargeException')) {
        return const FileTooLargeException();
      }
      
      if (message.contains('UnsupportedFileTypeException')) {
        return const UnsupportedFileTypeException();
      }
      
      if (message.contains('FileUploadException')) {
        return FileUploadException(message);
      }
      
      // Cache errors
      if (message.contains('CacheNotFoundException')) {
        return const CacheNotFoundException();
      }
      
      if (message.contains('CacheExpiredException')) {
        return const CacheExpiredException();
      }
      
      // Business errors
      if (message.contains('InsufficientPermissionsException')) {
        return const InsufficientPermissionsException();
      }
      
      if (message.contains('ResourceNotFoundException')) {
        return const ResourceNotFoundException();
      }
      
      if (message.contains('OperationNotAllowedException')) {
        return const OperationNotAllowedException();
      }
      
      if (message.contains('RateLimitExceededException')) {
        return const RateLimitExceededException();
      }
      
      // External service errors
      if (message.contains('GoogleMapsException')) {
        return GoogleMapsException(message);
      }
      
      if (message.contains('WeatherServiceException')) {
        return WeatherServiceException(message);
      }
      
      if (message.contains('TranslationServiceException')) {
        return TranslationServiceException(message);
      }
    }
    
    // Default to unknown exception
    return UnknownException(error.toString());
  }
}
