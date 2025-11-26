import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/tipo_usuario_screen.dart';
import 'screens/auth/novo_paciente_screen.dart';
import 'screens/auth/novo_psicologo_screen.dart';
import 'screens/inicio/home_screen.dart';
import 'screens/psicologos/psicologos_disponiveis_screen.dart';
import 'screens/consultas/agendar_consulta_screen.dart';
import 'screens/consultas/consultas_agendadas_screen.dart';
import 'screens/consultas/consultas_psicologo_screen.dart';
import 'screens/diario/diario_screen.dart';
import 'screens/perfil/perfil_usuario_screen.dart';
import 'screens/perfil/sobre_nos_screen.dart';
import 'screens/perfil/equipe_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Define a orientação para retrato apenas
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Define a cor da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS PSY - App de Consultas',
      // Configuração de localização
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português do Brasil
      ],
      locale: const Locale('pt', 'BR'),

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      initialRoute: '/', // Inicia na splash screen
      routes: {
        '/': (context) => SplashScreen(), // Rota da splash screen
        '/login': (context) => LoginScreen(),
        '/tipo-usuario': (context) => TipoUsuarioScreen(),
        '/novo-paciente': (context) => NovoPacienteScreen(),
        '/novo-psicologo': (context) => NovoPsicologoScreen(),
        '/inicio': (context) => HomeScreen(),
        '/consultas-agendadas': (context) => ConsultasAgendadasScreen(),
        '/consultas-psicologo': (context) => ConsultasPsicologoScreen(),
        '/psicologos-disponiveis': (context) => PsicologosDisponiveisScreen(),
        '/agendar-consulta': (context) => AgendarConsultaScreen(),
        '/diario': (context) => DiarioScreen(),
        '/perfil-usuario': (context) => PerfilUsuarioScreen(),
        '/sobre-nos': (context) => SobreNosScreen(),
        '/equipe': (context) => EquipeScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Página não encontrada')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Página não encontrada',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text('Rota: ${settings.name}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: Text('Voltar ao Login'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
