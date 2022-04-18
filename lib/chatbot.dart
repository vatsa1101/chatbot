import 'package:chatbot/auth_controller.dart';
import 'package:chatbot/chat_controller.dart';
import 'package:chatbot/infotext.dart';
import 'package:chatbot/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import './colors.dart';
import './utils.dart';

List messages = [];

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  bool isWriting = false;
  final ScrollController _listController = ScrollController();
  FocusNode textfieldFocus = FocusNode();
  final ChatController chatController = Get.put(ChatController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Obx(
        () => GestureDetector(
          onTap: () => textfieldFocus.unfocus(),
          onPanUpdate: (details) {
            if (details.delta.dy < 0) {
              textfieldFocus.requestFocus();
            } else {
              textfieldFocus.unfocus();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Flexible(
                child: chatController.isLoading.value
                    ? Center(
                        child: SizedBox(
                          width: size.width * 0.45,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  child: Lottie.asset(
                                'assets/images/chat.json',
                                height: 60,
                              )),
                              Expanded(
                                  child: Center(
                                      child: Text('Loading',
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                              fontSize: 16))))
                            ],
                          ),
                        ),
                      )
                    : chatController.chats.isNotEmpty
                        ? ListView.builder(
                            itemCount: chatController.chats.length,
                            reverse: true,
                            controller: _listController,
                            itemBuilder: (context, i) {
                              return chatItem(
                                chatController.chats[i].sentByUser,
                                chatController.chats[i].text,
                                chatController.chats[i].id,
                                key: chatController.chats[i].id,
                              );
                            },
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: SingleChildScrollView(
                                  primary: false,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        alignment: Alignment.centerLeft,
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (rect) =>
                                              const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.white,
                                              Colors.white,
                                            ],
                                          ).createShader(rect),
                                          child: Image.asset(
                                            'assets/images/gradient.png',
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                      chatItem(
                                          false,
                                          "Hi, ${Utils.capitalize(FirebaseAuth.instance.currentUser!.displayName.toString()).split(" ")[0]}. Your Oculus Assistant here. There's a lot I can help with. Here are a few popular Questions",
                                          null),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 10),
                                          child: InfoText(const [
                                            ' You can Copy the text by clicking on it\n',
                                            ' To delete any chat You can double tap or long press any message\n',
                                            ' Swipe up or down on Text field to trigger or dismiss keyboard',
                                          ])),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 10,
                                            bottom: 20),
                                        child: const Text(
                                          'Try saying',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.cyan,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      chatItem(true, "What is Oculus ?", null),
                                      chatItem(
                                          true,
                                          "Are the Pronites offline or online ?",
                                          null),
                                      chatItem(
                                          true,
                                          "What is the theme of Oculus 2022 ?",
                                          null),
                                      chatItem(
                                          true,
                                          "What are the dates of Oculus 2022 ?",
                                          null),
                                    ],
                                  ),
                                )),
                          ),
              ),
              chatController.waitingForResponse.value
                  ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(
                          horizontal: size.width * 0.18, vertical: 10),
                      child: Image.asset(
                        'assets/images/808.gif',
                        height: 15,
                      ))
                  : Container(),
              chatControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textFieldController,
              focusNode: textfieldFocus,
              // readOnly: waiting_for_response,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              onChanged: (val) {
                (val.isNotEmpty && val.trim() != "")
                    ? setWritingTo(true)
                    : setWritingTo(false);
              },
              decoration: InputDecoration(
                hintText: chatController.waitingForResponse.value
                    ? 'Waiting for Response'
                    : 'Say Hi !',
                hintStyle: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 16,
                ),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                filled: true,
                fillColor: AppColors.separatorColor,
                suffix: InkWell(
                  onTap: () async {
                    Get.showOverlay(
                      asyncFunction: () async {
                        await authController.signOut();
                        Get.offAll(() => const LoginScreen());
                      },
                      loadingWidget: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blueColor,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.logout,
                    size: 16,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
            ),
          ),
          isWriting &&
                  !chatController.waitingForResponse.value &&
                  textFieldController.text.trim() != ""
              ? GestureDetector(
                  onTap: () {
                    chatController.sendMessage(
                        context, textFieldController.text.trim());
                    textFieldController.text = "";
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        gradient: AppColors.fabGradient,
                        shape: BoxShape.circle),
                    child: const Icon(
                      Icons.send,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(left: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      gradient: AppColors.fabGradient,
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.send,
                    size: 22,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
        ],
      ),
    );
  }

  handleDeleteMessage(key) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            elevation: 10,
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text(
              "Remove this Message ? ",
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Divider(
                color: Colors.cyan[900],
                thickness: 0.8,
                indent: 10,
                endIndent: 10,
              ),
              SimpleDialogOption(
                child: Text(
                  'Once you Remove this message you cant undo it.This Message will be deleted from all the databases also.',
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SimpleDialogOption(
                      onPressed: () {
                        chatController.deleteMessage(key);
                        Navigator.pop(context);
                      },
                      child: Text('Delete',
                          style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                  Container(
                    height: 25,
                    width: 1,
                    color: Colors.black54,
                  ),
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)))
                ],
              )
            ],
          );
        });
  }

  Widget chatItem(x, text, key_for_deleting, {key}) {
    Radius r = const Radius.circular(10);
    return GestureDetector(
      onLongPress: key_for_deleting == null
          ? () {}
          : () {
              handleDeleteMessage(key_for_deleting);
            },
      onDoubleTap: key_for_deleting == null
          ? () {}
          : () {
              handleDeleteMessage(key_for_deleting);
            },
      onTap: () {
        Clipboard.setData(ClipboardData(text: text)).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            duration: Duration(milliseconds: 500),
            content: Text(
              'Text Copied  ✔️',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ));
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        alignment: x ? Alignment.centerRight : Alignment.centerLeft,
        child: x
            ? chatLayout(
                text,
                AppColors.fabGradient,
                BorderRadius.only(
                  topLeft: r,
                  topRight: r,
                  bottomLeft: r,
                ),
                Offset(-2, 4))
            : chatLayout(
                text,
                AppColors.fabGradient2,
                BorderRadius.only(
                  bottomRight: r,
                  topRight: r,
                  bottomLeft: r,
                ),
                Offset(2, 4)),
      ),
    );
  }

  Widget chatLayout(message, gr, br, of) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: of,
              blurRadius: 4,
              spreadRadius: 2)
        ],
        gradient: gr,
        color: AppColors.fgGray,
        // border: Border.all(color: Colors.white, width: 0.1),
        borderRadius: br,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
