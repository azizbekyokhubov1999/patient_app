import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../manager/main_navigation_cubit.dart';

class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  late final MainNavigationCubit _mainNavigationCubit;

  @override
  void initState() {
    super.initState();
    _mainNavigationCubit = MainNavigationCubit()
      ..setTabIndex(widget.navigationShell.currentIndex);
  }

  void _onTap(int index) {
    _mainNavigationCubit.setTabIndex(index);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant MainWrapperPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _mainNavigationCubit.setTabIndex(widget.navigationShell.currentIndex);
    }
  }

  @override
  void dispose() {
    _mainNavigationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mainNavigationCubit,
      child: BlocBuilder<MainNavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: _onTap,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.secondaryText,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Appointment',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  activeIcon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
