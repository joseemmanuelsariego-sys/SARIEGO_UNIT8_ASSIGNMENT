import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fair_event.dart';

// EXPLAIN E1: The screens only know this interface. They never import
// strapi_source.dart or contentful_source.dart. What would you have to change
// to move the app from one CMS to another, and what would stay the same?
abstract interface class EventSource {
  /// Shown in the drawer, e.g. 'Strapi'.
  String get name;

  Future<List<FairEvent>> fetchEvents();
}

/// A problem the user should read: no internet, wrong token, and so on.
class CmsException implements Exception {
  const CmsException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sends a GET request and gives back the decoded JSON.
/// Every CMS source uses it, so the error messages are the same everywhere.
Future<Object?> getJson(
  http.Client client,
  Uri uri, {
  required String cms,
  Map<String, String> headers = const {},
}) async {
  final http.Response response;

  try {
    response = await client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));
  } on TimeoutException {
    throw CmsException('$cms took too long to answer. Try again.');
  } on http.ClientException {
    throw const CmsException(
      'No connection. Check your internet and try again.',
    );
  }

  return decodeOrThrow(response, cms);
}

/// Turns an HTTP answer into JSON, or into a message the user can act on.
Object? decodeOrThrow(http.Response response, String cms) {
  final code = response.statusCode;

  // EXPLAIN E4: 401, 404 and 500 are all "errors", but who has to fix each
  // one: the user, you (the developer), or the people running the CMS?
  switch (code) {
    case 200:
      return jsonDecode(response.body);

    case 401 || 403:
      throw CmsException(
        '$cms refused the request ($code). Check your token and the read permission.',
      );

    case 404:
      throw CmsException(
        '$cms could not find the events (404). Check the URL and the content type name.',
      );

    case >= 500:
      throw CmsException('$cms is having problems ($code). Try again later.');

    default:
      throw CmsException('$cms answered $code.');
  }
}
