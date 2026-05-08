import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';
import 'profile_image.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))
          ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: Hero(
                    tag: widget.user.id,
                    child: ProfileImage(size: mq.height * .06, url: widget.user.image),
                  ),
                ),
                title: Text(widget.user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF202124))),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? '📷 Image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                  style: TextStyle(
                    color: (_message != null && _message!.read.isEmpty && _message!.fromId != APIs.user.uid)
                        ? const Color(0xFF1A73E8)
                        : const Color(0xFF5F6368),
                    fontWeight: (_message != null && _message!.read.isEmpty && _message!.fromId != APIs.user.uid)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(color: Color(0xFF1A73E8), shape: BoxShape.circle),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                            style: const TextStyle(color: Color(0xFF80868B), fontSize: 12),
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
