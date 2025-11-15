import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leader_board/src/common_widgets/pinball_card.dart';
import 'package:leader_board/src/features/settings/application/settings_service.dart';

/// Reusable pinball carousel that can be used across different screens
///
/// Takes a callback to handle pinball selection, allowing different screens
/// to handle the selection differently (player state, leaderboard state, etc.)
class ReusablePinballCarousel extends ConsumerStatefulWidget {
  final void Function(String pinballId) onPinballSelected;
  final int? initialSelectedIndex;
  final bool autoRotate; // <-- Add this

  const ReusablePinballCarousel({
    super.key,
    required this.onPinballSelected,
    this.initialSelectedIndex,
    this.autoRotate = false, // <-- Default to false
  });

  @override
  ConsumerState<ReusablePinballCarousel> createState() =>
      _ReusablePinballCarouselState();
}

class _ReusablePinballCarouselState
    extends ConsumerState<ReusablePinballCarousel> {
  int selectedIndex = 0;
  late PageController _pageController;
  Timer? _autoRotateTimer;
  static const Duration autoRotateDuration = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex ?? 0;
    _pageController = PageController(
      viewportFraction: 0.4,
      initialPage: selectedIndex,
    );

    if (widget.autoRotate) {
      _autoRotateTimer = Timer.periodic(autoRotateDuration, (_) {
        final asyncPinballs = ref.read(pinballCollectionProvider);
        asyncPinballs.when(
          data: (pinballs) {
            if (pinballs.isEmpty) return;
            final nextIndex = (selectedIndex + 1) % pinballs.length;
            _pageController.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          loading: () {},
          error: (error, stack) {},
        );
      });
    }
  }

  @override
  void dispose() {
    _autoRotateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncPinballs = ref.watch(pinballCollectionProvider);

    return asyncPinballs.when(
      data: (pinballs) {
        if (pinballs.isEmpty) {
          return const Center(child: Text('No pinballs found.'));
        }

        // Set initial pinball selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pinballs.isNotEmpty && selectedIndex < pinballs.length) {
            widget.onPinballSelected(pinballs[selectedIndex].id);
          }
        });

        return SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
              if (pinballs.isNotEmpty && index < pinballs.length) {
                widget.onPinballSelected(pinballs[index].id);
              }
            },
            itemCount: pinballs.length,
            itemBuilder: (context, index) {
              final pinball = pinballs[index];
              final isSelected = selectedIndex == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: isSelected ? 0 : 20,
                ),
                child: PinballCard(
                  pinball: pinball,
                  selected: isSelected,
                  isLarge: isSelected,
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        return Center(child: Text('Error: $error'));
      },
    );
  }
}
