import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/models/company_model.dart';
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

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String lastName,
    required String phone,
    required String email,
    required String profilePicture,
    required String password,
    required String specialty,
    required String role,
  }) async {
    // Construir el cuerpo del POST request con todos los argumentos
    var body = {
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'profile_picture': profilePicture,
      'password': password,
      'specialty': specialty,
      'role': role,
    };

    // Realizar la petición POST al endpoint para registrar usuarios
    var response = await _utils.post('users/', body);

    // Devolver la respuesta procesada
    return _utils.handleResponse(response);
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    var body = {'email': email, 'password': password};
    var response = await _utils.post('users/login', body);

    return _utils.handleResponse(response);
  }

  bool validateToken(String token) {
    return JwtDecoder.isExpired(token) == false;
  }

  Future<bool> validateAccesToken(String token) async {
    var response = await _utils.get('users/token');
    return _utils.handleResponse(response)['success'];
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

  Future<Map<String, dynamic>> getUserProfile(String id) async {
    var response = await _utils.get('users?_id_user=$id');
    return _utils.handleResponse(response);
  }

  Future<List<Company>> getSearch(String id) async {
    try {
      // var response = await _utils.get('users?_id_user=$id');

      // final List<dynamic> companyData =
      //     _utils.handleResponse(response)['companies'];

      await Future.delayed(Duration(seconds: 1));

      final List<dynamic> companyData = [
        {'name': 'Starbucks', 'parentCompany': 'Alsea'},
        {'name': 'Apple', 'parentCompany': 'Apple Inc.'},
        {
          'name': 'Burger King',
          'parentCompany': 'Restaurant Brands International'
        },
        {'name': 'Nike', 'parentCompany': 'Nike, Inc.'},
        {'name': 'Pepsi', 'parentCompany': 'PepsiCo'}
      ];

      return companyData.map((data) => Company.fromJson(data)).toList();
    } catch (e) {
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

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = token;
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
    } else {
      throw Exception(
          'Request failed with status: ${response.statusCode}. Response: ${response.body}');
    }
  }
}
