import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(
        BaseOptions(
          baseUrl: 'https://fcm.googleapis.com',
          receiveDataWhenStatusError: true,
        ));
  }
  static Future<Response> postData({
    Map<String, dynamic> ?data
  }) async
  {
    dio.options.headers =
    {
      'Content-Type': 'application/json',
      'Authorization': 'key = AAAAL9QmlJQ:APA91bGvhGb88Tkpyz7KrkJsiRmiNhP1KOv945nw7oNFnRtpCRuXhooDbF7y9HjvRiJNiDrO473T2wdbMEJV_POWajOn87Jfiy5IjUdQbsvhxpnGDlhvVhQ56ztc9rOTl7G2__uX-KkG '
    };
    return await dio.post(
      'https://fcm.googleapis.com/fcm/send',
      data: data,
    );
  }
}