import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () => _showBottomSheet(isMe),
        child: isMe ? _myMessage() : _senderMessage());
  }

  // Sender's message (Blue/Grey modern theme)
  Widget _senderMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Padding(
      padding: EdgeInsets.only(left: mq.width * .03, right: mq.width * .2, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 4 : 12),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ]),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg, style: const TextStyle(fontSize: 15, color: Colors.black87))
                : _imageWidget(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // My message (Premium Blue theme)
  Widget _myMessage() {
    return Padding(
      padding: EdgeInsets.only(right: mq.width * .03, left: mq.width * .2, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 4 : 12),
            decoration: const BoxDecoration(
                color: Color(0xFFE8F0FE), // Light Blue tint
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ]),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg, style: const TextStyle(fontSize: 15, color: Color(0xFF174EA6)))
                : _imageWidget(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, top: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(width: 4),
                Icon(
                  widget.message.read.isNotEmpty ? Icons.done_all : Icons.done,
                  size: 14,
                  color: widget.message.read.isNotEmpty ? Colors.blue : Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.message.msg,
        placeholder: (context, url) => const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.image, size: 70, color: Colors.grey),
      ),
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                _OptionItem(
                    icon: const Icon(Icons.copy_rounded, color: Colors.blueAccent),
                    name: 'Copy Text',
                    onTap: (ctx) {
                      Clipboard.setData(ClipboardData(text: widget.message.msg)).then((_) {
                        Navigator.pop(ctx);
                        Dialogs.showSnackbar(ctx, 'Text Copied!');
                      });
                    }),
                if (isMe && widget.message.type == Type.text)
                  _OptionItem(
                      icon: const Icon(Icons.edit_rounded, color: Colors.orangeAccent),
                      name: 'Edit Message',
                      onTap: (ctx) {
                        Navigator.pop(ctx);
                        _showMessageUpdateDialog(ctx);
                      }),
                if (isMe)
                  _OptionItem(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      name: 'Delete Message',
                      onTap: (ctx) {
                        APIs.deleteMessage(widget.message).then((_) => Navigator.pop(ctx));
                      }),
                const Divider(),
                _OptionItem(
                    icon: const Icon(Icons.info_outline, color: Colors.grey),
                    name: 'Sent At: ${MyDateUtil.getMessageTime(time: widget.message.sent)}',
                    onTap: (_) {}),
              ],
            ),
          );
        });
  }

  void _showMessageUpdateDialog(BuildContext ctx) {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Update Message'),
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (val) => updatedMsg = val,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.message_outlined, color: Colors.blue)),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      APIs.updateMessage(widget.message, updatedMsg);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    child: const Text('Update'))
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function(BuildContext) onTap;

  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(name, style: const TextStyle(fontSize: 15, color: Colors.black87, letterSpacing: 0.5)),
      onTap: () => onTap(context),
    );
  }
}
