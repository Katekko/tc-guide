import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:tc_flutter_web/core/config/contact_config.dart';

import '../../domain/entities/feedback_request.dart';
import '../../domain/repositories/feedback_repository.dart';

/// [FeedbackRepository] that delivers messages by email through Web3Forms.
///
/// Web3Forms is a backend-less form service: the request is POSTed straight
/// from the browser to their API, which emails `contact@gyanburuworld.com`. No
/// server of our own is involved, which suits the static GitHub Pages hosting.
class FeedbackRepositoryImpl implements FeedbackRepository {
  /// Creates the repository, optionally injecting an [http.Client] and an
  /// [accessKey] override (used by tests). In production the key comes from
  /// [ContactConfig.web3formsAccessKey].
  FeedbackRepositoryImpl({http.Client? client, String? accessKey})
      : _client = client ?? http.Client(),
        _accessKey = accessKey ?? ContactConfig.web3formsAccessKey;

  final http.Client _client;
  final String _accessKey;

  @override
  Future<void> send(FeedbackRequest request) async {
    if (_accessKey.isEmpty) {
      throw const FeedbackException('Email delivery is not configured.');
    }

    final email = request.email?.trim();
    final payload = <String, dynamic>{
      'access_key': _accessKey,
      'subject': '[TC Guide] ${request.category.key}: ${request.title}',
      'from_name': 'TC Guide Feedback',
      'category': request.category.key,
      'title': request.title,
      'page': request.pageRoute ?? '-',
      'locale': request.locale ?? '-',
      'message': request.body,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    late final http.Response response;
    try {
      response = await _client.post(
        Uri.parse(ContactConfig.web3formsEndpoint),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
    } on Exception catch (error) {
      throw FeedbackException('Network error: $error');
    }

    if (response.statusCode != 200) {
      throw FeedbackException('Request failed (HTTP ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? 'Unknown error.'
          : 'Unexpected response.';
      throw FeedbackException(message);
    }
  }
}
