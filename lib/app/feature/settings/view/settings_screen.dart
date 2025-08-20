import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.name = 'Jaehyun Park',
    this.email = 'jaehyun.park@email.com',
    this.avatarImage,
  });

  final String name;
  final String email;
  final ImageProvider? avatarImage;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color kPrimary = Color(0xFFDE496E);
  static const Color kBg = Colors.white;

  bool _notificationsOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile
            Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xE5E7EB),
                  backgroundImage: widget.avatarImage,
                  child: widget.avatarImage == null
                      ? const Icon(Icons.person,
                          size: 44, color: Color(0xFF8E8E93))
                      : null,
                ),
                const SizedBox(height: 16),
                Text(widget.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2)),
                const SizedBox(height: 6),
                Text(widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kPrimary)),
              ],
            ),

            const SizedBox(height: 50),

            const _SectionTitle('Notifications'),
            const SizedBox(height: 8),
            _TileSurface(
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Notifications',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Switch.adaptive(
                    value: _notificationsOn,
                    //inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white30,
                    activeColor: kPrimary,
                    onChanged: (v) => setState(() => _notificationsOn = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const _SectionTitle('Account'),
            const SizedBox(height: 8),
            _NavItem(
                label: 'Connected accounts',
                onTap: () {
                  /* TODO */
                }),
            const SizedBox(height: 10),
            _NavItem(
                label: 'Log out',
                onTap: () {
                  /* TODO */
                }),
            const SizedBox(height: 10),
            _NavItem(
              label: 'Delete account',
              danger: true,
              onTap: () {
                /* TODO */
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.1),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;
  static const Color kPrimary = Color(0xFFDE496E);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2E6EA),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text('',
            style: TextStyle()), // dummy to keep const? -> remove.
      );
}

class _TileSurface extends StatelessWidget {
  const _TileSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1F000000)),
          ),
          child: child,
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, this.onTap, this.danger = false});

  final String label;
  final VoidCallback? onTap;
  final bool danger;
  static const Color kDanger = Color(0xFFDE496E);

  @override
  Widget build(BuildContext context) => _TileSurface(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: danger ? kDanger : null,
                      )),
                ),
                const Icon(Icons.chevron_right_rounded, size: 24),
              ],
            ),
          ),
        ),
      );
}
