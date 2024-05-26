import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'application.dart';
import 'application_details_screen.dart';
import 'authorization.dart';

class ApplicationsPage extends StatefulWidget {
  final String token;
  final int userId;
  final VoidCallback logout;

  ApplicationsPage({
    required this.token,
    required this.userId,
    required this.logout,
  });

  @override
  _ApplicationsPageState createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  late Future<List<Application>> applications;

  @override
  void initState() {
    super.initState();
    applications = fetchApplications();
  }

  Future<List<Application>> fetchApplications() async {
    final response = await http.post(
      Uri.parse('http://dienis72.beget.tech/api/view-applications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userId}),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      return responseBody.map((data) => Application.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  void _navigateToApplicationsDetails(Application application) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationsDetails(application: application),
      ),
    );
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
              const Text('Мои заявки'),
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
        body: FutureBuilder<List<Application>>(
          future: applications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Заявок нет'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final application = snapshot.data![index];
                  return GestureDetector(
                    onTap: () => _navigateToApplicationsDetails(application),
                    child: Card(
                      color: const Color.fromARGB(255, 229, 236, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 15.0),
                        leading: CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          application.nazvanie,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Статус: ${application.statusText}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(204, 0, 0, 0),
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Color.fromARGB(255, 76, 175, 80)),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}