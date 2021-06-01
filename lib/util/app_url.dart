class AppUrl {
  static const String liveBaseURL = 'https://api.coingecko.com/api/v3';

  static const String baseURL = liveBaseURL;
  static const String summary =
      baseURL + '/exchanges/indodax/tickers?order=volume_desc';
}
