import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/appointment.dart';
import '../models/entrada_diario.dart';

class ApiService {
  static const String baseUrl = 'sos-psy-production.up.railway.app'; // Ajuste se rodar em device
  static String? _token;
  static User? currentUser;

  static Map<String, String> _headers({bool withAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  static Future<bool> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final resp = await http.post(uri,
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      _token = data['token'] as String?;
      currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      return true;
    }
    return false;
  }

  static Future<User?> me() async {
    if (_token == null) return null;
    final uri = Uri.parse('$baseUrl/auth/me');
    final resp = await http.get(uri, headers: _headers(withAuth: true));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = User.fromJson(data);
      return currentUser;
    }
    return null;
  }

  static Future<User> updateProfile({required String name}) async {
    if (_token == null) throw Exception('Não autenticado');
    final uri = Uri.parse('$baseUrl/users/me');
    final resp = await http.put(uri,
        headers: _headers(withAuth: true),
        body: jsonEncode({'name': name}));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = User.fromJson(data);
      return currentUser!;
    }
    try {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      throw Exception((data['message'] ?? 'Falha ao atualizar perfil').toString());
    } catch (_) {
      throw Exception('Falha ao atualizar perfil (código ${resp.statusCode})');
    }
  }

  static Future<User> updatePsychologistDetails({
    String? bio,
    String? specialty,
    double? price,
    String? profileImageUrl,
  }) async {
    if (_token == null) throw Exception('Não autenticado');
    final uri = Uri.parse('$baseUrl/users/me/details');
    final body = <String, dynamic>{};
    if (bio != null) body['bio'] = bio;
    if (specialty != null) body['specialty'] = specialty;
    if (price != null) body['price'] = price;
    if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;

    final resp = await http.put(uri,
        headers: _headers(withAuth: true),
        body: jsonEncode(body));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = User.fromJson(data);
      return currentUser!;
    }
    try {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      throw Exception((data['message'] ?? 'Falha ao atualizar detalhes').toString());
    } catch (_) {
      throw Exception('Falha ao atualizar detalhes (código ${resp.statusCode})');
    }
  }

  // Register
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? specialty,
    double? price,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
    if (specialty != null) {
      body['specialty'] = specialty;
    }
    if (price != null) {
      body['price'] = price;
    }
    final resp = await http.post(uri,
        headers: _headers(),
        body: jsonEncode(body));
    if (resp.statusCode == 201) return true;
    if (resp.statusCode == 409) {
      // Conflito: email já cadastrado
      throw Exception('Email já cadastrado');
    }
    try {
      final body = resp.body;
      if (body.isNotEmpty) {
        // Tenta JSON
        try {
          final data = jsonDecode(body) as Map<String, dynamic>;
          final msg = (data['message'] ?? 'Falha no cadastro').toString();
          throw Exception(msg);
        } catch (_) {
          // Se não for JSON, retorna texto bruto
          throw Exception(body);
        }
      }
    } catch (_) {}
    throw Exception('Falha no cadastro (código ${resp.statusCode})');
  }

  static Future<List<User>> getPsychologists() async {
    final uri = Uri.parse('$baseUrl/psychologists');
    final resp = await http.get(uri, headers: _headers());
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erro ao carregar psicólogos');
  }

  static Future<Appointment> scheduleAppointment({
    required User psicologo,
    required DateTime data,
    required String horario,
    required String modalidade,
    String motivo = '',
  }) async {
    if (currentUser == null) throw Exception('Usuário não autenticado');
    final uri = Uri.parse('$baseUrl/appointments');
    final payload = {
      'userId': currentUser!.id,
      'psicologoId': psicologo.id,
      'psicologo': psicologo.name,
      'especialidade': psicologo.specialty,
      'avaliacao': psicologo.rating,
      'totalAvaliacoes': psicologo.reviewCount,
      'data': data.toIso8601String(),
      'horario': horario,
      'local': 'Online', // Placeholder, as location is not in User model
      'imagemPsicologo': psicologo.profileImageUrl ?? '',
      'modalidade': modalidade,
      'motivo': motivo,
    };
    final resp = await http.post(uri,
        headers: _headers(withAuth: true), body: jsonEncode(payload));
    if (resp.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Erro ao agendar consulta');
  }

  static Future<List<Appointment>> getAppointments() async {
    if (currentUser == null) throw Exception('Usuário não autenticado');
    final uri = Uri.parse('$baseUrl/appointments');
    final resp = await http.get(uri, headers: _headers(withAuth: true));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erro ao carregar consultas');
  }

  static Future<List<Appointment>> getAppointmentsForPsychologist(
      String psychologistId) async {
    if (currentUser == null) throw Exception('Usuário não autenticado');
    final uri = Uri.parse('$baseUrl/appointments/psychologist/$psychologistId');
    final resp = await http.get(uri, headers: _headers(withAuth: true));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao carregar consultas do psicólogo');
  }

  // Diário
  static Future<List<EntradaDiario>> getDiaryEntries() async {
    if (currentUser == null) throw Exception('Usuário não autenticado');
    final uri = Uri.parse('$baseUrl/diario');
    final resp = await http.get(uri, headers: _headers(withAuth: true));
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list.map((e) => EntradaDiario.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erro ao carregar entradas do diário');
  }

  static Future<EntradaDiario> addDiaryEntry({
    required String titulo,
    required String conteudo,
    required Humor humor,
    required List<String> tags,
    String? psicologoId,
  }) async {
    if (currentUser == null) throw Exception('Usuário não autenticado');
    final uri = Uri.parse('$baseUrl/diario');
    final body = {
      'titulo': titulo,
      'conteudo': conteudo,
      'humor': humor.toString().split('.').last,
      'tags': tags,
      'psicologoId': psicologoId,
      'userId': currentUser!.id,
    };
    final resp = await http.post(uri,
        headers: _headers(withAuth: true),
        body: jsonEncode(body));

    if (resp.statusCode == 201) {
      return EntradaDiario.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Erro ao adicionar entrada no diário');
  }

  static Future<bool> cancelAppointment(String id) async {
    final uri = Uri.parse('$baseUrl/appointments/$id');
    final resp = await http.delete(uri, headers: _headers(withAuth: true));
    return resp.statusCode == 200;
  }

  static Future<bool> changePassword({required String current, required String newer}) async {
    final uri = Uri.parse('$baseUrl/users/me/password');
    final resp = await http.put(uri,
        headers: _headers(withAuth: true),
        body: jsonEncode({'currentPassword': current, 'newPassword': newer}));
    if (resp.statusCode == 200) return true;
    try {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      throw Exception((data['message'] ?? 'Falha ao alterar senha').toString());
    } catch (_) {
      throw Exception('Falha ao alterar senha (código ${resp.statusCode})');
    }
  }

  static Future<bool> deleteAccount() async {
    final uri = Uri.parse('$baseUrl/users/me');
    final resp = await http.delete(uri, headers: _headers(withAuth: true));
    if (resp.statusCode == 200) {
      _token = null;
      currentUser = null;
      return true;
    }
    try {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      throw Exception((data['message'] ?? 'Falha ao excluir conta').toString());
    } catch (_) {
      throw Exception('Falha ao excluir conta (código ${resp.statusCode})');
    }
  }
}
