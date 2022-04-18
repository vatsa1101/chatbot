import 'package:chatbot/chat.dart';
import 'package:chatbot/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool waitingForResponse = false.obs;
  RxList<Chat> chats = RxList<Chat>([]);
  late DialogFlowtter dialogFlowtter;

  @override
  void onInit() {
    super.onInit();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    chats.listen((p0) {
      isLoading.value = false;
    });
    isLoading.value = true;
    getData();
  }

  Future<bool> getData() async {
    chats.bindStream(await getChats());
    return true;
  }

  Future<Stream<List<Chat>>> getChats() async {
    return FirebaseFirestore.instance
        .collection('Chat')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chats')
        .orderBy('time')
        .snapshots()
        .map((query) => query.docs
            .map((e) {
              return Chat(
                id: e.id,
                sentByUser: e["sentByUser"],
                text: e["text"],
                time: DateTime.parse(e["time"]),
              );
            })
            .toList()
            .reversed
            .toList());
  }

  Future<void> sendMessage(BuildContext context, String text) async {
    waitingForResponse.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('Chat')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .add({
        'sentByUser': true,
        'time': DateTime.now().toIso8601String(),
        'text': text,
      });

      DetectIntentResponse response = await dialogFlowtter
          .detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)),
      )
          .catchError((e) {
        waitingForResponse.value = false;
      });

      waitingForResponse.value = false;

      await FirebaseFirestore.instance
          .collection('Chat')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .add({
        'sentByUser': false,
        'time': DateTime.now().toIso8601String(),
        'text': response.text,
      });
    } catch (e) {
      waitingForResponse.value = false;
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Dialog(
                backgroundColor: AppColors.fgGray,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0)), //this right here
                child: SizedBox(
                  height: 210,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView(
                      children: [
                        Image.asset('assets/images/nonet.gif', height: 150),
                        const Text('Some Error Occurerd',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('Chat')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(id)
          .delete();
    } catch (e) {}
  }
}
