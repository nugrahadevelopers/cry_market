import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cry_market/models/coin_model.dart';

class DatabaseHandler {
  Future<Database> initDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'coins.db'),
      onCreate: (database, version) async {
        await database.execute(
            "CREATE TABLE coins(id TEXT PRIMARY KEY NOT NULL, base TEXT NOT NULL, target TEXT NOT NULL, last double NOT NULL, coin_id TEXT NOT NULL)");
      },
      version: 1,
    );
  }

  Future<int> insertCoin(List<CoinModel> coins) async {
    int result = 0;
    final Database db = await initDB();
    for (var coin in coins) {
      try {
        if (coin.target != 'USDT') {
          result = await db.insert('coins', coin.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } catch (error) {
        print('Error insert db : $error');
      }
    }
    return result;
  }

  Future<int> updateCoin(List<CoinModel> coins) async {
    int result = 0;
    final Database db = await initDB();
    for (var coin in coins) {
      try {
        if (coin.target != 'USDT') {
          result = await db.update('coins', coin.toMap(),
              where: 'id = ?', whereArgs: [coin.id]);
        }
      } catch (error) {
        print('Error update db : $error');
      }
    }
    return result;
  }

  deleteAllCoin() async {
    final Database db = await initDB();
    db.delete('coins');
  }

  Future<List<CoinModel>> retrieveCoin() async {
    final Database db = await initDB();
    final List<Map<String, Object>> queryResult = await db.query('coins');
    return queryResult.map((e) => CoinModel.fromJson(e)).toList();
  }
}
