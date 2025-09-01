import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const kBg = Colors.white;
  static const kMine = Color(0xFFFF6E91);     // 내 말풍선
  static const kOther = Color(0xFFF5F6F8);    // 상대 말풍선
  static const kTextDark = Color(0xFF0E1B2A); // 어두운 본문색
  static const kSubtle = Color(0xFF9AA3AE);

  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = <_Msg>[
    _Msg(
      text: "Hey there! How’s your day going?",
      isMe: false,
      sender: "Sophia",
    ),
    _Msg(
      text:
      "Hi Sophia! It’s been pretty good, just finished a workout. How about yours?",
      isMe: true,
      sender: "Me",
    ),
    _Msg(
      text:
      "That's awesome! I had a productive morning at work, now relaxing with a book.",
      isMe: false,
      sender: "Sophia",
    ),
    _Msg(
      text: "Sounds perfect! What are you reading?",
      isMe: true,
      sender: "Me",
    ),
    _Msg(
      text:
      "A mystery novel, it's quite gripping. You should try it sometime!",
      isMe: false,
      sender: "Sophia",
    ),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isMe: true, sender: "Me"));
    });
    _controller.clear();
    // 스크롤 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: kTextDark),
        title: const Text('Chat',
            style: TextStyle(
              color: kTextDark,
              fontWeight: FontWeight.w800,
            )),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final align =
                  m.isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
                  final bubbleColor = m.isMe ? kMine : kOther;
                  final textColor = m.isMe ? Colors.white : kTextDark;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: align,
                    children: [
                      if (!m.isMe) ...[
                        _avatar("S"),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: m.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.sender,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kSubtle,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: Radius.circular(m.isMe ? 20 : 6),
                                  bottomRight:
                                  Radius.circular(m.isMe ? 6 : 20),
                                ),
                              ),
                              child: Text(
                                m.text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (m.isMe) ...[
                        const SizedBox(width: 8),
                        _avatar("M"),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            _Composer(
              controller: _controller,
              onSend: _send,
              accent: kMine, // 0xFFFF6E91
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String initials) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFF1E6E9),
      child: Text(
        initials,
        style: const TextStyle(
          color: kTextDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.accent,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 42,
            width: 42,
            child: Material(
              color: accent, // 0xFFFF6E91
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSend,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  final String sender;
  const _Msg({required this.text, required this.isMe, required this.sender});
}
