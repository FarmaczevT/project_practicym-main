import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_try_with_api/authorization.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SubmitApplicationPage extends StatefulWidget {
  final String token;
  final VoidCallback logout;
  final int userId;

  SubmitApplicationPage({
    required this.token,
    required this.logout,
    required this.userId,
  });

  @override
  _SubmitApplicationPageState createState() => _SubmitApplicationPageState();
}

class _SubmitApplicationPageState extends State<SubmitApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  String nazvanie = '';
  String korpus = '';
  int kabinet = 0;
  int otpravitel = 0;
  String opisanie = '';
  String fileName = '';
  int kategoria = 0;
  File? file;

  @override
  void initState() {
    super.initState();
    otpravitel = widget.userId;
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final url = Uri.parse('http://dienis72.beget.tech/api/submit-application');

      final request = http.MultipartRequest('POST', url)
        ..fields['nazvanie'] = nazvanie
        ..fields['korpus'] = korpus
        ..fields['kabinet'] = kabinet.toString()
        ..fields['otpravitel'] = otpravitel.toString()
        ..fields['opisanie'] = opisanie
        ..fields['kategoria'] = kategoria.toString();

      if (file != null) {
        final mimeType = lookupMimeType(file!.path)!;
        final mimeTypeData = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file!.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'Application submitted successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Заявка успешно отправлена')),
          );
          _formKey.currentState!.reset();
          setState(() {
            nazvanie = '';
            korpus = '';
            kabinet = 0;
            otpravitel = widget.userId;
            opisanie = '';
            kategoria = 0;
            file = null;
            fileName = '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось подать заявку: ${response.body}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при отправке заявки: ${response.statusCode} ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке заявки: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
        fileName = pickedFile.path.split('/').last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 8),
              const Text('Отправка заявки'),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                widget.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              icon: Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Название'),
                    validator: (value) =>
                        value!.isEmpty ? 'Введите название' : null,
                    onSaved: (value) => nazvanie = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Корпус'),
                    validator: (value) =>
                        value!.isEmpty ? 'Введите корпус' : null,
                    onSaved: (value) => korpus = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Кабинет'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Введите кабинет' : null,
                    onSaved: (value) => kabinet = int.parse(value!),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Описание'),
                    validator: (value) =>
                        value!.isEmpty ? 'Введите описание' : null,
                    onSaved: (value) => opisanie = value!,
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Категория'),
                    value: kategoria != 0 ? kategoria : null,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Плотник')),
                      DropdownMenuItem(value: 2, child: Text('Слесарь')),
                      DropdownMenuItem(value: 3, child: Text('Электрик')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        kategoria = value!;
                      });
                    },
                    onSaved: (value) => kategoria = value!,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text('Прикрепить файл'),
                  ),
                  SizedBox(height: 8),
                  file != null
                      ? Text('Файл выбран: $fileName')
                      : Text('Файл не выбран'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitApplication,
                    child: Text('Отправить заявку'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}