import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cry_market/models/coin_model.dart';
import 'package:cry_market/services/database_handler.dart';
import 'package:cry_market/util/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // PriceModel coinPrice;
  bool isLoading = false;
  DatabaseHandler handler;
  TextEditingController editingController = TextEditingController();

  List<CoinModel> list = [];
  List<CoinModel> filteredList = [];
  bool doItJustOnce = false;

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initDB().whenComplete(() async {
      setState(() {
        isLoading = true;
      });
      this.handler.deleteAllCoin();
      await _fetchCoin();
      setState(() {
        isLoading = false;
      });
    });

    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  int page = 2;

  Future<int> _fetchCoin() async {
    var myUrl = Uri.parse(
        'https://api.coingecko.com/api/v3/exchanges/indodax/tickers?page=$page&order=volume_desc');
    var response = await http.get(myUrl);

    if (response.statusCode == 200) {
      try {
        List jsonObject = json.decode(response.body)['tickers'];

        return await this
            .handler
            .insertCoin(jsonObject.map((e) => CoinModel.fromJson(e)).toList());
      } catch (error) {
        print('Error: $error');
        return null;
      }
    } else {
      throw Exception('Failed to Load Coin from API');
    }
  }

  Future<int> _updateCoin() async {
    var myUrl = Uri.parse(AppUrl.summary);
    var response = await http.get(myUrl);

    if (response.statusCode == 200) {
      try {
        List jsonObject = json.decode(response.body)['tickers'];

        return await this
            .handler
            .updateCoin(jsonObject.map((e) => CoinModel.fromJson(e)).toList());
      } catch (error) {
        print('Error: $error');
        return null;
      }
    } else {
      throw Exception('Failed to Load Coin from API');
    }
  }

  ListView _coinListView(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
              amount: data[index].last,
              settings: MoneyFormatterSettings(
                symbol: 'IDR',
                thousandSeparator: '.',
                decimalSeparator: ',',
                symbolAndNumberSeparator: ' ',
              ));

          return _tile(data[index].base, data[index].target,
              fmf.output.symbolOnLeft, data[index].coinId);
        });
  }

  ListTile _tile(
      String coinname, String tickerid, String lastPrice, String iconLogo) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Text(coinname,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              )),
          Text(' $tickerid' ?? 'Kok Kosong'),
        ],
      ),
      subtitle: Text(lastPrice ?? 'Kok Kosong'),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            'https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('Updating Coin');
          setState(() {
            isLoading = true;
          });
          await _updateCoin();
          setState(() {
            isLoading = false;
          });
        },
        child: Icon(Icons.refresh),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: size.height * 0.2,
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 36 + 20.0,
                    ),
                    height: size.height * 0.2 - 27,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Coin Market Price',
                          style: Theme.of(context).textTheme.headline5.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 50,
                            color: Colors.blue.withOpacity(0.23),
                          ),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    filteredList = list;
                                  });
                                }

                                _filteredList(value);
                              },
                              controller: editingController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: Colors.blue.withOpacity(0.5),
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.search,
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: buildFutureBuilder(),
            ),
          ],
        ),
      ),
    );
  }

  void _filteredList(value) {
    setState(() {
      filteredList = list
          .where((element) =>
              element.base.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  FutureBuilder<List<CoinModel>> buildFutureBuilder() {
    return FutureBuilder(
        future: this.handler.retrieveCoin(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!doItJustOnce) {
              list = snapshot.data;
              filteredList = list;
              doItJustOnce = !doItJustOnce;
            }

            return !isLoading
                ? _coinListView(filteredList)
                : Center(
                    child: CircularProgressIndicator(),
                  );
          } else {
            return Text("${snapshot.error}");
          }
        });
  }
}
