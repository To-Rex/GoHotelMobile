import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../controllers/main_controller.dart';
import '../../../core/layout/layout.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../home/views/home_page.dart';
import '../../tasks/views/tasks_page.dart';
import '../../notifications/views/notifications_page.dart';
import '../../profile/views/profile_page.dart';

// Web frontend bilan bir xil ko'k primary aksent
const _staffNavigationAccent = AppColors.primary;

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = AppBreakpoints.forWidth(constraints.maxWidth);
        final ultraCompact = AppBreakpoints.isUltraCompactWidth(
          constraints.maxWidth,
        );
        final useRail = breakpoint.isAtLeastMedium;
        final railWidth = breakpoint.isExpanded ? 232.0 : 84.0;

        return Scaffold(
          backgroundColor: AppColors.surface,
          // Telefonlarda suzuvchi navigatsiya kontent ustida turadi;
          // planshet/desktopda u doimiy railga aylanadi.
          // On an ultra-small display the bar takes a reserved slot instead
          // of floating above a page. This prevents the final list/form
          // controls from sitting underneath the essential navigation.
          extendBody: !useRail && !ultraCompact,
          body: Row(
            children: [
              if (useRail)
                SizedBox(
                  width: railWidth,
                  child: _StaffNavigationRail(
                    expanded: breakpoint.isExpanded,
                    currentIndex: controller.currentIndex,
                    onChanged: controller.changeTab,
                  ),
                ),
              if (useRail)
                Container(
                  width: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.44),
                ),
              // Row ichidagi doimiy uchinchi element: rail kengligi o'zgarsa
              // ham IndexedStack va uning scroll/form holatlari saqlanadi.
              Expanded(child: _buildPages()),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : Obx(
                  () => AppBottomNavBar(
                    currentIndex: controller.currentIndex.value,
                    onTabChanged: controller.changeTab,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPages() {
    return Obx(() {
      final index = controller.currentIndex.value;
      // Animated wrapper keeps one stable IndexedStack element. That retains
      // per-tab scroll and form state while still replaying the transition.
      return _PreservedTabTransition(
        index: index,
        child: IndexedStack(
          index: index,
          children: const [
            HomePage(),
            TasksPage(),
            NotificationsPage(),
            ProfilePage(),
          ],
        ),
      );
    });
  }
}

/// Replays a lightweight composited transition without keying/recreating the
/// [IndexedStack] below it. This is especially important when switching tabs
/// on low-powered devices: each page keeps its existing state and data.
class _PreservedTabTransition extends StatefulWidget {
  const _PreservedTabTransition({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_PreservedTabTransition> createState() =>
      _PreservedTabTransitionState();
}

class _PreservedTabTransitionState extends State<_PreservedTabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.base);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (_reduceMotion) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _PreservedTabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;

    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        final progress = _controller.value;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}

class _StaffNavigationRail extends StatelessWidget {
  final bool expanded;
  final RxInt currentIndex;
  final ValueChanged<int> onChanged;

  const _StaffNavigationRail({
    required this.expanded,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_outlined, Icons.home_rounded, 'Bosh'),
      (Icons.assignment_outlined, Icons.assignment_rounded, 'Vazifalar'),
      (Icons.notifications_outlined, Icons.notifications_rounded, 'Xabarlar'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest),
      child: SafeArea(
        right: false,
        child: RepaintBoundary(
          child: Column(
            children: [
              _StaffRailBrand(expanded: expanded),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  expanded ? 18 : 12,
                  8,
                  expanded ? 18 : 12,
                  12,
                ),
                child: Container(
                  height: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              Expanded(
                child: Obx(
                  () {
                    // MUHIM: observable Obx builder'ining O'ZIDA o'qiladi —
                    // itemBuilder lazy chaqirilgani uchun undagi o'qish GetX
                    // kuzatuviga tushmay, "improper use" xatosi otilardi.
                    final selectedIndex = currentIndex.value;
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: expanded ? 8 : 6,
                        vertical: 2,
                      ),
                      itemCount: destinations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        return _StaffRailItem(
                          expanded: expanded,
                          selected: selectedIndex == index,
                          outline: destination.$1,
                          filled: destination.$2,
                          label: destination.$3,
                          onTap: () => onChanged(index),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffRailBrand extends StatelessWidget {
  const _StaffRailBrand({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _staffNavigationAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.hotel_rounded,
        color: AppColors.onPrimary,
        size: 22,
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        expanded ? 18 : 12,
        16,
        expanded ? 18 : 12,
        4,
      ),
      child: expanded
          ? Row(
              children: [
                mark,
                const SizedBox(width: 11),
                Text(
                  'Go Hotel',
                  style: AppTextStyles.bodyLg(
                    color: AppColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            )
          : Tooltip(
              message: 'Go Hotel',
              child: Center(child: mark),
            ),
    );
  }
}

class _StaffRailItem extends StatelessWidget {
  const _StaffRailItem({
    required this.expanded,
    required this.selected,
    required this.outline,
    required this.filled,
    required this.label,
    required this.onTap,
  });

  final bool expanded;
  final bool selected;
  final IconData outline;
  final IconData filled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = label.tr;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.fast;

    return Semantics(
      label: text,
      selected: selected,
      button: true,
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 650),
        child: Pressable(
          haptic: false,
          pressedScale: 0.985,
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.emphasized,
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 10 : 6),
            decoration: BoxDecoration(
              color: selected
                  ? _staffNavigationAccent.withValues(alpha: 0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? _staffNavigationAccent.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                if (expanded)
                  AnimatedContainer(
                    duration: duration,
                    curve: AppMotion.emphasized,
                    width: 3,
                    height: selected ? 22 : 0,
                    decoration: BoxDecoration(
                      color: _staffNavigationAccent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                if (expanded) const SizedBox(width: 7),
                AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.emphasized,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? _staffNavigationAccent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selected ? filled : outline,
                    size: 21,
                    color: selected
                        ? _staffNavigationAccent
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                if (expanded) const SizedBox(width: 10),
                if (expanded)
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.bodyMd(
                            color: selected
                                ? _staffNavigationAccent
                                : AppColors.onSurfaceVariant,
                          ).copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
