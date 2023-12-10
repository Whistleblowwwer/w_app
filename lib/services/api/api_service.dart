import 'dart:isolate';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';

class ApiService {
  static final ApiService _singleton = ApiService._internal();
  late final ApiServerUtils _utils;

  factory ApiService() {
    return _singleton;
  }

  ApiService._internal() {
    var baseUrl = dotenv.env['API_BASE_URL']!;
    var userRepository = UserRepository();
    _utils = ApiServerUtils(baseUrl, userRepository);
  }

  Future<http.Response> createReview({
    required String content,
    required String idBusiness,
    required String idUser,
    required double rating,
  }) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      "content": content,
      "_id_business": idBusiness,
      "rating": rating
    };

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('reviews/?_id_user=$idUser', body);

    // Devolver la respuesta procesada
    return response;
  }

  Future<http.Response> createBusiness(
      {required String name,
      required String entity,
      required String country,
      required String state,
      required String city,
      required String category}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      "name": name,
      "address": "Galerias Monterrey",
      "entity": entity,
      "country": country,
      "state": state,
      "city": city,
      "category": category
    };

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('business', body);

    // Devolver la respuesta procesada
    return response;
  }

  Future<Map<String, dynamic>> commentReview(
      {required String content,
      required String idReview,
      String? idParent}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      "content": content,
      "_id_review": idReview,
      "_id_parent": idParent
    };

    // if (idParent != null) {
    //   body.addAll({});
    // }

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('comments', body);

    // Devolver la respuesta procesada
    return _utils.handleResponse(response);
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    var body = {'client_email': email, 'client_password': password};
    var response = await _utils.post('users/login', body);

    return _utils.handleResponse(response);
  }

  bool validateToken(String token) {
    return JwtDecoder.isExpired(token) == false;
  }

  Future<bool> validateAccesToken(String token) async {
    var response = await _utils.get('users/token');
    print(response.statusCode);
    return _utils.handleResponse(response)['success'];
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String lastName,
    required String phone,
    required String email,
    required String birthdate,
    required String password,
    required String gender,
    required String role,
  }) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      "name": name,
      "last_name": lastName,
      "email": email,
      "phone_number": phone,
      "birth_date": birthdate,
      "gender": gender,
      "password": password,
      "role": role
    };
    print(body);

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('users/', body);

    // Devolver la respuesta procesada
    return json.decode(response.body);
  }

  Future<bool> validateNumberSMS(String phoneNumber) async {
    try {
      var response = await _utils.get('users/sms');
      return _utils.handleResponse(response)['success'];
    } catch (e) {
      print("Error validating SMS: $e");
      return false; // o manejar de otra manera si es necesario
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    var response = await _utils.get('users/');
    print(response.statusCode);
    print("---------");
    print(_utils.handleResponse(response));
    return _utils.handleResponse(response);
  }

  Future<Business> getBusinessDetail(String idBusiness) async {
    try {
      var response =
          await _utils.get('business/details?_id_business=$idBusiness');
      print(response.statusCode);
      print(_utils.handleResponse(response));
      return Business.fromJson(_utils.handleResponse(response)["business"]);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<User> getProfileDetail(String idUser) async {
    try {
      var response = await _utils.get('users/?_id_user=$idUser');
      print(response.statusCode);
      print(_utils.handleResponse(response));
      return User.fromJson(_utils.handleResponse(response)["user"]);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Business>> getSearch(String name) async {
    try {
      var response = await _utils.get(
          'business/search?city=&enitty=&country=&address=&state=&name=$name');

      final List<dynamic> companyData =
          _utils.handleResponse(response)['businesses'];

      print(companyData);

      return companyData.map((data) => Business.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Review>> getReviews() async {
    List<dynamic> companyData = [];
    try {
      var response = await _utils.get('reviews/');
      print(response.statusCode);
      print("---a------a------");

      final hanldeResponse = _utils.handleResponse(response);

      if (hanldeResponse.containsKey('reviews')) {
        companyData = hanldeResponse['reviews'];
      }

      print(companyData);

      return companyData.map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Review>> getUserReviews(String idUser) async {
    try {
      var response = await _utils.get('users/reviews?_id_user=$idUser');
      print(response.statusCode);
      final List<dynamic> companyData =
          _utils.handleResponse(response)['reviews'];
      print("-----b-----b---");
      print(companyData);

      return companyData.map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Review>> getBusinessReviews(String idBusiness) async {
    try {
      var response =
          await _utils.get('reviews/business/?_id_business=$idBusiness');
      print(response.statusCode);
      final List<dynamic> companyData =
          _utils.handleResponse(response)['reviews'];
      print("-----b-----b---");
      print(companyData);

      return companyData.map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Comment>> getReviewsParentComments(String idReview) async {
    try {
      var response = await _utils.get('reviews/info/?_id_review=$idReview');
      print(response.statusCode);
      print("---a------a------");

      final List<dynamic> companyData =
          _utils.handleResponse(response)['Comments'];

      return companyData.map((data) => Comment.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Comment>> getCommentChildren(String idComment) async {
    try {
      var response =
          await _utils.get('comments/children/?_id_comment=$idComment');
      print(response.statusCode);
      print(response.body);
      print("---a------a------");

      final List<dynamic> companyData =
          _utils.handleResponse(response)['comment']["Comments"];

      return companyData.map((data) => Comment.fromJson(data)).toList();
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  //Actions

  Future<int> likeReview({required String idReview}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {};

    // Realizar la petición POST al endpoint para registrar usuarios
    var response =
        await _utils.post('users/reviews/like/?_id_review=$idReview', body);

    // Devolver la respuesta procesada
    return response.statusCode;
  }

  Future<int> likeComment({required String idComment}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {};

    // Realizar la petición POST al endpoint para registrar usuarios
    var response =
        await _utils.post('users/comments/like/?_id_comment=$idComment', body);

    // Devolver la respuesta procesada
    return response.statusCode;
  }

  Future<int> followUser({required String idFollowed}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {};

    // Realizar la petición POST al endpoint para registrar usuarios
    var response =
        await _utils.post('users/follow/?_id_followed=$idFollowed', body);

    // Devolver la respuesta procesada
    return response.statusCode;
  }

  Future<int> followBusiness({required String idBusiness}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {};

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post(
        'users/business/follow/?_id_business=$idBusiness', body);

    // Devolver la respuesta procesada
    return response.statusCode;
  }

  Future<dynamic> getChats() async{
    try {
      var response = await _utils.get('messages/conversations');
      print(response.statusCode);
      print("__________________");

      final List<dynamic> conversations =
          _utils.handleResponse(response)['conversations'];

      await Future.delayed(Duration(seconds: 1));

      return conversations;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> getConversationMessages(String id_receiver) async{
    try{
      print('SENDED: messages/?_id_receiver=$id_receiver');
      var response = await _utils.get('messages/?_id_receiver=$id_receiver');
      final List<dynamic> messages=
          _utils.handleResponse(response)['messages'];
      return messages;
    }catch(e) {
      return Future.error(e);
    }
  }
}

class ApiServerUtils {
  final String baseUrl;
  final UserRepository userRepository;

  ApiServerUtils(this.baseUrl, this.userRepository);

  Future<Map<String, String>> _getDefaultHeaders() async {
    final token = await userRepository.getToken();
    print(token);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> post(String endpoint, Map body) async {
    final headers = await _getDefaultHeaders();
    return await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getDefaultHeaders();
    return await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getDefaultHeaders();
    return await http.delete(Uri.parse('$baseUrl/$endpoint'), headers: headers);
  }

  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return json.decode(response.body);
      } catch (e) {
        // Si la respuesta no se puede decodificar a JSON
        throw Exception('Failed to decode the response: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Token is invalid or expired.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found.');
    } else if (response.statusCode == 500) {
      throw Exception('Server not found.');
    } else {
      throw Exception(
          'Request failed with status: ${response.statusCode}. Response: ${response.body}');
    }
  }
}
