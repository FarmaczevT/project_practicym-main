import 'package:flutter/material.dart';
import 'package:flutter_try_with_api/FullScreenImage.dart';
import 'application.dart';

class ApplicationsDetails extends StatefulWidget {
  final Application application;

  ApplicationsDetails({required this.application});

  @override
  _ApplicationsDetailsState createState() => _ApplicationsDetailsState();
}

class _ApplicationsDetailsState extends State<ApplicationsDetails> {
  bool _isLoading = true;
  late Map<String, dynamic> _applicationDetails;

  @override
  void initState() {
    super.initState();
    _applicationDetails = widget.application.toMap();
    print("application details loaded: $_applicationDetails");
    setState(() {
      _isLoading = false;
    });
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
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
