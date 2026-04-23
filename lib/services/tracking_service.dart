import 'package:petixfy/network/api_client.dart';

class TrackingService {
  TrackingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> patchVetLocation({
    required String trackingId,
    required double latitude,
    required double longitude,
    int? etaMinutes,
  }) async {
    await _apiClient.dio.patch(
      '/api/tracking/$trackingId/location',
      data: {
        'vet_lat': latitude,
        'vet_lng': longitude,
        if (etaMinutes != null) 'eta': etaMinutes,
      },
    );
  }

  Future<Map<String, dynamic>> getTrackingSession(String trackingId) async {
    final response = await _apiClient.dio.get('/api/tracking/$trackingId');
    return (response.data as Map).cast<String, dynamic>();
  }
}
