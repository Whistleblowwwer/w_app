import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
      required String iso2Country,
      required String country,
      required String iso2State,
      required String state,
      required String city,
      required String category}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      "name": name,
      "address": "tec",
      "entity": entity,
      "country": country,
      "iso2_country_code": iso2Country,
      "state": state,
      "iso2_state_code": iso2State,
      "city": city,
      "category": category
    };

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('business', body);

    // Devolver la respuesta procesada
    return response;
  }

  Future<Comment> commentReview(
      {required String content,
      required String idReview,
      String? idParent}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      "content": content,
      "_id_review": idReview,
      "_id_parent": idParent
    };

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('comments', body);
    final comment = await _utils.handleResponse(response)["comment"];

    // Devolver la respuesta procesada
    return Comment.fromJson(comment);
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    var body = {'client_email': email, 'client_password': password};
    var response = await _utils.post('users/login', body);

    return json.decode(response.body);
  }

  Future<bool> validateAccesToken(String token) async {
    var response = await _utils.get('users/token');

    return _utils.handleResponse(response)['success'];
  }

  Future<bool> requestOTP(String email) async {
    try {
      var response = await _utils.get('users/send-otp/?email=$email');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false; // o manejar de otra manera si es necesario
    }
  }

  Future<bool> validateOTP(String code, String email) async {
    print(code);
    print(email);
    try {
      var response = await _utils.post('users/validate-otp',
          {"code": double.tryParse(code), "email": email});
      print('a');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error validating SMS: $e");
      return false; // o manejar de otra manera si es necesario
    }
  }

  Future<Map<String, dynamic>> createUser({
    String? userName,
    required String name,
    required String lastName,
    String? phone,
    required String email,
    required String birthdate,
    required String password,
    String? gender,
    required String role,
  }) async {
    // Construir el cuerpo del POST request condicionalmente
    var body = {
      "name": name,
      "last_name": lastName,
      "email": email,
      "birth_date": birthdate,
      "password": password,
      "role": role,
    };

    if (userName != null && userName.isNotEmpty) {
      body["nick_name"] = userName;
    }
    if (phone != null && phone.isNotEmpty) {
      body["phone_number"] = phone;
    }
    if (gender != null && gender.isNotEmpty) {
      body["gender"] = gender;
    }

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('users/', body);

    // Devolver la respuesta procesada
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    var response = await _utils.get('users/');
    return _utils.handleResponse(response);
  }

  Future<Business> getBusinessDetail(String idBusiness) async {
    try {
      var response =
          await _utils.get('business/details?_id_business=$idBusiness');
      return Business.fromJson(_utils.handleResponse(response)["business"]);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<User> getProfileDetail(String idUser) async {
    try {
      var response = await _utils.get('users/?_id_user=$idUser');
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

      return companyData.map((data) => Business.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> getSearchUsers(String name) async {
    try {
      var response = await _utils.get('users/search?searchTerm=$name');

      final List<dynamic> companyData =
          _utils.handleResponse(response)['users'];

      return companyData.map((data) => User.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Review>> getReviews() async {
    List<dynamic> companyData = [];
    try {
      var response = await _utils.get('reviews/');
      final hanldeResponse = _utils.handleResponse(response);

      if (hanldeResponse.containsKey('reviews')) {
        companyData = hanldeResponse['reviews'];
      }

      return companyData.map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<int> deleteReview(String idReview) async {
    try {
      var response = await _utils.patch('reviews/?_id_review=$idReview', {});
      return response.statusCode;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<int> deleteComment(String idComment) async {
    try {
      var response = await _utils.patch('comments/?_id_comment=$idComment', {});

      return response.statusCode;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Review>> getUserReviews(String idUser) async {
    try {
      var response = await _utils.get('users/reviews?_id_user=$idUser');

      final List<dynamic> companyData =
          _utils.handleResponse(response)['reviews'];

      return companyData.map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Comment>> getCommentsByUser(String idUser) async {
    try {
      var response = await _utils.get('users/comments');
      final List<dynamic>? companyData =
          _utils.handleResponse(response)['comments'];

      return companyData?.map((data) => Comment.fromJson(data)).toList() ?? [];
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Review>> getBusinessReviews(String idBusiness) async {
    try {
      var response =
          await _utils.get('reviews/business/?_id_business=$idBusiness');

      final List<dynamic> companyData =
          _utils.handleResponse(response)['reviews'];

      return companyData.map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Comment>> getReviewsParentComments(String idReview) async {
    try {
      var response = await _utils.get('reviews/info/?_id_review=$idReview');

      final List<dynamic> companyData =
          _utils.handleResponse(response)['Comments'];

      print(companyData);

      return companyData.map((data) => Comment.fromJson(data)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Comment>> getCommentChildren(String idComment) async {
    try {
      var response =
          await _utils.get('comments/children/?_id_comment=$idComment');
      print(response);

      final handleResponse = _utils.handleResponse(response)['comment'];
      print(handleResponse);

      final List<dynamic> companyData = handleResponse["Comments"];

      print(companyData);

      return companyData.map((data) => Comment.fromJson(data)).toList();
    } catch (e) {
      print("- - object");
      return Future.error(e);
    }
  }

  //Actions

  Future<int> reportReview({required String idReview}) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {"_id_review": idReview};

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('reviews/report', body);

    // Devolver la respuesta procesada
    return response.statusCode;
  }

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

  Future<List<dynamic>> getChats() async {
    try {
      var response = await _utils.get('messages/conversations');

      final List<dynamic> conversations =
          _utils.handleResponse(response)['conversations'];

      return conversations;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<dynamic>> getNewChats() async {
    try {
      var response = await _utils.get('messages/users-list');

      final List<dynamic> newChats = json.decode(response.body);

      return newChats;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> getConversationMessages(String idReceiver) async {
    try {
      var response = await _utils.get('messages/?_id_receiver=$idReceiver');
      if (response.statusCode == 404) {
        return [];
      }
      final List<dynamic> messages =
          _utils.handleResponse(response)['messages'];
      return messages;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<http.Response> uploadUserImages(
      String reviewId, List<String> filePaths) async {
    var responseStream = await _utils.postMultipart(
        'bucket/review?_id_review=$reviewId',
        filePaths, {} // Campos adicionales si los necesitas
        );
    // Obtener la respuesta completa
    var response = await http.Response.fromStream(responseStream);

    return response;
  }

  Future<http.Response> uploadCommentImages(
      String commentId, List<String> filePaths) async {
    var responseStream = await _utils.postMultipart(
        'bucket/comment?_id_comment=$commentId',
        filePaths, {} // Campos adicionales si los necesitas
        );
    // Obtener la respuesta completa
    var response = await http.Response.fromStream(responseStream);

    return response;
  }

  // Future<User> getArticles(String idUser) async {
  //   try {
  //     var response = await _utils.get('articles/');
  //     print(response.statusCode);
  //     print(_utils.handleResponse(response));
  //     return User.fromJson(_utils.handleResponse(response)["articles"]);
  //   } catch (e) {
  //     return Future.error(e);
  //   }
  // }
}

class ApiServerUtils {
  final String baseUrl;
  final UserRepository userRepository;

  ApiServerUtils(this.baseUrl, this.userRepository);

  Future<Map<String, String>> _getDefaultHeaders() async {
    final token = await userRepository.getToken();

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

  Future<http.Response> patch(String endpoint, Map body) async {
    final headers = await _getDefaultHeaders();
    return await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getDefaultHeaders();
    return await http.delete(Uri.parse('$baseUrl/$endpoint'), headers: headers);
  }

  Future<http.StreamedResponse> postMultipart(String endpoint,
      List<String> filePaths, Map<String, String> additionalFields) async {
    final headers = await _getDefaultHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$endpoint'),
    );

    // Agregar campos adicionales si los hay
    request.fields.addAll(additionalFields);

    // Agregar cada archivo a la solicitud
    for (String filePath in filePaths) {
      request.files.add(await http.MultipartFile.fromPath('fileN', filePath));
    }

    // Agregar headers
    request.headers.addAll(headers);

    // Enviar la solicitud y devolver la respuesta
    return await request.send();
  }

  Future<http.Response> postMultipartMedicFlow(
      String endpoint, File file) async {
    final headers = await _getDefaultHeaders();
    // Obtén el tipo MIME del archivo

    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
    var mimeType = lookupMimeType(file.path);
    request.files.add(await http.MultipartFile.fromPath('fileN', file.path,
        contentType: MediaType.parse(mimeType ?? '')));

    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();

    // Convertir el StreamedResponse en un Response

    if (streamedResponse.statusCode == 200) {}
    final response = await http.Response.fromStream(streamedResponse);

    //  var response = await http.Response.fromStream(streamedResponse);

    return response;
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
