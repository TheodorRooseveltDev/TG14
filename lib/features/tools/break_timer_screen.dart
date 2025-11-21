import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Break Timer utility screen
class BreakTimerScreen extends StatefulWidget {
  const BreakTimerScreen({super.key});

  @override
  State<BreakTimerScreen> createState() => _BreakTimerScreenState();
}

class _BreakTimerScreenState extends State<BreakTimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;

  final List<int> _presetMinutes = [15, 20, 30, 45, 60];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      _isRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _remainingSeconds = 0;
      _totalSeconds = 0;
      _isRunning = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Break Complete!',
              style: AppTypography.cardTitle.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.gold,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Your break time is over.\nTime to get back to the tables!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slateGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.cardBackground,
            ),
            child: Text(
              'Got It',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  String get _timeDisplay {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg.png',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_totalSeconds == 0) ...[
                        _buildPresetButtons(),
                      ] else ...[
                        _buildTimerDisplay(),
                        const SizedBox(height: 24),
                        _buildControlButtons(),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.gold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Break Timer',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your break times',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
          if (_totalSeconds > 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.gold),
              onPressed: _resetTimer,
              tooltip: 'Reset',
            ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: AppColors.gold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Break Duration',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Preset buttons
            ..._presetMinutes.map((minutes) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startTimer(minutes),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold.withOpacity(0.2),
                      foregroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Text(
                          '$minutes Minutes',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 16),
            Text(
              'Tap a duration to start your break timer',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slateGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Progress circle
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: AppColors.feltGreen,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.gold.withOpacity(0.2),
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                    ),
                  ),
                  // Time display
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeDisplay,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRunning ? 'Break Time' : 'Paused',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.slateGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isRunning
                    ? AppColors.gold.withOpacity(0.2)
                    : AppColors.feltGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isRunning ? AppColors.gold : AppColors.gold.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRunning ? Icons.play_circle_filled : Icons.pause_circle_filled,
                    color: AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRunning ? 'Timer Running' : 'Timer Paused',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        if (_isRunning) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: _pauseTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.gold),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pause),
                  const SizedBox(width: 8),
                  Text(
                    'Pause',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (_remainingSeconds > 0) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: _resumeTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.feltGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(
                    'Resume',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_remainingSeconds > 0) ...[
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _resetTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardBackground,
              foregroundColor: AppColors.slateGray,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
              ),
            ),
            child: const Icon(Icons.stop),
          ),
        ],
      ],
    );
  }
}
