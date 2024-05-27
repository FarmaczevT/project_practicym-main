import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_try_with_api/main.dart';
import 'package:flutter_try_with_api/registration.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String token = ''; // Инициализируем значением по умолчанию
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/api_user.json');

    if (await file.exists()) {
      final userData = jsonDecode(await file.readAsString());
      token = userData['token'];
      final userId = userData['userId'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            token: token,
            userId: userId,
            logout: _logout,
          ),
        ),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
        _isLoading = true;
      });

    final url = Uri.parse('http://dienis72.beget.tech/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': username,
        'password': password,
      }),
    );

    setState(() {
        _isLoading = false;
      });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      token = responseData['access_token']; // Сохраняем токен
      final userId = responseData['user_id']; // Получаем ID пользователя
      print(
          'User ID after login: $userId'); // Выводим ID пользователя в консоль

      // Сохраняем токен и userId в файл
      await _saveUserData(token, userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            token: token,
            userId: userId, // Передаем ID пользователя
            logout: _logout, // Передаем функцию logout
          ),
        ),
      );
    } else {
      final errorData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${errorData['error']}')),
      );
    }
  }

  Future<void> _saveUserData(String token, int userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/api_user.json');
    final userData = jsonEncode({'token': token, 'userId': userId});
    await file.writeAsString(userData);
  }

  Future<void> _deleteUserData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/api_user.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _logout() async {
    if (token.isEmpty) {
      // Если токен не определен, выходим
      return;
    }

    await _deleteUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Замените на путь к вашему изображению
              height: 40, // Задайте высоту и ширину, которые вам подходят
              width: 40,
            ),
            const SizedBox(
                width:
                    8), // Добавьте немного отступа между изображением и текстом
            const Text('Авторизация'),
          ],
        ),
        automaticallyImplyLeading: false, // Убираем стрелку "назад"
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        :Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 189, 189, 189),
                    fontSize: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 189, 189, 189),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12), // Устанавливаем внутренние отступы
                ),
                validator: (value) => value!.isEmpty ? 'Введите логин' : null,
                onSaved: (value) => username = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 189, 189, 189),
                    fontSize: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 189, 189, 189),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12), // Устанавливаем внутренние отступы
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Введите пароль' : null,
                onSaved: (value) => password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                      color: const Color.fromARGB(255, 128, 128, 128),
                      width: 2),
                ),
                onPressed: _login,
                child: const Text(
                  'Войти',
                  style: TextStyle(
                      fontSize: 17, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 123, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                      color: const Color.fromARGB(255, 128, 128, 128),
                      width: 2),
                ),
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text(
                  'Регистрация',
                  style: TextStyle(
                      fontSize: 17, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
