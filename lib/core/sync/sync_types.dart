class SyncData<T> {
  final List<T> dataForSync;
  final List<T> deletedDataForSync;
  final bool hasMore;

  SyncData({required this.dataForSync, required this.hasMore, required this.deletedDataForSync});
  factory SyncData.empty() =>
      SyncData(dataForSync: [], hasMore: false, deletedDataForSync: []);
  List<T> get data => [...dataForSync, ...deletedDataForSync];
}

class PerformSyncStatus {
  final SyncManagerStatus status;
  final bool? isPremium;

  PerformSyncStatus({required this.status, required this.isPremium});
}

enum SyncManagerStatus {
  ok,
  notOk,
  alreadyRunning,
  notHasAccessToken,
  itsTooErarly,
  limitStorageReached,
  notConection,
  notConectionServer,
}