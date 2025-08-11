import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({
    super.key,
    required this.pages, // [Home(), Family(), Calendar(), Settings()]
    this.initialIndex = 0,
    this.homeOnly = false, // <-- 추가: 홈에서만 바텀바 표시
  }) : assert(pagesLength == 4, 'pages는 4개(홈/가족/캘린더/설정)');

  final List<Widget> pages;
  final int initialIndex;
  final bool homeOnly; // <-- 추가

  static int get pagesLength => 4;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // 홈에서만 바텀바 쓰는 모드면: 홈(0번)만 보여주고 하단 바에서 push로 진입
    if (widget.homeOnly) {
      final bottom = _buildBottomBar(context, currentIndex: 0, homeOnly: true);
      return Scaffold(
        backgroundColor: Colors.white,
        body: widget.pages[0], // HOME만 표시
        bottomNavigationBar: Platform.isIOS
            ? MediaQuery.removePadding(
            context: context, removeBottom: true, child: bottom)
            : bottom,
      );
    }

    // 기존: 모든 탭에서 바텀바 유지 + IndexedStack
    final bottom = _buildBottomBar(context, currentIndex: _index, homeOnly: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index,
        children: widget.pages,
      ),
      bottomNavigationBar: Platform.isIOS
          ? MediaQuery.removePadding(
          context: context, removeBottom: true, child: bottom)
          : bottom,
    );
  }

  Widget _buildBottomBar(BuildContext context,
      {required int currentIndex, required bool homeOnly}) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDDDDDD), width: 1), // 회색 구분선
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: Platform.isIOS ? (safeBottom == 0 ? 20 : safeBottom) : 0,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: currentIndex,
        onTap: (i) {
          if (homeOnly) {
            // 홈에서만 바텀바: 다른 탭은 push로 풀스크린 진입
            switch (i) {
              case 0:
              // 홈 아이콘 재탭 시 스크롤 탑/리프레시 트리거 등 원하는 동작 넣어도 됨
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => widget.pages[1]),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => widget.pages[2]),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => widget.pages[3]),
                );
                break;
            }
          } else {
            // 기존 방식: 탭 전환에 따라 IndexedStack 인덱스 변경
            setState(() => _index = i);
          }
        },
        items: <BottomNavigationBarItem>[
          _buildItem(
            label: 'HOME',
            iconPath: 'assets/icons/ic_nav_home.svg',
            activeIconPath: 'assets/icons/ic_nav_home_active.svg',
          ),
          _buildItem(
            label: 'FAMILY',
            iconPath: 'assets/icons/ic_nav_family.svg',
            activeIconPath: 'assets/icons/ic_nav_family_active.svg',
          ),
          _buildItem(
            label: 'Calendar',
            iconPath: 'assets/icons/ic_nav_calendar.svg',
            activeIconPath: 'assets/icons/ic_nav_calendar_active.svg',
          ),
          _buildItem(
            label: 'Settings',
            iconPath: 'assets/icons/ic_nav_settings.svg',
            activeIconPath: 'assets/icons/ic_nav_settings_active.svg',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({
    required String label,
    required String iconPath,
    required String activeIconPath,
  }) {
    return BottomNavigationBarItem(
      icon: _NavIcon(label: label, asset: iconPath, isActive: false),
      activeIcon: _NavIcon(label: label, asset: activeIconPath, isActive: true),
      label: label,
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.label, required this.asset, required this.isActive});

  final String label;
  final String asset;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(asset, width: 24, height: 24, fit: BoxFit.contain),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? const Color(0xFF111111) : const Color(0xFF808080),
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            height: 1.44,
          ),
        ),
      ],
    );
  }
}
