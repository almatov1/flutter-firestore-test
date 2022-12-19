import 'package:chat_test/filtr.dart';
import 'package:chat_test/messages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDjCDbAe57eUiTJHGW_JJrJT4UHFbJTYHM',
          appId: '1:580296772809:web:862e63cb5d36ed538dd118',
          messagingSenderId: '580296772809',
          projectId: 'laravel-test-realtime-c9944'));

  runApp(const ChatTest());
}

class ChatTest extends StatelessWidget {
  const ChatTest({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chat Test',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
        ),
        home: const Chats());
  }
}

class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final Stream<QuerySnapshot> _chatsStream =
      FirebaseFirestore.instance.collection('chats').snapshots();
  final _vacancyStream = FirebaseFirestore.instance.collection('vacancy');
  Map vacancy = {};
  bool isLoading = true;
  List<String> vacancyName = [];
  String currentVacancy = 'Flutter разработчик';

  @override
  void initState() {
    super.initState();
    getVacancy();
  }

  getVacancy() async {
    await _vacancyStream.get().then(
      (res) {
        for (var element in res.docs) {
          vacancy.addAll({element.id: element.get('title')});
          vacancyName.add(element.get('title'));
        }
      },
      onError: (e) {},
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5, top: 10),
                    child: Text(
                      'Список чатов:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, top: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 250,
                            child: DropdownButton<String>(
                              value: currentVacancy,
                              items: vacancyName.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child:
                                      SizedBox(width: 200, child: Text(value)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  currentVacancy = value.toString();
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                                onPressed: () {
                                  if (vacancy.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => VacancyFiltr(
                                                vacancyName: currentVacancy,
                                              )),
                                    );
                                  }
                                },
                                child: const Text('Применить фильтр')),
                          ),
                        ],
                      )),
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: 280, maxHeight: 500),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _chatsStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Firebase error');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator());
                        }

                        return ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            DateTime dateNow = data['created_at'].toDate();

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Messages(
                                            chatId: document.id,
                                          )),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                    'Вакансия чата: ${vacancy[data['vacancy_id'].toString()]}'),
                                subtitle:
                                    Text(dateNow.toString().split(' ').first),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
