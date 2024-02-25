import 'package:chat_ui_kit/chat_ui_kit.dart' hide ChatMessageImage;
import 'package:chatapp/MyBehavior.dart';
import 'package:chatapp/Providers/ChatProvider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:get/get.dart';
import 'package:chatapp/util/ChatMessageAudio.dart' as cau;
import 'package:provider/provider.dart';
import '../../constant/AppString.dart';
import '../../main.dart';
import '../../util/MessageInput.dart' as msg;
import '../../util/MessageContainer.dart' as msgc;
import '../../util/ChatMessageVideo.dart' as cmv;
import '../../Providers/ThemeProvider.dart';
import '../../constant/AppColors.dart';
import '../../model/chat.dart';
import '../../model/chat_message.dart';
import '../../util/chat_message_image.dart';
import '../../util/date_formatter.dart';
import '../../util/switch_appbar.dart';
import 'chat_viewmodel.dart';



part 'chat_screen.g.dart';

class ChatScreenArgs {
  /// Pass the chat for an already existing chat
  final ChatWithMembers chat;

  ChatScreenArgs({required this.chat});
}

class ChatScreen extends StatefulWidget {


  @override
  _ChatScreenSate createState() => _ChatScreenSate();
}

class _ChatScreenSate extends State<ChatScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var reciver=(ModalRoute.of(context)!.settings.arguments as Map)['user'];
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return ChangeNotifierProvider(
      create: (_) =>ChatProvider(reciver),
      child: Consumer(
        builder: (BuildContext context,ChatProvider provider, Widget? child)=> Scaffold(
            floatingActionButtonLocation: ExpandableFab.location,
          backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
            appBar: SwitchAppBar(
              showSwitch: provider.controller.isSelectionModeActive,
              switchLeadingCallback: () => provider.controller.unSelectAll(),
              primaryAppBar: AppBar(
                title: provider.chat==null?Container():GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.searchUserScreen,arguments: {"user":provider.reciver!.uid});
                    },
                    child: provider.buildChatTitle()),
                actions: [
                  // IconButton(

                  //     icon: Icon(Icons.more_vert), onPressed: provider.onChatDetailsPressed)
                ],
              ),
              switchTitle: Text(provider.selectedItemsCount.toString(),
                  style: TextStyle(color: Colors.white)),
              switchActions: [
                IconButton(
                    icon: Icon(Icons.content_copy),
                    color: Colors.white,
                    onPressed: provider.copyContent),
                // IconButton(
                //     color: Colors.white,
                //     icon: Icon(Icons.delete),
                //     onPressed: provider.deleteSelectedMessages),
              ],
            ),
            floatingActionButton:  customeSend(provider),
            body: provider.chat==null?Center(child: CircularProgressIndicator(),):Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMessagesList(provider),
                Theme(
                  data:  ThemeData(
                      primarySwatch:MaterialColor(0xFF082480, AppColors.color),
                      fontFamily: "okra",
                      textTheme: TextTheme(subtitle1: TextStyle(color: themeBlack?Colors.white:Colors.black)),
                      ),
                  child: msg.MessageInput(
                      textController: provider.textController,
                      sendphoto:provider.onSendPhoto,
                      sendaudio: provider.onSendAuddio,
                      sendvideo: provider.onSendVideo,
                      sendCallback: provider.onMessageSend,
                      typingCallback: provider.onTypingEvent),
                ),
              ],
            )),
      ),
    );
  }
  Widget buildMessagesList(ChatProvider provider) {
    IncomingMessageTileBuilders incomingBuilders;
    if (false) {
      incomingBuilders = IncomingMessageTileBuilders(
        bodyBuilder: (context, index, item, messagePosition) =>
            buildMessageBody(context, index, item, messagePosition,
                MessageFlow.incoming),
        avatarBuilder: (context, index, item, messagePosition) {
          final _chatMessage = item as ChatMessage;
          return Padding(
              padding: EdgeInsets.only(right: 16),
              child: ClipOval(
                  child: Image.asset(_chatMessage.author!.avatar,
                      width: 32, height: 32, fit: BoxFit.cover)));
        });
    } else {
      incomingBuilders = IncomingMessageTileBuilders(
        bodyBuilder: (context, index, item, messagePosition) =>
            buildMessageBody(context, index, item, messagePosition,
                MessageFlow.incoming),
        titleBuilder: null);
    }

    return Expanded(
        child: RefreshIndicator(
          onRefresh: () async{
            provider.fetchlist();
          },
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: MessagesList(
                controller: provider.controller,
                appUserId: provider.senderMember!.id,
                useCustomTile: (i, item, pos) {
                  final msg = item as ChatMessage;
                  return msg.isTypeEvent;
                },
                messagePosition: provider.messagePosition,
                builders: MessageTileBuilders(
                    customTileBuilder: provider.buildEventMessage,
                    customDateBuilder: provider.buildDate,
                    incomingMessageBuilders: incomingBuilders,
                    outgoingMessageBuilders: OutgoingMessageTileBuilders(
                        bodyBuilder: (context, index, item, messagePosition) =>
                            buildMessageBody(context, index, item, messagePosition,
                                MessageFlow.outgoing)))),
          ),
        ));
  }
  /// Called when a user tapped an item
  void onItemPressed(int index, MessageBase message) {
    print(
        "item pressed, you could display images in full screen or play videos with this callback");
  }
  Widget buildMessageBody(
      context, index, item, messagePosition, MessageFlow messageFlow) {
    final _chatMessage = item as ChatMessage;
    Widget _child;

    if (_chatMessage.type == ChatMessageType.text) {
      _child = _chatMessageText(context,index, item, messagePosition, messageFlow);
    } else if (_chatMessage.type == ChatMessageType.image) {
      _child = ChatMessageImage(index, item, messagePosition, messageFlow,
          callback: () => onItemPressed(index, item));
    } else if (_chatMessage.type == ChatMessageType.video) {
      _child = cmv.ChatMessageVideo(index, item, messagePosition, messageFlow);
    } else if (_chatMessage.type == ChatMessageType.audio) {
      _child = cau.ChatMessageAudio(index, item, messagePosition, messageFlow);
    } else {
      //return text message as default
      _child = _chatMessageText(context,index, item, messagePosition, messageFlow);
    }

    if (messageFlow == MessageFlow.incoming) return _child;
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Align(alignment: Alignment.centerRight, child: _child));
  }

  customeSend(ChatProvider provider) {
    return ExpandableFab(
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.file_open_outlined,color: Colors.white,),
        fabSize: ExpandableFabSize.small,
        // foregroundColor: Colors.amber,
        backgroundColor: AppColors.primaryDark,
        shape: const CircleBorder(),
      ),
      overlayStyle:ExpandableFabOverlayStyle(
        color: Colors.transparent,
      ),
      children: [
        Container(
          // height: 30,width: 30,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: AppColors.primaryDark,),
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red)
            ),
            onPressed: provider.onSendPhoto,
            icon: FaIcon(FontAwesomeIcons.photoVideo,color: Colors.white,size: 10,),),
        ),
        Visibility(
          visible: true,
          child: Container(
            // height: 30,width: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: AppColors.primaryDark,),
            child: IconButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.green)
              ),
              onPressed: provider.onSendAuddio,
              icon: FaIcon(FontAwesomeIcons.fileAudio,color: Colors.white,size: 10,),),
          ),
        ),
        Visibility(
          visible: true,
          child: Container(
            // height: 30,width: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: AppColors.primaryDark,),
            child: IconButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.yellow)
              ),
              onPressed: provider.onSendVideo,
              icon: FaIcon(FontAwesomeIcons.video,color: Colors.white,size: 10,),),
          ),
        ),
      ],
    );
  }
}

