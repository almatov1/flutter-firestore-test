import 'package:chat_test/main.dart';
import 'package:chat_test/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VacancyFiltr extends StatefulWidget {
  final String vacancyName;
  const VacancyFiltr({Key? key, required this.vacancyName}) : super(key: key);

  @override
  State<VacancyFiltr> createState() => _VacancyFiltrState();
}

class _VacancyFiltrState extends State<VacancyFiltr> {
  bool isLoading = true;
  final _vacancyStream = FirebaseFirestore.instance.collection('vacancy');
  final _chatsStream = FirebaseFirestore.instance.collection('chats');
  Map chats = {};

  @override
  void initState() {
    super.initState();
    loadStream();
  }

  loadStream() async {
    late String vacancyId;
    await _vacancyStream
        .where('title', isEqualTo: widget.vacancyName.toString())
        .get()
        .then(
      (res) {
        for (var elem in res.docs) {
          vacancyId = elem.id;
        }
      },
      onError: (e) {},
    );

    await _chatsStream.where('vacancy_id', isEqualTo: vacancyId).get().then(
      (res) {
        for (var elem in res.docs) {
          chats.addAll({
            elem.id: elem.get('created_at'),
          });
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
                          Text('Применен фильтр: ${widget.vacancyName}'),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Chats()),
                                  );
                                },
                                child: const Text('Отменить')),
                          ),
                        ],
                      )),
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: 280, maxHeight: 500),
                    child: ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = chats.keys.elementAt(index);
                        DateTime dateNow = chats[key].toDate();

                        return InkWell(
                          onTap: () {
                            var docId = chats.keys.firstWhere(
                                (k) => chats[k] == chats[key],
                                orElse: () => null);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Messages(
                                        chatId: docId,
                                      )),
                            );
                          },
                          child: ListTile(
                            title: Text(widget.vacancyName),
                            subtitle: Text(dateNow.toString().split(' ').first),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
