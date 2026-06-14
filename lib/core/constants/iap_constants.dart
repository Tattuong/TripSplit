class IapConstants {
  IapConstants._();

  static const String appCode = 'T106';
  static const String productPrefix = 'ts';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/T106.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'ts_pack_1',
    'ts_pack_2',
    'ts_pack_3',
    'ts_pack_4',
    'ts_pack_5',
    'ts_pack_6',
    'ts_pack_7',
    'ts_pack_8',
    'ts_pack_9',
    'ts_pack_10',
  ];

  static const List<int> coinPackAmounts = [
    50,
    100,
    200,
    350,
    500,
    750,
    1000,
    1500,
    2200,
    3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static const int freeTripLimit = 3;
  static const int dailyLoginReward = 10;
  static const int settlementReward = 8;
  static const int maxSettlementRewardsPerDay = 3;
}
