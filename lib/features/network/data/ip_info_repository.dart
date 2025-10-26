import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/ip_info.dart';

class IpInfoRepository {
  IpInfoRepository({http.Client? client}) : _client = client ?? http.Client();

  static const _endpoint = 'http://ip-api.com/json/';

  final http.Client _client;

  Future<IpInfo> fetchIpInfo() async {
    final uri = Uri.parse(_endpoint);
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Unexpected status: ${response.statusCode}',
        uri,
      );
    }
    final body = response.body;
    if (body.isEmpty) {
      throw const FormatException('Empty response body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return IpInfo.fromJson(data);
  }
}

final ipInfoRepositoryProvider = Provider<IpInfoRepository>((ref) {
  return IpInfoRepository();
});

final ipInfoProvider = FutureProvider.autoDispose<IpInfo>((ref) async {
  final repository = ref.watch(ipInfoRepositoryProvider);
  final info = await repository.fetchIpInfo();
  return info;
});
