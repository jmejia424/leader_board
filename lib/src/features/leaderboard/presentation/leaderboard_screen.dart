import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leader_board/src/common_widgets/reusable_pinball_carousel.dart';
import 'package:leader_board/src/features/authentication/presentation/components/profile_icon.dart';
import 'package:leader_board/src/features/leaderboard/application/leaderboard_service.dart';
import 'package:leader_board/src/features/leaderboard/application/leaderboard_state_controller.dart';
import 'package:leader_board/src/features/leaderboard/presentation/components/leaderboard_header.dart';
import 'package:leader_board/src/features/leaderboard/presentation/components/leaderboard_list.dart';
import 'package:leader_board/src/features/leaderboard/presentation/components/period_selector.dart';
import 'package:leader_board/src/features/leaderboard/presentation/components/qr_code.dart';
import 'package:leader_board/src/routing/app_routes.dart';

class LeaderBoardScreen extends ConsumerStatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  ConsumerState<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends ConsumerState<LeaderBoardScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(currentLeaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                ],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: const Icon(Icons.camera, color: Colors.white),
          ),
          onPressed: () {
            context.goNamed(AppRoute.player.name);
          },
        ),
        title: PeriodSelector(),
        actions: const [ProfileIcon()],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey.shade900,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Stack(
                  children: [
                    // Carousel fills the width
                    ReusablePinballCarousel(
                      onPinballSelected: (pinballId) {
                        ref
                            .read(leaderboardStateControllerProvider.notifier)
                            .setSelectedPinball(pinballId);
                      },
                      autoRotate: true,
                    ),
                    // QR image overlay, aligned left
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: const QrCode(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: leaderboardAsync.when(
                data: (leaderboard) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        LeaderboardHeader(leaderboard: leaderboard),
                        LeaderboardList(leaderboard: leaderboard),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading leaderboard',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
