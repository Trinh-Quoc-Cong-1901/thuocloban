import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/env_config.dart';
import '../../utils/logger_utils.dart';
import '../../utils/network_utils.dart';
import './storage_provider.dart';
import './cache_manager.dart';

class ApiProvider {
  late Dio _dio;
  final String baseUrl = '';
  final bool enableLogging;
  final CacheManager _cacheManager = CacheManager();
  final StorageProvider _storageProvider = StorageProvider();

  // Default cache expiration in hours
  final int _defaultCacheExpiration = 720;

  // Singleton pattern
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;

  ApiProvider._internal({this.enableLogging = false}) {
    _init();
  }

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.isEmpty ? EnvConfig.apiUrl : baseUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
        sendTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // SSL certificate handling removed for compatibility

    if (enableLogging && !EnvConfig.isProduction) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
        ),
      );
    }

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _storageProvider.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Cache configuration via headers
          final String cacheControl = options.headers['cache-control'] ?? '';
          if (cacheControl.contains('no-cache')) {
            options.extra['no-cache'] = true;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Cache the response if not explicitly disabled
          _cacheResponseIfApplicable(response);
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Handle token refresh
          if (e.response?.statusCode == 401) {
            // Implement token refresh logic
            // if (await refreshToken()) {
            //   return handler.resolve(await _retry(e.requestOptions));
            // }
          }

          // Try to return cached data on error (offline mode)
          if (e.type == DioExceptionType.connectionError ||
              e.error is SocketException ||
              !NetworkUtils.hasConnection) {
            final cachedData = _getCachedResponse(e.requestOptions);
            if (cachedData != null) {
              LoggerUtils.info(
                'Returning cached data for offline request: ${e.requestOptions.path}',
              );
              return handler.resolve(cachedData);
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  // Cache a response
  void _cacheResponseIfApplicable(Response response) {
    try {
      final RequestOptions requestOptions = response.requestOptions;

      // Skip caching if explicitly disabled or for non-GET requests
      if (requestOptions.method != 'GET' ||
          requestOptions.extra['no-cache'] == true) {
        return;
      }

      // Generate a cache key from the request
      final cacheKey = _getCacheKey(requestOptions);

      // Cache the response
      _cacheManager.cacheData(cacheKey, {
        'data': response.data,
        'headers': response.headers.map,
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
      }, expirationHours: _defaultCacheExpiration);
    } catch (e) {
      LoggerUtils.error('Failed to cache response', e);
    }
  }

  // Get a cached response
  Response? _getCachedResponse(RequestOptions requestOptions) {
    try {
      // Only return cache for GET requests
      if (requestOptions.method != 'GET') {
        return null;
      }

      final cacheKey = _getCacheKey(requestOptions);
      final cachedData = _cacheManager.getCachedData(cacheKey);

      if (cachedData != null) {
        return Response(
          data: cachedData['data'],
          headers: Headers.fromMap(cachedData['headers'] ?? {}),
          requestOptions: requestOptions,
          statusCode: cachedData['statusCode'] ?? 200,
          statusMessage: cachedData['statusMessage'],
          isRedirect: false,
        );
      }

      return null;
    } catch (e) {
      LoggerUtils.error('Failed to get cached response', e);
      return null;
    }
  }

  // Generate a cache key for a request
  String _getCacheKey(RequestOptions requestOptions) {
    final params =
        requestOptions.queryParameters.isNotEmpty
            ? requestOptions.queryParameters.entries
                .map((e) => '${e.key}=${e.value}')
                .join('&')
            : '';
    return '${requestOptions.method}:${requestOptions.path}${params.isNotEmpty ? "?$params" : ""}';
  }

  // Retry request with new token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // GET request with offline support
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool forceRefresh = false,
  }) async {
    try {
      // Set caching options
      final requestOptions = options ?? Options();
      if (forceRefresh) {
        requestOptions.headers = {
          ...requestOptions.headers ?? {},
          'cache-control': 'no-cache',
        };
      }

      // Check connectivity
      final hasNetwork = NetworkUtils.hasConnection;
      // If offline and cached data exists, return it
      if (!hasNetwork && !forceRefresh) {
        final cacheKey = _getCacheKey(
          RequestOptions(
            path: path,
            method: 'GET',
            queryParameters: queryParameters,
          ),
        );

        final cachedData = _cacheManager.getCachedData(cacheKey);
        if (cachedData != null) {
          LoggerUtils.info('Using cached data for offline request: $path');
          return Response(
            data: cachedData['data'],
            requestOptions: RequestOptions(path: path),
            statusCode: cachedData['statusCode'] ?? 200,
            statusMessage: cachedData['statusMessage'],
            isRedirect: false,
          );
        }
      }

      // Make the network request
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('GET Error: $e');
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Check connectivity if needed
      if (!NetworkUtils.hasConnection) {
        // Option 1: Queue for later submission
        // _queueOfflineRequest('POST', path, data, queryParameters);
        // return Response(
        //   data: {'message': 'Request queued for offline processing'},
        //   requestOptions: RequestOptions(path: path),
        //   statusCode: 202,
        // );

        // Option 2: Throw exception
        throw NoInternetConnectionException(RequestOptions(path: path));
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('POST Error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Check connectivity if needed
      if (!NetworkUtils.hasConnection) {
        // Option 1: Queue for later submission
        // _queueOfflineRequest('PUT', path, data, queryParameters);
        // return Response(
        //   data: {'message': 'Request queued for offline processing'},
        //   requestOptions: RequestOptions(path: path),
        //   statusCode: 202,
        // );

        // Option 2: Throw exception
        throw NoInternetConnectionException(RequestOptions(path: path));
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('PUT Error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // Check connectivity if needed
      if (!NetworkUtils.hasConnection) {
        // Option 1: Queue for later submission
        // _queueOfflineRequest('DELETE', path, data, queryParameters);
        // return Response(
        //   data: {'message': 'Request queued for offline processing'},
        //   requestOptions: RequestOptions(path: path),
        //   statusCode: 202,
        // );

        // Option 2: Throw exception
        throw NoInternetConnectionException(RequestOptions(path: path));
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('DELETE Error: $e');
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Check connectivity if needed
      if (!NetworkUtils.hasConnection) {
        // Option 1: Queue for later submission
        // _queueOfflineRequest('PATCH', path, data, queryParameters);
        // return Response(
        //   data: {'message': 'Request queued for offline processing'},
        //   requestOptions: RequestOptions(path: path),
        //   statusCode: 202,
        // );

        // Option 2: Throw exception
        throw NoInternetConnectionException(RequestOptions(path: path));
      }

      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('PATCH Error: $e');
      rethrow;
    }
  }

  // Invalidate cache for a specific endpoint
  Future<void> invalidateCache(
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) async {
    final cacheKey = _getCacheKey(
      RequestOptions(
        path: path,
        method: 'GET',
        queryParameters: queryParameters,
      ),
    );
    await _cacheManager.removeCachedData(cacheKey);
    LoggerUtils.debug('Cache invalidated for: $path');
  }

  // Clear all cached responses
  Future<void> clearCache() async {
    await _cacheManager.clearAllCachedData();
    LoggerUtils.debug('All API cache cleared');
  }

  // Handle Dio errors
  dynamic _handleError(DioException e) {
    LoggerUtils.error('Dio Error: $e');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(e.requestOptions);
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            throw BadRequestException(e.requestOptions, e.response);
          case 401:
            throw UnauthorizedException(e.requestOptions, e.response);
          case 403:
            throw ForbiddenException(e.requestOptions, e.response);
          case 404:
            throw NotFoundException(e.requestOptions, e.response);
          case 409:
            throw ConflictException(e.requestOptions, e.response);
          case 500:
            throw InternalServerErrorException(e.requestOptions, e.response);
        }
        throw ServerException(e.requestOptions, e.response);
      case DioExceptionType.cancel:
        throw RequestCancelledException(e.requestOptions);
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(e.requestOptions);
      case DioExceptionType.badCertificate:
        throw BadCertificateException(e.requestOptions);
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          throw NoInternetConnectionException(e.requestOptions);
        }
        throw UnexpectedException(e.requestOptions);
    }
  }

  // Queue a request for offline processing
  // Future<void> _queueOfflineRequest(
  //   String method,
  //   String path,
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  // ) async {
  //   // Implementation for offline queue
  //   // Store request in a database/queue for later submission
  // }
}

// Custom exceptions
class AppException extends DioException {
  AppException(RequestOptions requestOptions, {super.response})
    : super(requestOptions: requestOptions);
}

class BadRequestException extends AppException {
  BadRequestException(super.requestOptions, Response? response)
    : super(response: response);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.requestOptions, Response? response)
    : super(response: response);
}

class ForbiddenException extends AppException {
  ForbiddenException(super.requestOptions, Response? response)
    : super(response: response);
}

class NotFoundException extends AppException {
  NotFoundException(super.requestOptions, Response? response)
    : super(response: response);
}

class ConflictException extends AppException {
  ConflictException(super.requestOptions, Response? response)
    : super(response: response);
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException(super.requestOptions, Response? response)
    : super(response: response);
}

class NoInternetConnectionException extends AppException {
  NoInternetConnectionException(super.requestOptions) : super(response: null);
}

class DeadlineExceededException extends AppException {
  DeadlineExceededException(super.requestOptions) : super(response: null);
}

class BadCertificateException extends AppException {
  BadCertificateException(super.requestOptions) : super(response: null);
}

class RequestCancelledException extends AppException {
  RequestCancelledException(super.requestOptions) : super(response: null);
}

class ServerException extends AppException {
  ServerException(super.requestOptions, Response? response)
    : super(response: response);
}

class UnexpectedException extends AppException {
  UnexpectedException(super.requestOptions) : super(response: null);
}
