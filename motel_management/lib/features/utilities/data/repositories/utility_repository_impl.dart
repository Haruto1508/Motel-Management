import 'package:rental_management/features/utilities/data/datasources/utility_local_data_source.dart';
import 'package:rental_management/features/utilities/data/datasources/utility_remote_data_source.dart';
import 'package:rental_management/features/utilities/data/models/service_config_model.dart';
import 'package:rental_management/features/utilities/data/models/utility_reading_model.dart';
import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/repositories/utility_repository.dart';

class UtilityRepositoryImpl implements UtilityRepository {
  final UtilityRemoteDataSource remoteDataSource;
  final UtilityLocalDataSource localDataSource;

  UtilityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<UtilityReadingEntity>> getReadings({String? roomId, String? billingMonth}) async {
    try {
      final remoteList = await remoteDataSource.getReadings(
        roomId: roomId,
        billingMonth: billingMonth,
      );
      try {
        await localDataSource.cacheReadings(remoteList);
      } catch (_) {}
      return remoteList.map((m) => m.toEntity()).toList();
    } catch (_) {
      try {
        final cachedList = await localDataSource.getCachedReadings(
          roomId: roomId,
          billingMonth: billingMonth,
        );
        return cachedList.map((m) => m.toEntity()).toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<UtilityReadingEntity?> getLatestReading(String roomId) async {
    try {
      final remote = await remoteDataSource.getLatestReading(roomId);
      if (remote != null) {
        try {
          await localDataSource.saveReading(remote);
        } catch (_) {}
        return remote.toEntity();
      }
    } catch (_) {}

    try {
      final cached = await localDataSource.getLatestCachedReading(roomId);
      return cached?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UtilityReadingEntity> recordReading(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.recordReading(data);
      try {
        await localDataSource.saveReading(model);
      } catch (_) {}
      return model.toEntity();
    } catch (_) {
      final offlineId = 'offline_reading_${DateTime.now().millisecondsSinceEpoch}';
      final offlineMap = Map<String, dynamic>.from(data);
      offlineMap['id'] = offlineId;
      offlineMap['createdAt'] = DateTime.now().toIso8601String();

      final model = UtilityReadingModel.fromJson(offlineMap);
      try {
        await localDataSource.saveReading(model);
      } catch (_) {}
      return model.toEntity();
    }
  }

  @override
  Future<UtilityReadingEntity> updateReading(String id, Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.updateReading(id, data);
      try {
        await localDataSource.saveReading(model);
      } catch (_) {}
      return model.toEntity();
    } catch (_) {
      final offlineMap = Map<String, dynamic>.from(data);
      offlineMap['id'] = id;
      final model = UtilityReadingModel.fromJson(offlineMap);
      try {
        await localDataSource.saveReading(model);
      } catch (_) {}
      return model.toEntity();
    }
  }

  @override
  Future<void> deleteReading(String id) async {
    try {
      await remoteDataSource.deleteReading(id);
    } catch (_) {}
    try {
      await localDataSource.deleteCachedReading(id);
    } catch (_) {}
  }

  @override
  Future<List<ServiceConfigEntity>> getServices() async {
    try {
      final remoteServices = await remoteDataSource.getServices();
      try {
        await localDataSource.cacheServices(remoteServices);
      } catch (_) {}
      return remoteServices.map((m) => m.toEntity()).toList();
    } catch (_) {
      try {
        final cachedServices = await localDataSource.getCachedServices();
        return cachedServices.map((m) => m.toEntity()).toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<ServiceConfigEntity> updateService(String id, double unitPrice) async {
    try {
      final model = await remoteDataSource.updateService(id, unitPrice);
      try {
        await localDataSource.saveService(model);
      } catch (_) {}
      return model.toEntity();
    } catch (_) {
      try {
        final cached = await localDataSource.getCachedServices();
        final index = cached.indexWhere((s) => s.id == id);
        if (index != -1) {
          final updated = ServiceConfigModel(
            id: cached[index].id,
            name: cached[index].name,
            type: cached[index].type,
            unitPrice: unitPrice,
            unitName: cached[index].unitName,
            isActive: cached[index].isActive,
          );
          try {
            await localDataSource.saveService(updated);
          } catch (_) {}
          return updated.toEntity();
        }
      } catch (_) {}
      throw Exception('Service not found');
    }
  }
}
