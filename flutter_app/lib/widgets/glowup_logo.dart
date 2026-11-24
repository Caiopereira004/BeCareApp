import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlowUpLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final bool darkMode;

  const GlowUpLogo({
    super.key,
    this.size = 64,
    this.showWordmark = false,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7A3248),
            Color(0xFF9E4761),
            Color(0xFFC8748C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E4761).withOpacity(0.24),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: CustomPaint(painter: _DropletArchPainter()),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.28),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: size * 0.56,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: darkMode ? const Color(0xFFF5F3F5) : const Color(0xFF1E1B1E),
            ),
            children: [
              const TextSpan(text: 'Glow'),
              TextSpan(
                text: 'Up',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: size * 0.68,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9E4761),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropletArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final archPaint = Paint()
      ..color = const Color(0xFFFDE8D7).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.055;

    final archRect = Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.60, h * 0.60);
    canvas.drawArc(archRect, 0.35, 4.4, false, archPaint);

    final dropPath = Path()
      ..moveTo(w * 0.50, h * 0.26)
      ..cubicTo(w * 0.64, h * 0.43, w * 0.67, h * 0.54, w * 0.67, h * 0.60)
      ..arcToPoint(Offset(w * 0.33, h * 0.60), radius: Radius.circular(w * 0.17), clockwise: true)
      ..cubicTo(w * 0.33, h * 0.54, w * 0.36, h * 0.43, w * 0.50, h * 0.26)
      ..close();

    final dropPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropPath, dropPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
