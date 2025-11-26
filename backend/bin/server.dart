import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:email_validator/email_validator.dart';

// Função para gerar hash de senha
String _hashPassword(String password) {
  final bytes = utf8.encode(password); // Converte a senha para bytes
  final digest = sha256.convert(bytes); // Aplica o hash SHA-256
  return digest.toString(); // Retorna o hash como uma string hexadecimal
}

void main(List<String> args) async {
  final app = Router();

  // Simple file-based persistence (JSON arrays) - creates defaults if missing
  final dataDir = Directory('data');
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }

  List<Map<String, dynamic>> _load(String name, List<Map<String, dynamic>> seed) {
    final file = File('data/$name.json');
    if (!file.existsSync()) {
      file.writeAsStringSync(jsonEncode(seed));
      return seed;
    }
    final raw = jsonDecode(file.readAsStringSync());
    return (raw as List).cast<Map<String, dynamic>>();
  }

  void _save(String name, List<Map<String, dynamic>> data) {
    File('data/$name.json').writeAsStringSync(jsonEncode(data));
  }

  final users = _load('users', [
    {
      'id': 'u1',
      'name': 'Admin',
      'email': 'admin@gmail.com',
      'role': 'patient',
      'password': _hashPassword('12345'), // Armazena a senha como hash
    }
  ]);

  final appointments = _load('appointments', []);
  final diario = _load('diario', []);

  // JWT secret (use env var in real production)
  const secret = 'dev-secret-change';

  String _issueToken(String userId) {
    final jwt = JWT({'sub': userId, 'iat': DateTime.now().millisecondsSinceEpoch});
    return jwt.sign(SecretKey(secret));
  }

  String? _verifyToken(String? header) {
    if (header == null || !header.startsWith('Bearer ')) return null;
    final token = header.substring(7);
    try {
      final decoded = JWT.verify(token, SecretKey(secret));
      return decoded.payload['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  // Routes
  app.post('/auth/login', (Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final email = (data['email'] ?? '').toString().trim();
    final password = (data['password'] ?? '').toString();

    if (email.isEmpty || !EmailValidator.validate(email)) {
      return Response(400,
          body: jsonEncode({'message': 'Formato de email inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final userIndex = users.indexWhere((u) => u['email'] == email);

    if (userIndex == -1) {
      return Response(401,
          body: jsonEncode({'message': 'Credenciais inválidas'}),
          headers: {'Content-Type': 'application/json'});
    }

    final user = users[userIndex];
    final storedPassword = user['password'] as String;
    final providedPasswordHash = _hashPassword(password);

    // Lógica de migração de senha:
    // Se a senha armazenada não for um hash (legado) e for igual à senha fornecida
    if (storedPassword.length != 64 && storedPassword == password) {
      // Atualiza a senha para o formato de hash
      users[userIndex]['password'] = providedPasswordHash;
      _save('users', users);
    }
    // Se a senha armazenada for um hash e for diferente do hash da senha fornecida
    else if (storedPassword != providedPasswordHash) {
      return Response(401,
          body: jsonEncode({'message': 'Credenciais inválidas'}),
          headers: {'Content-Type': 'application/json'});
    }

    final token = _issueToken(user['id'] as String);
    final result = Map.of(user)..remove('password');
    return Response.ok(
      jsonEncode({'token': token, 'user': result}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Dados do usuário autenticado
  app.get('/auth/me', (Request req) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401,
          body: jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }
    final user = users.firstWhere((u) => u['id'] == userIdFromToken, orElse: () => {});
    if (user.isEmpty) {
      return Response(404,
          body: jsonEncode({'message': 'Usuário não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }
    final result = Map.of(user)..remove('password');
    return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
  });

  // Atualização de perfil (nome apenas para este MVP)
  app.put('/users/me', (Request req) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401,
          body: jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }
    final index = users.indexWhere((u) => u['id'] == userIdFromToken);
    if (index == -1) {
      return Response(404,
          body: jsonEncode({'message': 'Usuário não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }
    final body = await req.readAsString();
    Map<String, dynamic> data = {};
    if (body.isNotEmpty) {
      try { data = jsonDecode(body) as Map<String, dynamic>; } catch(_) {}
    }
    final novoNome = (data['name'] ?? '').toString().trim();
    if (novoNome.isEmpty) {
      return Response(400,
          body: jsonEncode({'message': 'O nome não pode ser vazio'}),
          headers: {'Content-Type': 'application/json'});
    }
    users[index]['name'] = novoNome;
    _save('users', users);
    final result = Map.of(users[index])..remove('password');
    return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
  });

  // Atualização de detalhes do psicólogo
  app.put('/users/me/details', (Request req) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401, body: jsonEncode({'message': 'Token inválido ou ausente'}), headers: {'Content-Type': 'application/json'});
    }
    final index = users.indexWhere((u) => u['id'] == userIdFromToken);
    if (index == -1) {
      return Response(404, body: jsonEncode({'message': 'Usuário não encontrado'}), headers: {'Content-Type': 'application/json'});
    }
    if (users[index]['role'] != 'psychologist') {
      return Response(403, body: jsonEncode({'message': 'Apenas psicólogos podem atualizar detalhes profissionais'}), headers: {'Content-Type': 'application/json'});
    }

    final body = await req.readAsString();
    Map<String, dynamic> data = {};
    if (body.isNotEmpty) {
      try { data = jsonDecode(body) as Map<String, dynamic>; } catch(_) {}
    }

    // Atualiza os campos permitidos
    if (data.containsKey('bio')) {
      users[index]['bio'] = data['bio'].toString();
    }
    if (data.containsKey('specialty')) {
      users[index]['specialty'] = data['specialty'].toString();
    }
    if (data.containsKey('price')) {
      final price = (data['price'] as num?)?.toDouble();
      if (price != null && price >= 0) {
        users[index]['price'] = price;
      }
    }
     if (data.containsKey('profileImageUrl')) {
      users[index]['profileImageUrl'] = data['profileImageUrl'] as String?;
    }

    _save('users', users);
    final result = Map.of(users[index])..remove('password');
    return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
  });

  app.post('/auth/register', (Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    // Validação de campos
    final name = (data['name'] ?? '').toString().trim();
    final email = (data['email'] ?? '').toString().trim();
    final password = (data['password'] ?? '').toString();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return Response(400,
          body: jsonEncode({'message': 'Nome, email e senha são obrigatórios'}),
          headers: {'Content-Type': 'application/json'});
    }

    if (!EmailValidator.validate(email)) {
      return Response(400,
          body: jsonEncode({'message': 'Formato de email inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    if (password.length < 6) {
      return Response(400,
          body: jsonEncode(
              {'message': 'A senha deve ter pelo menos 6 caracteres'}),
          headers: {'Content-Type': 'application/json'});
    }

    final exists = users.any((u) => u['email'] == email);
    if (exists) {
      return Response(409,
          body: jsonEncode({'message': 'Email já cadastrado'}),
          headers: {'Content-Type': 'application/json'});
    }

    final isPsychologist = data['role'] == 'psychologist';

    final newUser = {
      'id': 'u${users.length + 1}',
      'name': name,
      'email': email,
      'role': data['role'] ?? 'patient',
      'password': _hashPassword(password), // Hash da senha
      // Add psychologist-specific fields with defaults if the role is psychologist
      if (isPsychologist) ...{
        'specialty': data['specialty'] ?? 'Clínica Geral',
        'bio': data['bio'] ?? 'Psicólogo com vasta experiência em saúde mental.',
        'profileImageUrl': data['profileImageUrl'] as String?,
        'rating': (data['rating'] as num?)?.toDouble() ?? 4.5,
        'reviewCount': data['reviewCount'] as int? ?? 0,
        'price': (data['price'] as num?)?.toDouble() ?? 150.0,
      }
    };
    users.add(newUser);
    _save('users', users);
    final result = Map.of(newUser)..remove('password');
    return Response(201,
        body: jsonEncode(result),
        headers: {'Content-Type': 'application/json'});
  });

  app.get('/psychologists', (Request req) async {
    final psychologistUsers = users.where((u) => u['role'] == 'psychologist').toList();
    // Remove sensitive data before sending
    final publicData = psychologistUsers.map((p) {
      final publicUser = Map<String, dynamic>.from(p);
      publicUser.remove('password');
      return publicUser;
    }).toList();
    return Response.ok(jsonEncode(publicData),
        headers: {'Content-Type': 'application/json'});
  });

  app.get('/appointments', (Request req) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401,
          body: jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }
    final userIdQuery = req.url.queryParameters['userId']; // backward compatibility
    final effectiveUser = userIdQuery ?? userIdFromToken;
    final list = appointments.where((a) => a['userId'] == effectiveUser).toList();
    return Response.ok(jsonEncode(list),
        headers: {'Content-Type': 'application/json'});
  });

  // Rota para buscar agendamentos de um psicólogo específico
  app.get('/appointments/psychologist/<psychologistId>',
      (Request req, String psychologistId) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response.unauthorized(
          jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }

    // Filtra os agendamentos pelo ID do psicólogo
    final psychologistAppointments =
        appointments.where((a) => a['psicologoId'] == psychologistId).toList();

    // Adiciona o nome do paciente a cada agendamento
    final appointmentsWithPatientNames = psychologistAppointments.map((appt) {
      final patient =
          users.firstWhere((u) => u['id'] == appt['userId'], orElse: () => {});
      final newAppt = Map<String, dynamic>.from(appt);
      if (patient.isNotEmpty) {
        newAppt['patientName'] = patient['name'];
      } else {
        newAppt['patientName'] = 'Paciente não encontrado';
      }
      return newAppt;
    }).toList();

    return Response.ok(jsonEncode(appointmentsWithPatientNames),
        headers: {'Content-Type': 'application/json'});
  });

  app.post('/appointments', (Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response.unauthorized(
          jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }

    // Validação dos campos obrigatórios
    final requiredFields = ['psicologoId', 'psicologo', 'data', 'horario', 'modalidade'];
    for (final f in requiredFields) {
      if (!data.containsKey(f) || (data[f]?.toString().isEmpty ?? true)) {
        return Response.badRequest(
            body: jsonEncode({'message': 'Campo obrigatório ausente: $f'}),
            headers: {'Content-Type': 'application/json'});
      }
    }

    final newAppt = {
      'id': 'a${appointments.length + 1}',
      'userId': data['userId'] ?? userIdFromToken,
      'psicologoId': data['psicologoId'], // Chave para a busca do psicólogo
      'psicologo': data['psicologo'],
      'especialidade': data['especialidade'] ?? '',
      'avaliacao': (data['avaliacao'] ?? 0.0).toDouble(),
      'totalAvaliacoes': data['totalAvaliacoes'] ?? 0,
      'data': data['data'],
      'horario': data['horario'],
      'local': data['local'] ?? '',
      'imagemPsicologo': data['imagemPsicologo'] ?? '',
      'modalidade': data['modalidade'],
      'motivo': data['motivo'] ?? '',
    };

    appointments.add(newAppt);
    _save('appointments', appointments);

    return Response(201,
        body: jsonEncode(newAppt),
        headers: {'Content-Type': 'application/json'});
  });

  app.delete('/appointments/<id>', (Request req, String id) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401,
          body: jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }
    final idx = appointments.indexWhere((a) => a['id'] == id);
    if (idx == -1) {
      return Response(404,
          body: jsonEncode({'message': 'Agendamento não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }
    // Ensure ownership
    if (appointments[idx]['userId'] != userIdFromToken) {
      return Response(403,
          body: jsonEncode({'message': 'Não autorizado'}),
          headers: {'Content-Type': 'application/json'});
    }
    appointments.removeAt(idx);
    _save('appointments', appointments);
    return Response.ok(jsonEncode({'message': 'Cancelado'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Rotas do Diário
  // Criar uma nova entrada no diário
  app.post('/diario', (Request req) async {
    print('[POST /diario] request received');
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401, body: jsonEncode({'message': 'Token inválido ou ausente'}), headers: {'Content-Type': 'application/json'});
    }

    final body = await req.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    // Validação básica
    if (data['titulo'] == null || data['conteudo'] == null || data['humor'] == null) {
      return Response(400, body: jsonEncode({'message': 'Título, conteúdo e humor são obrigatórios'}), headers: {'Content-Type': 'application/json'});
    }

    // Direcionamento opcional para psicólogo
    final psicologoId = (data['psicologoId'] as String?)?.trim();
    String? psicologoNome;
    if (psicologoId != null && psicologoId.isNotEmpty) {
      final psic = users.firstWhere((u) => u['id'] == psicologoId && u['role'] == 'psychologist', orElse: () => {});
      if (psic.isNotEmpty) {
        psicologoNome = psic['name'] as String?;
      }
    }

    final newEntry = {
      'id': 'd${diario.length + 1}',
      'userId': userIdFromToken,
      'data': DateTime.now().toIso8601String(),
      'titulo': data['titulo'],
      'conteudo': data['conteudo'],
      'humor': data['humor'],
      'tags': (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      if (psicologoId != null) 'psicologoId': psicologoId,
      if (psicologoNome != null) 'psicologoNome': psicologoNome,
    };

    diario.add(newEntry);
    _save('diario', diario);

    return Response(201, body: jsonEncode(newEntry), headers: {'Content-Type': 'application/json'});
  });

  // Suporte a trailing slash
  app.post('/diario/', (Request req) async => app.call(Request('POST', req.requestedUri.replace(path: '/diario'), headers: req.headers, body: await req.readAsString())));

  // Obter todas as entradas do diário do usuário autenticado
  app.get('/diario', (Request req) async {
    print('[GET /diario] request received');
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401, body: jsonEncode({'message': 'Token inválido ou ausente'}), headers: {'Content-Type': 'application/json'});
    }

    final userEntries = diario.where((entry) => entry['userId'] == userIdFromToken).toList();
    return Response.ok(jsonEncode(userEntries), headers: {'Content-Type': 'application/json'});
  });

  // Suporte a trailing slash
  app.get('/diario/', (Request req) async => app.call(Request('GET', req.requestedUri.replace(path: '/diario'), headers: req.headers)));

  // Obter entradas do diário de um paciente específico (para psicólogos)
  app.get('/pacientes/<pacienteId>/diario', (Request req, String pacienteId) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401, body: jsonEncode({'message': 'Token inválido ou ausente'}), headers: {'Content-Type': 'application/json'});
    }

    // Verifica se o usuário autenticado é um psicólogo
    final psychologist = users.firstWhere((u) => u['id'] == userIdFromToken, orElse: () => {});
    if (psychologist.isEmpty || psychologist['role'] != 'psychologist') {
      return Response(403, body: jsonEncode({'message': 'Acesso negado. Apenas para psicólogos.'}), headers: {'Content-Type': 'application/json'});
    }

    final patientEntries = diario.where((entry) => entry['userId'] == pacienteId).toList();
    return Response.ok(jsonEncode(patientEntries), headers: {'Content-Type': 'application/json'});
  });


  // Alterar senha do usuário autenticado
  app.put('/users/me/password', (Request req) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401,
          body: jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }
    final index = users.indexWhere((u) => u['id'] == userIdFromToken);
    if (index == -1) {
      return Response(404,
          body: jsonEncode({'message': 'Usuário não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }
    final body = await req.readAsString();
    if (body.isEmpty) {
      return Response(400,
          body: jsonEncode({'message': 'Corpo da requisição vazio'}),
          headers: {'Content-Type': 'application/json'});
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    final atual = (data['currentPassword'] ?? '').toString();
    final nova = (data['newPassword'] ?? '').toString();
    if (atual.isEmpty || nova.isEmpty) {
      return Response(400,
          body: jsonEncode({'message': 'Informe a senha atual e a nova senha'}),
          headers: {'Content-Type': 'application/json'});
    }

    final storedPassword = users[index]['password'] as String;
    final currentPasswordHash = _hashPassword(atual);

    // Lógica de migração + verificação
    if (storedPassword.length != 64 && storedPassword == atual) {
      // Senha legada correta, permite alteração
    } else if (storedPassword != currentPasswordHash) {
      return Response(403,
          body: jsonEncode({'message': 'Senha atual incorreta'}),
          headers: {'Content-Type': 'application/json'});
    }

    if (nova.length < 6) {
      return Response(400,
          body: jsonEncode(
              {'message': 'A nova senha deve ter ao menos 6 caracteres'}),
          headers: {'Content-Type': 'application/json'});
    }
    users[index]['password'] = _hashPassword(nova); // Salva o hash da nova senha
    _save('users', users);
    return Response.ok(jsonEncode({'message': 'Senha alterada com sucesso'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Excluir conta do usuário autenticado (remove também seus agendamentos)
  app.delete('/users/me', (Request req) async {
    final userIdFromToken = _verifyToken(req.headers['Authorization']);
    if (userIdFromToken == null) {
      return Response(401,
          body: jsonEncode({'message': 'Token inválido ou ausente'}),
          headers: {'Content-Type': 'application/json'});
    }
    final index = users.indexWhere((u) => u['id'] == userIdFromToken);
    if (index == -1) {
      return Response(404,
          body: jsonEncode({'message': 'Usuário não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }
    users.removeAt(index);
    // Remove todos os agendamentos do usuário
    appointments.removeWhere((a) => a['userId'] == userIdFromToken);
    _save('users', users);
    _save('appointments', appointments);
    return Response.ok(jsonEncode({'message': 'Conta excluída com sucesso'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Middlewares: CORS + log + json content type default
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        ACCESS_CONTROL_ALLOW_ORIGIN: '*',
        ACCESS_CONTROL_ALLOW_HEADERS:
            'Origin, Content-Type, Accept, Authorization',
        ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      }))
      .addHandler(app);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Backend running on http://${server.address.host}:${server.port}');
}
