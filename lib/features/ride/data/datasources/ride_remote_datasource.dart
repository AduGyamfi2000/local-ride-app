import '../models/ride_model.dart';
import 'ride_api_client.dart';

abstract class RideRemoteDatasource {
  Future<RideModel> requestRide(RideModel ride);
  Future<List<RideModel>> getRideHistory(String userId);
  Stream<RideModel> getRideStream(String rideId);
}

class RideRemoteDatasourceImpl implements RideRemoteDatasource {
  final RideApiClient apiClient;

  RideRemoteDatasourceImpl({RideApiClient? apiClient})
      : apiClient = apiClient ?? RideApiClient(
          apiClient: throw Exception('ApiClient required'),
          token: '',
        );

  @override
  Future<RideModel> requestRide(RideModel ride) async {
    return apiClient.requestRide(ride);
  }

  @override
  Future<List<RideModel>> getRideHistory(String userId) async {
    return apiClient.getRideHistory(userId);
  }

  @override
  Stream<RideModel> getRideStream(String rideId) {
    return const Stream.empty();
  }
}

