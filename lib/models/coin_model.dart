class CoinModel {
  final String id;
  final String base;
  final String target;
  final double last;
  final String coinId;

  CoinModel({
    this.id,
    this.base,
    this.target,
    this.last,
    this.coinId,
  });

  factory CoinModel.fromJson(Map<String, dynamic> jsonData) {
    return CoinModel(
      id: jsonData['base'] + jsonData['target'],
      base: jsonData['base'],
      target: jsonData['target'],
      last: jsonData['last'],
      coinId: jsonData['coin_id'],
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'base': base,
      'target': target,
      'last': last,
      'coin_id': coinId
    };
  }
}
