import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_try_with_api/FullScreenImage.dart';
import 'application.dart';
import 'CancellApplication.dart';
import 'package:http/http.dart' as http;

class ApplicationsDetails extends StatefulWidget {
  final Application application;

  ApplicationsDetails({required this.application});

  @override
  _ApplicationsDetailsState createState() => _ApplicationsDetailsState();
}

class _ApplicationsDetailsState extends State<ApplicationsDetails> {
  bool _isLoading = true;
  late Map<String, dynamic> _applicationDetails;
  late Future<List<CancellApplication>> cancellApplications;

  @override
  void initState() {
    super.initState();
    _applicationDetails = widget.application.toMap();
    print("application details loaded: $_applicationDetails");
    cancellApplications = CancellApplications();
  }

  Future<List<CancellApplication>> CancellApplications() async {
    final response = await http.post(
      Uri.parse('http://dienis72.beget.tech/api/cancell-applications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'applicationId': _applicationDetails['id']}),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      if (responseBody.isNotEmpty) {
        print("Cancellapplication details loaded: $responseBody");
        List<CancellApplication> applications = responseBody
            .map((data) => CancellApplication.fromJson(data))
            .toList();

        // Show dialog if there are cancelled applications
        if (applications.isNotEmpty) {
          final comment = applications.first.kommentarii;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCancellationDialog(comment);
          });
        }

        setState(() {
          _isLoading = false;
        });

        return applications;
      } else {
        setState(() {
          _isLoading = false;
        });
        return [];
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 404) {
        throw Exception('No applications found for the given ID');
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: Application ID is required');
      } else {
        throw Exception('Something went wrong: ${response.reasonPhrase}');
      }
    }
  }

  void _showCancellationDialog(String comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ваша заявка отклонена'),
          content: Text('Причина: $comment'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.application.nazvanie),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    'Статус заявки: ${_applicationDetails['statusText'] ?? ''}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16.0),
                  if (_applicationDetails['ispolnitel'] != null &&
                      _applicationDetails['ispolnitel'].isNotEmpty &&
                      _applicationDetails['kategoria'] != null &&
                      _applicationDetails['kategoria'].isNotEmpty)
                    Text(
                      'Исполнитель: ${_applicationDetails['ispolnitel'] ?? ''}, ${_applicationDetails['kategoria'] ?? ''}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16.0),
                  if (_applicationDetails['korpys'] != null &&
                      _applicationDetails['korpys'].isNotEmpty &&
                      _applicationDetails['kabinet'] != null &&
                      _applicationDetails['kabinet'].isNotEmpty)
                    Text(
                      'Место: ${_applicationDetails['korpys'] ?? ''}/${_applicationDetails['kabinet'] ?? ''}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16.0),
                  if (_applicationDetails['opisanie'] != null &&
                      _applicationDetails['opisanie'].isNotEmpty)
                    Text(
                      'Описание: ${_applicationDetails['opisanie'] ?? ''}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16.0),
                  if (_applicationDetails['file'] != null &&
                      _applicationDetails['file'].isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(
                              imageUrl: _applicationDetails['file'],
                            ),
                          ),
                        );
                      },
                      child: FractionallySizedBox(
                        widthFactor: 0.8, // 80% ширины экрана
                        child: Image.network(
                          _applicationDetails['file'],
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
