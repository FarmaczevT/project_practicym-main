import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _name = '';
  String _password = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://dienis72.beget.tech/api/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _name,
            'role': 1,
            'kategoria': 5,
            'password': _password,
            'password_confirmation': _confirmPasswordController.text,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          // Показать модальное окно
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Успешная регистрация'),
                content: const Text('Регистрация прошла успешно. Пожалуйста, войдите в свой аккаунт.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Закрыть окно регистрации
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['errors'].toString())),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            const SizedBox(width: 8), // Добавьте немного отступа между изображением и текстом
            const Text('Регистрация'),
          ],
        ),
        automaticallyImplyLeading: false, // Убираем стрелку "назад"
      ),
      body: Padding(
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
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Устанавливаем внутренние отступы
                ),
                validator: (value) => value!.isEmpty ? 'Введите логин' : null,
                onSaved: (value) => _name = value!,
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
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Устанавливаем внутренние отступы
                ),
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 8) {
                    return 'Длина пароля должна составлять не менее 8 символов';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Повторите пароль',
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
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Устанавливаем внутренние отступы
                ),
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, подтвердите свой пароль';
                  }
                  if (value != _passwordController.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: const Color.fromARGB(255, 128, 128, 128), width: 2),
                ),
                onPressed: _register,
                child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
