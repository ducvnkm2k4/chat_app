import 'package:chat_app/screens/sign_up_screen.dart';
import 'package:chat_app/service/message_provider.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/chat_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lấy SharedPreferences để kiểm tra trạng thái đăng nhập
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uId = prefs.getString('uId');
  SocketService();
  // Quyết định route ban đầu dựa trên việc có uid hay không
  String initialRoute = uId == null ? '/login' : '/chat_detail';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MyApp(
        initialRoute: initialRoute,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/chat_detail': (context) => const ChatDetailScreen(),
        '/sign_up': (context) => const SignUpScreen(),
      },
    );
  }
}
