import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../providers/games_provider.dart';
import '../../../data/models/game_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../widgets/backgrounds/animated_casino_background.dart';
import '../game_detail/game_detail_screen.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  GameModel? _selectedGame;
  int _selectedIndex = 0;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showResultSheet();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    
    final gamesProvider = context.read<GamesProvider>();
    final games = gamesProvider.allGames.take(8).toList();
    if (games.isEmpty) return;

    // Pick a random game
    final random = math.Random();
    _selectedIndex = random.nextInt(games.length);
    _selectedGame = games[_selectedIndex];
    
    // Calculate the rotation needed to land on this segment
    final segmentAngle = 2 * math.pi / games.length;
    // Target angle: we want the selected segment to be at the top (pointer position)
    final targetAngle = -(_selectedIndex * segmentAngle) - (segmentAngle / 2);
    // Add extra rotations for drama (5-8 full rotations)
    final extraRotations = (5 + random.nextInt(4)) * 2 * math.pi;
    final totalRotation = extraRotations + targetAngle - _currentRotation;
    
    setState(() {
      _isSpinning = true;
      _currentRotation += totalRotation;
    });
    
    _controller.reset();
    _controller.forward();
  }

  void _showResultSheet() {
    if (_selectedGame == null) return;
    
    // Show confetti overlay first
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => _ConfettiOverlay(
        onComplete: () {
          Navigator.of(context).pop();
          _showGameSheet();
        },
      ),
    );
  }

  void _showGameSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.gold.withOpacity(0.4), width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slateGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Game info row: Icon + Title & Tagline
            Row(
              children: [
                // Game icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.25),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _selectedGame!.imageUrl != null
                        ? Image.network(
                            SupabaseService.getImageUrl(_selectedGame!.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                          )
                        : _buildPlaceholderIcon(),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Title and tagline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.premiumGoldGradient.createShader(bounds),
                        child: Text(
                          _selectedGame!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedGame!.tagline != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _selectedGame!.tagline!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.slateGray,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                // Spin again button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 200), _spin);
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: AppColors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Spin again',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Play now button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              GameDetailScreen(game: _selectedGame!),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.deepBlack,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Play Now',
                            style: TextStyle(
                              color: AppColors.deepBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: AppColors.feltGreen,
      child: Center(
        child: Icon(
          Icons.casino_rounded,
          color: AppColors.gold,
          size: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedCasinoBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spin the wheel to find your next game',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.slateGray,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
            
            const Spacer(),
            
            // Wheel - centered
            Center(
              child: Consumer<GamesProvider>(
                builder: (context, gamesProvider, child) {
                  final games = gamesProvider.allGames.take(8).toList();
                  return _buildPremiumWheel(games);
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Spin button - centered
            Center(
              child: GestureDetector(
              onTap: _isSpinning ? null : _spin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  gradient: _isSpinning ? null : AppColors.premiumGoldGradient,
                  color: _isSpinning ? AppColors.cardBackground : null,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _isSpinning 
                        ? AppColors.gold.withOpacity(0.3) 
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: _isSpinning ? null : [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isSpinning)
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.deepBlack,
                        size: 28,
                      ),
                    if (_isSpinning)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isSpinning ? 'Spinning...' : 'SPIN',
                      style: TextStyle(
                        color: _isSpinning ? AppColors.gold : AppColors.deepBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ),
            
            const Spacer(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumWheel(List<GameModel> games) {
    if (games.isEmpty) {
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 4),
        ),
        child: Center(
          child: Text(
            'Loading games...',
            style: TextStyle(color: AppColors.slateGray),
          ),
        ),
      );
    }

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.2),
            blurRadius: 50,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColors.deepBlack.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.premiumGoldGradient,
            ),
          ),
          
          // Inner border
          Container(
            width: 308,
            height: 308,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepBlack,
            ),
          ),
          
          // Wheel with game icons
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final startRotation = _currentRotation - 8 * math.pi;
              final currentAngle = startRotation + (_animation.value * 8 * math.pi);
              return Transform.rotate(
                angle: _isSpinning ? currentAngle : _currentRotation,
                child: Container(
                  width: 296,
                  height: 296,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        // Wheel segments
                        CustomPaint(
                          size: const Size(296, 296),
                          painter: _WheelSegmentPainter(segmentCount: games.length),
                        ),
                        // Game icons
                        ...List.generate(games.length, (index) {
                          final segmentAngle = 2 * math.pi / games.length;
                          final angle = index * segmentAngle + segmentAngle / 2 - math.pi / 2;
                          final radius = 105.0;
                          final x = 148 + radius * math.cos(angle);
                          final y = 148 + radius * math.sin(angle);
                          
                          return Positioned(
                            left: x - 28,
                            top: y - 28,
                            child: Transform.rotate(
                              angle: angle + math.pi / 2,
                              child: _WheelGameIcon(game: games[index]),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Center dot like real roulette
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.premiumGoldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: AppColors.deepBlack,
                width: 3,
              ),
            ),
          ),
          
          // Pointer at top
          Positioned(
            top: 0,
            child: _buildPointer(),
          ),
          
          // Light indicators around the rim
          ...List.generate(16, (index) {
            final angle = index * (2 * math.pi / 16) - math.pi / 2;
            final radius = 152.0;
            final x = 160 + radius * math.cos(angle);
            final y = 160 + radius * math.sin(angle);
            return Positioned(
              left: x - 4,
              top: y - 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSpinning && (index % 2 == (_animation.value * 16).floor() % 2)
                      ? AppColors.gold
                      : AppColors.goldDark.withOpacity(0.5),
                  boxShadow: [
                    if (_isSpinning && (index % 2 == (_animation.value * 16).floor() % 2))
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.8),
                        blurRadius: 8,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildPointer() {
    return Container(
      width: 30,
      height: 40,
      child: CustomPaint(
        painter: _PointerPainter(),
      ),
    );
  }
}

class _WheelGameIcon extends StatelessWidget {
  final GameModel game;

  const _WheelGameIcon({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlack.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: game.imageUrl != null
            ? Image.network(
                SupabaseService.getImageUrl(game.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.feltGreen,
      child: Center(
        child: Icon(
          Icons.casino_rounded,
          color: AppColors.gold.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }
}

class _WheelSegmentPainter extends CustomPainter {
  final int segmentCount;

  _WheelSegmentPainter({required this.segmentCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / segmentCount;

    final colors = [
      const Color(0xFF0F4422), // Slightly brighter felt green
      const Color(0xFF0A2E16), // Dark felt
    ];

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      final paint = Paint()
        ..color = colors[i % 2]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Segment divider lines - like real roulette spokes
      final borderPaint = Paint()
        ..color = AppColors.gold.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final endX = center.dx + radius * math.cos(startAngle);
      final endY = center.dy + radius * math.sin(startAngle);
      canvas.drawLine(center, Offset(endX, endY), borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.premiumGoldGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final shadowPaint = Paint()
      ..color = AppColors.deepBlack.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 4)
      ..quadraticBezierTo(size.width / 2, 0, size.width, 4)
      ..close();

    // Shadow
    canvas.drawPath(path.shift(const Offset(1, 2)), shadowPaint);
    // Main pointer
    canvas.drawPath(path, paint);
    
    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Confetti overlay widget
class _ConfettiOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _ConfettiOverlay({required this.onComplete});

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final int _particleCount = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    final random = math.Random();
    _particles = List.generate(_particleCount, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        y: -random.nextDouble() * 0.3,
        speed: 0.3 + random.nextDouble() * 0.5,
        size: 6 + random.nextDouble() * 10,
        color: [
          AppColors.gold,
          AppColors.goldLight,
          AppColors.goldDark,
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          Colors.white,
        ][random.nextInt(6)],
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.3,
        wobble: random.nextDouble() * 2 * math.pi,
        wobbleSpeed: 2 + random.nextDouble() * 4,
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
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
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double wobble;
  final double wobbleSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobble,
    required this.wobbleSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = particle.y + progress * particle.speed * 1.5;
      if (currentY > 1.2) continue;

      final wobbleOffset = math.sin(particle.wobble + progress * particle.wobbleSpeed * math.pi * 2) * 0.05;
      final currentX = particle.x + wobbleOffset;
      final currentRotation = particle.rotation + progress * particle.rotationSpeed * math.pi * 4;

      final opacity = currentY > 0.8 ? (1.2 - currentY) / 0.4 : 1.0;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX * size.width, currentY * size.height);
      canvas.rotate(currentRotation);

      // Draw confetti shape (rectangle or circle)
      if (particles.indexOf(particle) % 3 == 0) {
        // Circle
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      } else if (particles.indexOf(particle) % 3 == 1) {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
          paint,
        );
      } else {
        // Star/diamond shape
        final path = Path();
        final s = particle.size / 2;
        path.moveTo(0, -s);
        path.lineTo(s * 0.4, 0);
        path.lineTo(0, s);
        path.lineTo(-s * 0.4, 0);
        path.close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
