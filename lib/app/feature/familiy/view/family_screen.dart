import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Family {
  final String name;
  final String image; // 네트워크/에셋 모두 허용
  final List<Member> members;

  Family({required this.name, required this.image, required this.members});
}

class Member {
  final String name;
  final String avatar; // URL or asset
  Member(this.name, this.avatar);
}

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  // 서버 연동 전 임시 상태
  Family? _family; // null이면 "가족 없음" 상태
  String get _inviteUrl =>
      'https://with.app/invite/abcdef123456'; // 서버에서 받은 토큰 URL
  static const MethodChannel _shareCh = MethodChannel('app.share');

  @override
  void initState() {
    super.initState();

    _family = Family(
        name: '우리 가족',
        image: 'assets/images/family_temporary.png',
        members: [
          Member('나', 'assets/images/profile.png'),
          Member('엄마', 'assets/images/profile.png'),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final hasFamily = _family != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('가족')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // 둥근 직사각형 카드
                InkWell(
                  onTap: hasFamily
                      ? () {
                          // 가족 이미지 탭 → 가족 전용 채팅방
                          context.pushNamed('familyChat');
                        }
                      : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 260),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    child: hasFamily ? _familyCard(_family!) : _emptyCard(),
                  ),
                ),
                const SizedBox(height: 20),
                // 초대 버튼 (항상 노출해도 되고, 가족 없을 때만 보여도 됨)
                _inviteButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> shareToKakao(String text) async {
    await _shareCh.invokeMethod('shareToKakao', {'text': text});
  }

  // 가족 없음 카드
  Widget _emptyCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        // placeholder 이미지
        SizedBox(
          width: 120,
          height: 120,
          child: Image.asset(
            'assets/images/family_empty.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.family_restroom, size: 72, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '아직 가족이 없습니다.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          '가족을 초대해 일정을 함께 공유해보세요.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 가족 있음 카드
  Widget _familyCard(Family family) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단: 가족 이미지 + 이름
        Row(
          children: [
            Ink(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(
                  image: family.image.startsWith('http')
                      ? NetworkImage(family.image)
                      : AssetImage(family.image) as ImageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.family_restroom,
                      size: 36,
                      color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                family.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('가족 구성원',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _memberChips(family.members),
        const SizedBox(height: 12),
        const Text(
          '가족 이미지를 탭하면 가족 전용 채팅방으로 이동합니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _memberChips(List<Member> members) {
    if (members.isEmpty) {
      return const Text('아직 구성원이 없습니다.', style: TextStyle(color: Colors.grey));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: members.map((m) {
        final provider = m.avatar.startsWith('http')
            ? NetworkImage(m.avatar)
            : AssetImage(m.avatar) as ImageProvider;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 10, backgroundImage: provider),
              const SizedBox(width: 6),
              Text(m.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 초대 버튼 (OS 공유 시트 + 복사/QR 등은 바텀시트로 확장 가능)
  Widget _inviteButton() {
    return SizedBox(
      width: 250,
      height: 56,
      child: ElevatedButton(
        onPressed: _openInviteSheet,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFFDE496E), Color(0xFFFF6E91)]),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: const Center(
            child: Text('가족 초대하기',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _openInviteSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                const Text('가족 초대',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('카카오톡 등 메신저로 링크를 공유하세요.',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.ios_share),
                  title: const Text('공유하기'),
                  onTap: () async {
                    await shareToKakao('가족 초대 링크: $_inviteUrl');
                    if (mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('링크 복사'),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: _inviteUrl));
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('링크가 복사됐어요.')));
                    }
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==== 데모용: 수락 완료 후 가족 생성/업데이트 시 호출 ====
  void simulateAccept() {
    setState(() {
      _family ??= Family(
        name: 'With 우리 가족',
        image: 'assets/images/family_photo.jpg',
        members: [
          Member('나', 'assets/avatars/me.png'),
          Member('엄마', 'assets/avatars/mom.png'),
        ],
      );
      // 새 멤버 추가 예시:
      _family!.members.add(Member('아빠', 'assets/avatars/dad.png'));
    });
  }
}
