import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/theme.dart';
import '../../../data/models/game.dart';
import '../../widgets/common/common.dart';
import '../../widgets/buttons/buttons.dart';

/// State for mystery picker animation
enum MysteryState { idle, shaking, revealing, revealed }

/// Mystery game picker - unique feature to reveal random games
class MysteryGamePicker extends StatefulWidget {
  final List<Game> games;
  final Function(Game) onGameSelected;

  const MysteryGamePicker({
    super.key,
    required this.games,
    required this.onGameSelected,
  });

  @override
  State<MysteryGamePicker> createState() => _MysteryGamePickerState();
}

class _MysteryGamePickerState extends State<MysteryGamePicker>
    with TickerProviderStateMixin {
  late AnimationController _wobbleController;
  late AnimationController _shakeController;
  late AnimationController _revealController;
  late AnimationController _sparkleController;

  Game? _selectedGame;
  MysteryState _state = MysteryState.idle;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();

    // Gentle wobble animation
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Intense shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Reveal animation
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _shakeController.dispose();
    _revealController.dispose();
    _sparkleController.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _reveal() async {
    if (_state != MysteryState.idle || widget.games.isEmpty) return;

    HapticFeedback.mediumImpact();

    // Select random game
    final random = Random();
    _selectedGame = widget.games[random.nextInt(widget.games.length)];

    // State: Shaking
    setState(() => _state = MysteryState.shaking);
    _shakeController.forward();

    // Wait for shake animation
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // State: Revealing
    setState(() => _state = MysteryState.revealing);
    HapticFeedback.heavyImpact();
    _revealController.forward();

    // Wait for reveal animation
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // State: Revealed
    setState(() => _state = MysteryState.revealed);

    // Auto-reset after 5 seconds if no action
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 5), () {
      if (_state == MysteryState.revealed && mounted) {
        _reset();
      }
    });
  }

  void _reset() {
    _resetTimer?.cancel();
    _shakeController.reset();
    _revealController.reset();
    setState(() {
      _state = MysteryState.idle;
      _selectedGame = null;
    });
  }

  void _playGame() {
    if (_selectedGame != null) {
      HapticFeedback.mediumImpact();
      widget.onGameSelected(_selectedGame!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: AppSpacing.mysteryPickerHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Stack(
        children: [
          // Sparkle layer
          SparkleLayer(controller: _sparkleController),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _state == MysteryState.revealed
                  ? _buildRevealedContent()
                  : _buildIdleContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleContent() {
    return Row(
      key: const ValueKey('idle'),
      children: [
        // Mystery box
        AnimatedBuilder(
          animation: _state == MysteryState.shaking
              ? _shakeController
              : _wobbleController,
          builder: (context, child) {
            double rotation = 0;
            if (_state == MysteryState.shaking) {
              rotation = sin(_shakeController.value * 20 * pi) * 0.15;
            } else {
              rotation = sin(_wobbleController.value * pi) * 0.03;
            }
            return Transform.rotate(
              angle: rotation,
              child: child,
            );
          },
          child: _MysteryBox(
            size: 80,
            isShaking: _state == MysteryState.shaking,
          ),
        ),

        const SizedBox(width: 20),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mystery Game',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to reveal your lucky game!',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textLight.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Reveal button
        _PulsingRevealButton(
          onTap: _reveal,
          isEnabled: _state == MysteryState.idle,
        ),
      ],
    );
  }

  Widget _buildRevealedContent() {
    return Row(
      key: const ValueKey('revealed'),
      children: [
        // Game thumbnail
        AnimatedBuilder(
          animation: _revealController,
          builder: (context, child) {
            return Transform.scale(
              scale: _revealController.value,
              child: child,
            );
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.feltGreen,
              border: Border.all(
                color: AppColors.gold.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: AppShadows.goldGlow,
            ),
            child: const Center(
              child: Icon(
                Icons.casino,
                color: AppColors.gold,
                size: 40,
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Game info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _selectedGame?.name ?? 'Lucky Game',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _reset,
                child: Text(
                  'Try Again',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.slateGray,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Play button
        GoldButton(
          text: 'PLAY',
          onPressed: _playGame,
          small: true,
        ),
      ],
    );
  }
}

/// Mystery box widget with gift box design
class _MysteryBox extends StatelessWidget {
  final double size;
  final bool isShaking;

  const _MysteryBox({
    required this.size,
    this.isShaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gold, AppColors.goldDark],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isShaking ? AppShadows.goldGlowIntense : AppShadows.goldGlow,
      ),
      child: Stack(
        children: [
          // Vertical ribbon
          Positioned(
            top: 0,
            left: size * 0.4,
            child: Container(
              width: size * 0.2,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.redVelvet,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Horizontal ribbon
          Positioned(
            left: 0,
            top: size * 0.4,
            child: Container(
              width: size,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: AppColors.redVelvet,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Question mark
          Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing reveal button
class _PulsingRevealButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isEnabled;

  const _PulsingRevealButton({
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<_PulsingRevealButton> createState() => _PulsingRevealButtonState();
}

class _PulsingRevealButtonState extends State<_PulsingRevealButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = widget.isEnabled ? 1.0 + (_pulseController.value * 0.05) : 1.0;
        return Transform.scale(
          scale: scale,
          child: GoldButton(
            text: 'REVEAL',
            onPressed: widget.onTap,
            small: true,
            disabled: !widget.isEnabled,
          ),
        );
      },
    );
  }
}
