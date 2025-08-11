import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottom = Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
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
        currentIndex: idx,
        onTap: (i) {
          // 같은 탭을 다시 누르면 루트로 스냅(원치 않으면 false)
          navigationShell.goBranch(i, initialLocation: i == idx);
        },
        items: [
          _item(
            label: 'HOME',
            iconPath: 'assets/icons/ic_nav_home.svg',
            activeIconPath: 'assets/icons/ic_nav_home_active.svg',
          ),
          _item(
            label: 'Family',
            iconPath: 'assets/icons/ic_nav_family.svg',
            activeIconPath: 'assets/icons/ic_nav_family_active.svg',
          ),
          _item(
            label: 'Calendar',
            iconPath: 'assets/icons/ic_nav_calendar.svg',
            activeIconPath: 'assets/icons/ic_nav_calendar_active.svg',
          ),
          _item(
            label: 'Settings',
            iconPath: 'assets/icons/ic_nav_settings.svg',
            activeIconPath: 'assets/icons/ic_nav_settings_active.svg',
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell, // <- 현재 브랜치 화면이 여기 그려짐
      bottomNavigationBar: Platform.isIOS
          ? MediaQuery.removePadding(
              context: context, removeBottom: true, child: bottom)
          : bottom,
    );
  }
}

class _item extends BottomNavigationBarItem {
  _item({
    required String label,
    required String iconPath,
    required String activeIconPath,
  }) : super(
          label: label,
          icon: _NavIcon(label: label, asset: iconPath, isActive: false),
          activeIcon:
              _NavIcon(label: label, asset: activeIconPath, isActive: true),
        );
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(
      {required this.label, required this.asset, required this.isActive});

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
