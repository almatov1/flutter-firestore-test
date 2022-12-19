import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  final String chatId;
  const Messages({Key? key, required this.chatId}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  bool isLoading = true;
  final _messagesStream = FirebaseFirestore.instance.collection('messages');
  Map messages = {};

  List standartMessages = [
    'Здравстуйте!',
    'Вы все еще в поиске?',
    'Ищу.',
    'Вы тут?',
    'Привет.',
    'Как ваши дела?',
    'Можно информацию?',
    'Как вы?'
  ];

  @override
  void initState() {
    super.initState();
    loadStream();
  }

  Future<void> addMessage() {
    var rng = Random();

    return _messagesStream.add({
      'chat_id': widget.chatId,
      'author': rng.nextInt(2),
      'created_at': DateTime.now(),
      'message': standartMessages[rng.nextInt(standartMessages.length)]
    });
  }

  loadStream() async {
    await _messagesStream.where('chat_id', isEqualTo: widget.chatId).get().then(
      (res) {
        for (var elem in res.docs) {
          messages.addAll({
            elem.get('message'): elem.get('author').toString(),
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
                      'Переписка:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: 280, maxHeight: 500),
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = messages.keys.elementAt(index);
                        return ListTile(
                          title: Text(
                              messages[key] == '0' ? 'HR:' : 'Пользователь:'),
                          subtitle: Text(key),
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
