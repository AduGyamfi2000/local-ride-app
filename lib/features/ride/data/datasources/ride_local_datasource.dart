import '../models/ride_model.dart';

abstract class RideLocalDatasource {
  Future<void> cacheRide(RideModel ride);
  Future<void> saveRideHistory(List<RideModel> rides);
  Future<List<RideModel>> getRideHistory(String userId);
  Future<RideModel?> getCachedActiveRide(String userId);
}

class RideLocalDatasourceImpl implements RideLocalDatasource {
  @override
  Future<void> cacheRide(RideModel ride) async {
    // Implementation: use hive/sqflite
  }

  @override
  Future<void> saveRideHistory(List<RideModel> rides) async {
    // Implementation: save to local db
  }

  @override
  Future<List<RideModel>> getRideHistory(String userId) async {
    return [];
  }

  @override
  Future<RideModel?> getCachedActiveRide(String userId) async {
    return null;
  }
}