///************************************************ Functional widgets used in the screen ***************************************
@swidget
Widget _chatMessageText(BuildContext context, int index, ChatMessage message,
    MessagePosition messagePosition, MessageFlow messageFlow) {
  print(messagePosition);
  var themeBlack=context.read<ThemeProvider>().darkTheme;
  return msgc.MessageContainer(
      decoration: messageDecoration(context,
          messagePosition: messagePosition, messageFlow: messageFlow),
      child: Container(
        child: Wrap(
            runSpacing: 4.0, alignment: WrapAlignment.end, children: [
          Text(message.text ?? "",style: TextStyle(color: themeBlack?Colors.white:Colors.white),),
          ChatMessageFooter(index, message, messagePosition, messageFlow)
        ]),
      ));
}
@swidget
Widget chatMessageFooter(BuildContext context, int index, ChatMessage message,
    MessagePosition messagePosition, MessageFlow messageFlow) {
  final Widget _date = _chatMessageDate(context,index, message, messagePosition);
  return messageFlow == MessageFlow.incoming
      ? _date
      : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _date,
      ]);
}

@swidget
Widget _chatMessageDate(BuildContext context, int index, ChatMessage message,
    MessagePosition messagePosition) {
  var themeBlack=context.read<ThemeProvider>().darkTheme;
  final color = //themeBlack?Colors.grey[600]! :
  message.isTypeMedia ? Colors.white : Colors.grey[600]!;
  return Padding(
      padding: EdgeInsets.only(left: 8),
      child: Text(
          DateFormatter.getVerboseDateTimeRepresentation(
              context, message.createdAt,
              timeOnly: true),
          style: TextStyle(color: color)));
}