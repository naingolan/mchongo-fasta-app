import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

/// SVG Path Parser to render any SVG string directly to Canvas
class SvgPathParser {
  static Path parse(String d) {
    final path = Path();
    final tokens = _tokenize(d);
    int i = 0;
    String cmd = '';
    double curX = 0;
    double curY = 0;
    double startX = 0;
    double startY = 0;
    double lastCtrlX = 0;
    double lastCtrlY = 0;

    while (i < tokens.length) {
      final token = tokens[i];
      if (_isCommand(token)) {
        cmd = token;
        i++;
      }

      switch (cmd) {
        case 'M':
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          path.moveTo(x, y);
          curX = x;
          curY = y;
          startX = x;
          startY = y;
          cmd = 'L';
          break;
        case 'm':
          final x = curX + double.parse(tokens[i++]);
          final y = curY + double.parse(tokens[i++]);
          path.moveTo(x, y);
          curX = x;
          curY = y;
          startX = x;
          startY = y;
          cmd = 'l';
          break;
        case 'L':
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          path.lineTo(x, y);
          curX = x;
          curY = y;
          break;
        case 'l':
          final x = curX + double.parse(tokens[i++]);
          final y = curY + double.parse(tokens[i++]);
          path.lineTo(x, y);
          curX = x;
          curY = y;
          break;
        case 'H':
          final x = double.parse(tokens[i++]);
          path.lineTo(x, curY);
          curX = x;
          break;
        case 'h':
          final x = curX + double.parse(tokens[i++]);
          path.lineTo(x, curY);
          curX = x;
          break;
        case 'V':
          final y = double.parse(tokens[i++]);
          path.lineTo(curX, y);
          curY = y;
          break;
        case 'v':
          final y = curY + double.parse(tokens[i++]);
          path.lineTo(curX, y);
          curY = y;
          break;
        case 'C':
          final x1 = double.parse(tokens[i++]);
          final y1 = double.parse(tokens[i++]);
          final x2 = double.parse(tokens[i++]);
          final y2 = double.parse(tokens[i++]);
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCtrlX = x2;
          lastCtrlY = y2;
          curX = x;
          curY = y;
          break;
        case 'c':
          final x1 = curX + double.parse(tokens[i++]);
          final y1 = curY + double.parse(tokens[i++]);
          final x2 = curX + double.parse(tokens[i++]);
          final y2 = curY + double.parse(tokens[i++]);
          final x = curX + double.parse(tokens[i++]);
          final y = curY + double.parse(tokens[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCtrlX = x2;
          lastCtrlY = y2;
          curX = x;
          curY = y;
          break;
        case 'S':
          final x2 = double.parse(tokens[i++]);
          final y2 = double.parse(tokens[i++]);
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          final x1 = 2 * curX - lastCtrlX;
          final y1 = 2 * curY - lastCtrlY;
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCtrlX = x2;
          lastCtrlY = y2;
          curX = x;
          curY = y;
          break;
        case 's':
          final x2 = curX + double.parse(tokens[i++]);
          final y2 = curY + double.parse(tokens[i++]);
          final x = curX + double.parse(tokens[i++]);
          final y = curY + double.parse(tokens[i++]);
          final x1 = 2 * curX - lastCtrlX;
          final y1 = 2 * curY - lastCtrlY;
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCtrlX = x2;
          lastCtrlY = y2;
          curX = x;
          curY = y;
          break;
        case 'A':
        case 'a':
          final rx = double.parse(tokens[i++]).abs();
          final ry = double.parse(tokens[i++]).abs();
          final rot = double.parse(tokens[i++]) * math.pi / 180.0;
          final largeArc = int.parse(tokens[i++]) != 0;
          final sweep = int.parse(tokens[i++]) != 0;
          double x = double.parse(tokens[i++]);
          double y = double.parse(tokens[i++]);
          if (cmd == 'a') {
            x += curX;
            y += curY;
          }
          _arcTo(path, curX, curY, rx, ry, rot, largeArc, sweep, x, y);
          curX = x;
          curY = y;
          break;
        case 'Z':
        case 'z':
          path.close();
          curX = startX;
          curY = startY;
          break;
        default:
          i++;
      }
    }

    return path;
  }

  static bool _isCommand(String token) {
    return token.length == 1 &&
        'MmLlHhVvCcSsQqTtAaZz'.contains(token);
  }

  static List<String> _tokenize(String d) {
    final regExp = RegExp(r'([MmLlHhVvCcSsQqTtAaZz])|([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)');
    final matches = regExp.allMatches(d);
    final list = <String>[];
    for (final m in matches) {
      if (m.group(1) != null) {
        list.add(m.group(1)!);
      } else if (m.group(2) != null) {
        list.add(m.group(2)!);
      }
    }
    return list;
  }

  static void _arcTo(
    Path path,
    double x0,
    double y0,
    double rx,
    double ry,
    double phi,
    bool largeArc,
    bool sweep,
    double x1,
    double y1,
  ) {
    if (x0 == x1 && y0 == y1) return;
    if (rx == 0 || ry == 0) {
      path.lineTo(x1, y1);
      return;
    }

    final cosPhi = math.cos(phi);
    final sinPhi = math.sin(phi);

    final dx = (x0 - x1) / 2.0;
    final dy = (y0 - y1) / 2.0;
    final x1p = cosPhi * dx + sinPhi * dy;
    final y1p = -sinPhi * dx + cosPhi * dy;

    var rxSq = rx * rx;
    var rySq = ry * ry;
    final x1pSq = x1p * x1p;
    final y1pSq = y1p * y1p;

    final radiiCheck = x1pSq / rxSq + y1pSq / rySq;
    if (radiiCheck > 1.0) {
      final s = math.sqrt(radiiCheck);
      rx *= s;
      ry *= s;
      rxSq = rx * rx;
      rySq = ry * ry;
    }

    final sign = (largeArc == sweep) ? -1.0 : 1.0;
    final num = rxSq * rySq - rxSq * y1pSq - rySq * x1pSq;
    final den = rxSq * y1pSq + rySq * x1pSq;
    final sq = math.max(0.0, num / den);
    final coef = sign * math.sqrt(sq);
    final cxp = coef * ((rx * y1p) / ry);
    final cyp = coef * (-(ry * x1p) / rx);

    final cx = cosPhi * cxp - sinPhi * cyp + (x0 + x1) / 2.0;
    final cy = sinPhi * cxp + cosPhi * cyp + (y0 + y1) / 2.0;

    final theta1 = _angle(1.0, 0.0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    var dTheta = _angle(
      (x1p - cxp) / rx,
      (y1p - cyp) / ry,
      (-x1p - cxp) / rx,
      (-y1p - cyp) / ry,
    );

    if (!sweep && dTheta > 0) {
      dTheta -= 2 * math.pi;
    } else if (sweep && dTheta < 0) {
      dTheta += 2 * math.pi;
    }

    final segments = (dTheta.abs() / (math.pi / 2.0)).ceil();
    final dt = dTheta / segments;
    final alpha = (8.0 / 3.0) * math.sin(dt / 4.0) * math.sin(dt / 4.0) / math.sin(dt / 2.0);

    var currentTheta = theta1;
    var currentX = x0;
    var currentY = y0;

    for (int i = 0; i < segments; i++) {
      final nextTheta = currentTheta + dt;
      final cosTheta = math.cos(currentTheta);
      final sinTheta = math.sin(currentTheta);
      final cosNextTheta = math.cos(nextTheta);
      final sinNextTheta = math.sin(nextTheta);

      final p1x = currentX - alpha * (-rx * sinTheta * cosPhi - ry * cosTheta * sinPhi);
      final p1y = currentY - alpha * (-rx * sinTheta * sinPhi + ry * cosTheta * cosPhi);

      final nextX = cx + rx * cosNextTheta * cosPhi - ry * sinNextTheta * sinPhi;
      final nextY = cy + rx * cosNextTheta * sinPhi + ry * sinNextTheta * cosPhi;

      final p2x = nextX + alpha * (-rx * sinNextTheta * cosPhi - ry * cosNextTheta * sinPhi);
      final p2y = nextY + alpha * (-rx * sinNextTheta * sinPhi + ry * cosNextTheta * cosPhi);

      path.cubicTo(p1x, p1y, p2x, p2y, nextX, nextY);
      currentTheta = nextTheta;
      currentX = nextX;
      currentY = nextY;
    }
  }

  static double _angle(double ux, double uy, double vx, double vy) {
    final dot = ux * vx + uy * vy;
    final len = math.sqrt(ux * ux + uy * uy) * math.sqrt(vx * vx + vy * vy);
    var val = (dot / len).clamp(-1.0, 1.0);
    var ang = math.acos(val);
    if (ux * vy - uy * vx < 0) ang = -ang;
    return ang;
  }
}

/// Map Tab Icon (Crime-Target-Location)
/// When active: fully white
/// When inactive: dual-tone (blue + black/ink)
class MfMapTabIcon extends StatelessWidget {
  const MfMapTabIcon({
    super.key,
    required this.selected,
    this.size = 20,
  });

  final bool selected;
  final double size;

  static const _bluePath1 =
      'M8.84 7.48A3.4 3.4 0 0 1 11 4.82l0.37 -0.1c0.19 1.32 0.38 1.3 0.52 1.3s0.34 0 0.53 -1.37a3.42 3.42 0 0 1 0.44 0 3.18 3.18 0 0 1 1.88 1 0.29 0.29 0 0 0 0.46 -0.36A3.89 3.89 0 0 0 13 4a5.86 5.86 0 0 0 -0.58 -0.1 0.61 0.61 0 0 1 0 -0.14c-0.17 -1.26 -0.26 -1.41 -0.53 -1.41s-0.36 0.14 -0.53 1.41a0.81 0.81 0 0 1 0 0.16 4.27 4.27 0 0 0 -2.57 1.32 4.49 4.49 0 0 0 -1 2.21C6 7.59 6 7.73 6 7.92s0 0.37 1.72 0.6a3.83 3.83 0 0 0 1.73 3 4.51 4.51 0 0 0 2.29 0.66c0.17 1.23 0.28 1.42 0.56 1.41s0.35 -0.17 0.47 -1.52a4.18 4.18 0 0 0 0.92 -0.32 4.32 4.32 0 0 0 2.46 -3.25h0.17c1.42 -0.14 1.6 -0.21 1.61 -0.5s-0.15 -0.38 -1.59 -0.56h-0.16a0.76 0.76 0 0 1 0 -0.15 2.76 2.76 0 0 0 -0.4 -1.1 0.32 0.32 0 0 0 -0.45 -0.11 0.33 0.33 0 0 0 -0.12 0.45 2.11 2.11 0 0 1 0.26 0.85h-0.21c-1.57 0.17 -1.56 0.34 -1.57 0.51s0 0.35 1.56 0.56h0.12a3.48 3.48 0 0 1 -2.06 2.38 3.09 3.09 0 0 1 -0.54 0.17c-0.21 -1.48 -0.4 -1.45 -0.55 -1.45s-0.34 0 -0.51 1.48l0 0.07a3.34 3.34 0 0 1 -1.71 -0.51 2.74 2.74 0 0 1 -1.2 -2h0.12c1.64 -0.12 1.78 -0.17 1.79 -0.47s0 -0.37 -1.77 -0.58Z';

  static const _bluePath2 =
      'M4.79 10.39A16.64 16.64 0 0 0 6 13.18c0.7 1.32 1.54 2.58 2.35 3.81a8.17 8.17 0 0 0 1.42 1.78 3.1 3.1 0 0 0 1.53 0.74 3.3 3.3 0 0 0 2.34 -0.51 4.58 4.58 0 0 0 1.56 -1.69c1 -1.77 1.9 -3.11 2.64 -4.52a14.58 14.58 0 0 0 1.28 -3.35 7.47 7.47 0 0 0 0.2 -2.24 10.41 10.41 0 0 0 -0.48 -2.16 0.33 0.33 0 0 0 -0.41 -0.24 0.33 0.33 0 0 0 -0.23 0.41 10.49 10.49 0 0 1 0.41 2 6.47 6.47 0 0 1 -0.23 2 13 13 0 0 1 -1.28 3.13c-0.77 1.39 -1.72 2.71 -2.73 4.45a3.73 3.73 0 0 1 -1.26 1.3 2.29 2.29 0 0 1 -1.64 0.31 2.09 2.09 0 0 1 -1 -0.52 7.81 7.81 0 0 1 -1.21 -1.58c-0.78 -1.2 -1.6 -2.44 -2.28 -3.72a15.72 15.72 0 0 1 -1.13 -2.61 7.36 7.36 0 0 1 -0.19 -3.82A5.53 5.53 0 0 1 7.56 3a7.22 7.22 0 0 1 5.62 -1.69 7 7 0 0 1 4.91 3.26 0.29 0.29 0 1 0 0.51 -0.29A7.66 7.66 0 0 0 13.3 0.57 8.07 8.07 0 0 0 7 2.26 6.53 6.53 0 0 0 4.62 6a8.51 8.51 0 0 0 0.17 4.39Z';

  static const _blackPath3 =
      'm24 22.52 -3.78 -6.67a0.33 0.33 0 0 0 -0.29 -0.18l-1.08 0a0.33 0.33 0 0 0 -0.33 0.33 0.33 0.33 0 0 0 0.32 0.34l0.87 0 3.14 5.93 -8.5 0c-2.83 0 -5.54 0.1 -8.31 0.16l-4.8 0.12 2.86 -5.67h1.69a0.29 0.29 0 0 0 0 -0.58l-1.89 -0.07a0.3 0.3 0 0 0 -0.29 0.19c-0.22 0.43 -0.45 0.86 -0.68 1.29C2 19.44 0.94 21.1 0.05 22.86a0.46 0.46 0 0 0 0 0.44 0.44 0.44 0 0 0 0.38 0.21l9.25 0c2.31 0 4.62 -0.09 6.93 -0.15s4.61 -0.13 6.92 -0.18a0.44 0.44 0 0 0 0.39 -0.22 0.46 0.46 0 0 0 0.08 -0.44Z';

  static Path? _p1;
  static Path? _p2;
  static Path? _p3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blueColor = selected
        ? Colors.white
        : (isDark ? MfColors.primarySoft : MfColors.primary);
    final blackColor = selected
        ? Colors.white
        : (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_bluePath1);
    _p2 ??= SvgPathParser.parse(_bluePath2);
    _p3 ??= SvgPathParser.parse(_blackPath3);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!],
          colors: [blueColor, blueColor, blackColor],
        ),
      ),
    );
  }
}

/// List Tab Icon (Task-List-Clipboard-Search)
/// When active: fully white
/// When inactive: dual-tone (blue + black/ink)
class MfListTabIcon extends StatelessWidget {
  const MfListTabIcon({
    super.key,
    required this.selected,
    this.size = 20,
  });

  final bool selected;
  final double size;

  static const _bluePath1 =
      'M21.91 20.16A4.18 4.18 0 0 0 24 17a6.19 6.19 0 0 0 -0.68 -3.68 5.71 5.71 0 0 0 -2.45 -2.42 5.07 5.07 0 0 0 -3.45 -0.38 9.45 9.45 0 0 0 -2.73 1.06A5.43 5.43 0 0 0 13.13 13a5.66 5.66 0 0 0 -0.87 4.3 5.08 5.08 0 0 0 2.39 3.6 5 5 0 0 0 2.29 0.58 11.19 11.19 0 0 0 3.34 -0.48c0.12 0 0.53 0.49 0.74 0.85a4 4 0 0 0 0.34 0.5 5.58 5.58 0 0 0 0.39 0.46c0.32 0.34 0.67 0.65 1 1a0.33 0.33 0 0 0 0.5 -0.42c-0.25 -0.4 -0.47 -0.8 -0.71 -1.19 -0.11 -0.17 -0.21 -0.33 -0.33 -0.49s-0.24 -0.31 -0.37 -0.46 -0.48 -0.48 -0.73 -0.72l0.14 0a3.37 3.37 0 0 0 0.66 -0.37Zm-4.94 0.6a4.25 4.25 0 0 1 -1.92 -0.57 4.22 4.22 0 0 1 -1.84 -3.08 4.64 4.64 0 0 1 0.79 -3.49 4.48 4.48 0 0 1 1.59 -1.28 8.8 8.8 0 0 1 2 -0.73 4.08 4.08 0 0 1 2.77 0.25 4.73 4.73 0 0 1 2.07 2 5.24 5.24 0 0 1 0.69 3.12 3.44 3.44 0 0 1 -1.59 2.64 2.63 2.63 0 0 1 -0.66 0.3c-1.13 0.34 -1.37 1.08 -3.87 0.84Z';

  static const _bluePath2 =
      'M4.76 1.61a0.86 0.86 0 0 0 -0.33 -0.2 1.65 1.65 0 0 0 -1.19 0.31c-0.23 0.23 -0.18 0.72 -1 5.52 -0.29 1.64 -0.66 3.14 -0.94 4.55 -0.21 1.06 -0.41 2.06 -0.62 3A24.43 24.43 0 0 0 0 17.47a0.84 0.84 0 0 0 0.29 0.81 18.82 18.82 0 0 0 3.46 0.84c3.1 0.57 7.28 1.17 7.84 1.27a0.32 0.32 0 1 0 0.13 -0.63c-0.56 -0.12 -4.72 -0.91 -7.72 -1.58a28.79 28.79 0 0 1 -2.85 -0.72c0.11 -0.75 0.58 -2.3 0.6 -2.41 0.18 -0.82 0.35 -1.67 0.5 -2.55C2.7 9.59 4 2.39 4 2.38a1.07 1.07 0 0 0 0.66 0c0.06 -0.06 0.34 -0.58 0.1 -0.77Z';

  static const _bluePath3 =
      'M16.94 4.5a1 1 0 0 0 0.49 0.2c0.17 0 0.21 0.07 0.37 0.06 -0.11 0.61 -0.24 1.17 -0.34 1.69 -0.05 0.26 -0.1 0.51 -0.13 0.74s-0.07 0.51 -0.09 0.74c-0.08 1.12 -0.1 1.76 -0.1 1.76a0.28 0.28 0 0 0 0.55 0.14 9.54 9.54 0 0 0 0.58 -1.73 6.92 6.92 0 0 0 0.14 -0.76c0 -0.24 0.05 -0.5 0.06 -0.77l0 -1.8 0 -0.14c0 -0.05 0.08 -0.07 0.09 -0.13a0.33 0.33 0 0 0 -0.24 -0.39 1.69 1.69 0 0 0 -0.93 -0.18c-0.45 0.07 -0.53 0.5 -0.45 0.57Z';

  static const _blackPath4 =
      'M20.69 3.84a2.46 2.46 0 0 0 -0.46 -1 2.24 2.24 0 0 0 -2.3 -0.9l-0.27 -0.06c-1.14 -0.23 -2 -0.49 -3.08 -0.74 -0.4 -0.09 -0.84 -0.17 -1.35 -0.26L11.42 0.61C7.14 0.15 7 -0.27 5.88 0.72a2 2 0 0 0 -0.35 0.41 3.21 3.21 0 0 0 -0.24 0.45L5 2.5l0 0.76c-0.28 2.29 -0.51 2.64 -1.8 9 -0.12 0.6 -0.49 1.55 -0.62 2.39a3.11 3.11 0 0 0 0 1.27 0.94 0.94 0 0 0 0.49 0.52 6.07 6.07 0 0 0 1.33 0.41c1.68 0.37 4.45 0.7 6.25 1.05a0.32 0.32 0 0 0 0.38 -0.24 0.32 0.32 0 0 0 -0.24 -0.39c-1.29 -0.33 -3.11 -0.67 -4.64 -1a18.38 18.38 0 0 1 -2.36 -0.64l-0.21 -0.07a3.06 3.06 0 0 1 0.09 -1c0.16 -0.72 0.43 -1.49 0.55 -2 0.19 -0.86 0.38 -1.71 0.54 -2.57 1.28 -7 0.57 -6.11 1.4 -7.7a4.28 4.28 0 0 1 0.48 -0.74 2.23 2.23 0 0 1 1 -0.69c0.89 0.26 1.75 0.47 2.63 0.65s1.83 0.33 2.79 0.51c1.41 0.18 2.33 0.37 3.35 0.52l0.36 0C15.48 3.57 15.6 4.28 14.82 7c-0.07 0.24 -0.12 0.46 -0.16 0.66s-0.07 0.47 -0.09 0.67c-0.12 1.06 -0.13 1.58 -0.13 1.58a0.34 0.34 0 0 0 0.26 0.39 0.33 0.33 0 0 0 0.38 -0.26 14.88 14.88 0 0 0 0.49 -1.51 5.32 5.32 0 0 0 0.16 -0.66 6.25 6.25 0 0 0 0.11 -0.67 6.32 6.32 0 0 1 1.5 -3.95 1.34 1.34 0 0 1 2 0.28 1.67 1.67 0 0 1 0.31 0.78 5 5 0 0 1 0.05 1c0 0.6 0 1.23 -0.11 1.86A18.1 18.1 0 0 1 19.31 9a0.34 0.34 0 0 0 0.23 0.4 0.33 0.33 0 0 0 0.4 -0.23 18.65 18.65 0 0 0 0.48 -1.89c0.13 -0.64 0.23 -1.29 0.3 -1.92a5.39 5.39 0 0 0 -0.03 -1.52Z';

  static const _blackPath5 =
      'M14.7 5.23a0.31 0.31 0 0 0 -0.22 -0.39A28.83 28.83 0 0 0 11.7 4c-0.4 -0.1 -0.81 -0.18 -1.22 -0.25s-0.82 -0.13 -1.24 -0.16c-1 -0.08 -1.93 -0.06 -2.9 -0.05a0.29 0.29 0 0 0 0 0.57c1.07 0.16 2.13 0.39 3.21 0.58 0.63 0.12 1.27 0.21 1.91 0.3 1 0.15 1.94 0.28 2.89 0.48a0.31 0.31 0 0 0 0.35 -0.24Z';

  static const _blackPath6 =
      'M10.92 7.52c-0.26 0 -0.51 -0.11 -0.78 -0.15A7.58 7.58 0 0 0 9 7.31a8.76 8.76 0 0 0 -2 0.34 0.27 0.27 0 0 0 -0.22 0.35 0.27 0.27 0 0 0 0.31 0.24l0.75 0c0.5 0 1 0.11 1.46 0.16s1 0 1.48 0.1l1 0a2.62 2.62 0 0 1 0.57 0.11 0.33 0.33 0 0 0 0.44 -0.16 0.34 0.34 0 0 0 -0.17 -0.43 3.71 3.71 0 0 0 -0.68 -0.27c-0.37 -0.08 -0.72 -0.15 -1.02 -0.23Z';

  static const _blackPath7 =
      'M12 11.65a16.5 16.5 0 0 0 -1.88 -0.65 6.44 6.44 0 0 0 -0.82 -0.19 6.15 6.15 0 0 0 -0.85 -0.1 13.14 13.14 0 0 0 -2 0.1 0.29 0.29 0 0 0 0 0.57c0.73 0.1 1.41 0.28 2.11 0.41 0.43 0.08 0.85 0.14 1.27 0.2 0.64 0.1 1.28 0.17 1.92 0.31a0.33 0.33 0 0 0 0.41 -0.21 0.33 0.33 0 0 0 -0.16 -0.44Z';

  static Path? _p1;
  static Path? _p2;
  static Path? _p3;
  static Path? _p4;
  static Path? _p5;
  static Path? _p6;
  static Path? _p7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blueColor = selected
        ? Colors.white
        : (isDark ? MfColors.primarySoft : MfColors.primary);
    final blackColor = selected
        ? Colors.white
        : (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_bluePath1);
    _p2 ??= SvgPathParser.parse(_bluePath2);
    _p3 ??= SvgPathParser.parse(_bluePath3);
    _p4 ??= SvgPathParser.parse(_blackPath4);
    _p5 ??= SvgPathParser.parse(_blackPath5);
    _p6 ??= SvgPathParser.parse(_blackPath6);
    _p7 ??= SvgPathParser.parse(_blackPath7);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!, _p6!, _p7!],
          colors: [
            blueColor,
            blueColor,
            blueColor,
            blackColor,
            blackColor,
            blackColor,
            blackColor,
          ],
        ),
      ),
    );
  }
}

class _MultiPathPainter extends CustomPainter {
  _MultiPathPainter({
    required this.paths,
    required this.colors,
  });

  final List<Path> paths;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    const origWidth = 24.0;
    const origHeight = 24.0;

    final scaleX = size.width / origWidth;
    final scaleY = size.height / origHeight;
    final scale = math.min(scaleX, scaleY);

    final dx = (size.width - origWidth * scale) / 2;
    final dy = (size.height - origHeight * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    for (int i = 0; i < paths.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(paths[i], paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MultiPathPainter oldDelegate) {
    if (oldDelegate.colors.length != colors.length) return true;
    for (int i = 0; i < colors.length; i++) {
      if (oldDelegate.colors[i] != colors[i]) return true;
    }
    return false;
  }
}

/// Guaranteed Safe Pay Icon (Cash-Payment-Coins)
class MfSafePayIcon extends StatelessWidget {
  const MfSafePayIcon({
    super.key,
    this.size = 24,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M20.57 10.92A3.81 3.81 0 0 0 19.84 9a0.94 0.94 0 0 0 -1 -0.23 5.42 5.42 0 0 0 0 -0.57 2.14 2.14 0 0 0 -1.75 -2 0.34 0.34 0 0 0 -0.42 0.21 0.32 0.32 0 0 0 0.21 0.41 1.3 1.3 0 0 1 0.7 1 2.75 2.75 0 0 1 0 0.5 7.68 7.68 0 0 1 0 0.82c-0.07 0.84 -0.22 1.7 -0.32 2.29a0.37 0.37 0 1 0 0.71 0.21c0.16 -0.39 0.39 -0.91 0.58 -1.46 0 -0.11 0.1 -0.23 0.16 -0.34a0.84 0.84 0 0 1 0.29 -0.28c0.21 -0.08 0.26 0.17 0.34 0.38a3.9 3.9 0 0 1 0.2 1.06 5.7 5.7 0 0 1 -0.4 2 10.9 10.9 0 0 1 -0.92 2 5 5 0 0 1 -1.38 1.58c-1.15 0.88 -2.38 1.31 -3 2a7 7 0 0 0 -0.71 1 12.09 12.09 0 0 0 -0.63 1.24 7.45 7.45 0 0 1 -0.79 -0.27c-1 -0.48 -1.88 -1.08 -2.86 -1.55a10.64 10.64 0 0 0 -1.36 -0.53c-0.21 -0.06 -0.44 -0.1 -0.66 -0.15a4.16 4.16 0 0 0 0.33 -1.46 5 5 0 0 0 -0.32 -1.74c-0.22 -0.55 -0.48 -1.11 -0.76 -1.67A10.87 10.87 0 0 1 5.42 12a2.35 2.35 0 0 1 0.12 -1.9 2.85 2.85 0 0 1 0.55 -0.71 4 4 0 0 1 0.77 -0.56 0.33 0.33 0 0 0 -0.29 -0.59 4.54 4.54 0 0 0 -1 0.54 3.72 3.72 0 0 0 -0.85 0.82 3.26 3.26 0 0 0 -0.52 2.7 7.14 7.14 0 0 0 0.72 1.79c0.28 0.52 0.61 1 0.85 1.53A3.7 3.7 0 0 1 6.21 17 3.29 3.29 0 0 1 6 18.27a2.16 2.16 0 0 0 -0.72 0 0.63 0.63 0 0 0 -0.33 0.19c-0.11 0.13 -0.25 0.36 -0.32 0.44l-1.14 1.41a0.33 0.33 0 0 0 0.46 0.47l1.35 -1.27s0.12 -0.2 0.2 -0.29c0 -0.06 0.09 -0.09 0.12 0s-0.08 0 -0.12 0a1.65 1.65 0 0 1 0.58 0.05 8.17 8.17 0 0 1 1 0.36l4.12 2c0.3 0.13 1.54 0.93 1.81 0.51a1.36 1.36 0 0 1 0.13 0.62 6.94 6.94 0 0 1 -0.26 1.24 0.37 0.37 0 1 0 0.7 0.23 5.78 5.78 0 0 0 0.4 -1.38 2.17 2.17 0 0 0 -0.12 -1.1 1.22 1.22 0 0 0 -0.57 -0.52l-0.1 0c0.15 -0.27 0.3 -0.55 0.48 -0.82a5.49 5.49 0 0 1 0.83 -1c0.66 -0.67 1.9 -0.95 3 -1.73a5.87 5.87 0 0 0 1.78 -1.93 11.18 11.18 0 0 0 1.11 -2.7 5.78 5.78 0 0 0 0.18 -2.13Z';

  static const _path2 =
      'M8 11.21a0.36 0.36 0 0 0 -0.45 0 0.39 0.39 0 0 0 0 0.53c0.61 0.71 1.17 1.39 1.7 2.08 0.2 0.27 0.4 0.54 0.58 0.82a6.37 6.37 0 0 1 0.35 0.55 4.77 4.77 0 0 1 0.58 1.68 0.34 0.34 0 0 0 0.34 0.33 0.32 0.32 0 0 0 0.32 -0.33 4.83 4.83 0 0 0 -0.48 -2.8 6.56 6.56 0 0 0 -1.22 -1.37c-0.93 -0.8 -1.06 -1.11 -1.72 -1.49Z';

  static const _path3 =
      'M15.61 10.62a8 8 0 0 1 -2.39 0.47h-1q-0.52 0 -1 -0.06a5 5 0 0 1 -1.9 -0.67S8.76 10 8.73 10l0 -1.66a6.75 6.75 0 0 0 2.23 1 5.87 5.87 0 0 0 1.19 0.14 6 6 0 0 0 1.19 -0.09 7.63 7.63 0 0 0 1.92 -0.65l0 0.76a0.39 0.39 0 0 0 0.34 0.41 0.37 0.37 0 0 0 0.4 -0.34 21.73 21.73 0 0 0 0.28 -3l0 -1.29c0 -0.43 -0.03 -0.88 -0.08 -1.28 -0.07 -0.64 -0.2 -1.24 -0.2 -1.85L16 2A1.77 1.77 0 0 0 14.86 0.3a4.26 4.26 0 0 0 -1.18 -0.3 0.38 0.38 0 0 0 -0.44 0.31 0.39 0.39 0 0 0 0.3 0.43 3.28 3.28 0 0 1 0.8 0.27 1.75 1.75 0 0 1 0.6 0.45 0.64 0.64 0 0 1 0.1 0.47 0.6 0.6 0 0 1 -0.22 0.39 3.27 3.27 0 0 1 -1.47 0.46 9 9 0 0 1 -2.56 0l-0.94 -0.26 -0.59 -0.27a0.66 0.66 0 0 1 -0.34 -0.47 0.72 0.72 0 0 1 0.31 -0.55 4.29 4.29 0 0 1 1.42 -0.7A3.79 3.79 0 0 1 12.24 0.3a0.33 0.33 0 0 0 0.4 -0.25 0.34 0.34 0 0 0 -0.26 -0.39 4.54 4.54 0 0 0 -1.91 0 5.06 5.06 0 0 0 -1.8 0.68 1.72 1.72 0 0 0 -0.87 1.3 1.51 1.51 0 0 0 0.2 0.77 22.11 22.11 0 0 0 -0.4 2.48 12.06 12.06 0 0 0 0 1.35 12.12 12.12 0 0 0 0.06 1.34c0.07 0.9 0.17 1.51 0.29 2.38s1.16 1.39 2 1.86a6.19 6.19 0 0 0 1.12 0.39 5.87 5.87 0 0 0 1.19 0.14 6 6 0 0 0 1.19 -0.09 7.68 7.68 0 0 0 2.57 -1 0.37 0.37 0 0 0 -0.32 -0.67Zm-0.52 -4.75 0 0.62c0 0.45 0.07 0.9 0.11 1.35a8.09 8.09 0 0 1 -2 0.37h-1c-0.35 0 -0.69 0 -1 -0.06a7.55 7.55 0 0 1 -2.36 -0.57h-0.08l0 -1.31 0 -0.81a6.65 6.65 0 0 0 2.17 1 5.17 5.17 0 0 0 1.19 0.14 5.87 5.87 0 0 0 1.18 -0.09 7.58 7.58 0 0 0 1.79 -0.64Zm-5.71 -2.3a4.68 4.68 0 0 0 0.6 0.22 6.21 6.21 0 0 0 0.62 0.14 10 10 0 0 0 2.93 0A4.55 4.55 0 0 0 15 3.32l0 1.15 0 0.49a8.92 8.92 0 0 1 -1.87 0.32l-1 0c-0.32 0 -0.68 0 -1 -0.07a7.1 7.1 0 0 1 -2.36 -0.57l0 -1.42Z';

  static Path? _p1;
  static Path? _p2;
  static Path? _p3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!],
          colors: [blue, blue, dark],
        ),
      ),
    );
  }
}

/// Verified Task Icon (Form-Validation-Check-Circle)
class MfVerifiedTaskIcon extends StatelessWidget {
  const MfVerifiedTaskIcon({
    super.key,
    this.size = 20,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M20.06 12.45a0.35 0.35 0 0 0 -0.26 0.41 6.88 6.88 0 0 1 -0.43 4.14 8.59 8.59 0 0 1 -2.55 3.34 11.7 11.7 0 0 1 -6.41 2.53A8.79 8.79 0 0 1 4 21a7 7 0 0 1 -2.44 -5.64 10.19 10.19 0 0 1 2.15 -6.1 7.93 7.93 0 0 1 5 -3.11 4.11 4.11 0 0 1 3.56 1.32 0.29 0.29 0 0 0 0.42 0 0.3 0.3 0 0 0 0 -0.42 4.76 4.76 0 0 0 -4.04 -1.62A8.81 8.81 0 0 0 3 8.67a11.06 11.06 0 0 0 -2.54 6.62 8 8 0 0 0 2.81 6.56A9.86 9.86 0 0 0 10.5 24a12.61 12.61 0 0 0 6.89 -2.9 9.39 9.39 0 0 0 2.71 -3.8 7.59 7.59 0 0 0 0.37 -4.59 0.34 0.34 0 0 0 -0.41 -0.26Z';

  static const _path2 =
      'M23.2 0c-0.24 0 -0.2 0.09 -0.86 1 -1.05 1.5 -3.41 4.63 -5.63 7.67 -1.6 2.17 -3.13 4.3 -4.17 5.67a12.59 12.59 0 0 1 -1.15 1.42c-0.07 0.06 -0.16 0 -0.26 0a2.76 2.76 0 0 1 -0.8 -0.43 18.37 18.37 0 0 1 -2.84 -2.93c-0.35 -0.43 -0.45 -0.69 -0.68 -0.51s-0.35 0.16 -0.2 0.38l0.21 0.3a24.85 24.85 0 0 0 2.31 2.82 5.26 5.26 0 0 0 1.63 1.22 1.22 1.22 0 0 0 1.24 -0.04 18.55 18.55 0 0 0 2.16 -2.46c0.82 -1.06 1.81 -2.38 2.81 -3.78 2.35 -3.29 4.81 -7 5.94 -8.79a6.77 6.77 0 0 0 0.67 -1.2 0.35 0.35 0 0 0 -0.38 -0.34Z';

  static Path? _p1;
  static Path? _p2;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!],
          colors: [dark, blue],
        ),
      ),
    );
  }
}

/// Common File Text Clock Icon (Time / Schedule)
class MfTimeClockIcon extends StatelessWidget {
  const MfTimeClockIcon({
    super.key,
    this.size = 18,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M19.56 4.87a3.5 3.5 0 0 0 -0.83 -1c-0.67 -0.62 -1.6 -1.28 -2 -1.67s-1 -1 -1.56 -1.47a3.27 3.27 0 0 0 -0.92 -0.53A4 4 0 0 0 13 0c-0.87 0 -1.87 0.14 -2.58 0.18L1.71 0.92a0.26 0.26 0 1 0 0 0.51h0.37a0.28 0.28 0 0 0 0 0.13c0.15 2.62 0.37 5.28 0.41 7.93a38.08 38.08 0 0 1 -0.23 5.24l-0.6 4.55c0 0.24 -0.2 0.77 -0.26 1.2a1.48 1.48 0 0 0 0.07 0.79 1.93 1.93 0 0 0 1.58 0.73 18.78 18.78 0 0 0 3.21 -0.12c1.25 -0.12 2.5 -0.18 3.75 -0.22 2.94 -0.1 5.88 -0.05 8.82 -0.21a0.29 0.29 0 0 0 0.29 -0.3A0.27 0.27 0 0 0 19 21a0.27 0.27 0 0 0 0.46 -0.17 19.8 19.8 0 0 0 0.28 -2.44c0.08 -1.22 0.08 -2.44 0.13 -3.64 0.06 -1.7 0.38 -3.84 0.36 -5.88a10.36 10.36 0 0 0 -0.67 -4Zm-4.82 -3.22c0.48 0.42 0.94 0.93 1.29 1.25s1.36 1.06 2 1.68a2.55 2.55 0 0 1 0.6 0.7 0.36 0.36 0 0 1 0 0.11l-0.62 0c-1.11 0 -2.25 0.15 -3.33 0.16a8.28 8.28 0 0 1 -0.85 0c-0.2 0 -0.4 0 -0.49 -0.15a1.29 1.29 0 0 1 -0.06 -0.76c0.05 -0.64 0.2 -1.35 0.23 -1.67s0.09 -0.75 0.15 -1.13 0.09 -0.49 0.14 -0.73a2.73 2.73 0 0 1 0.94 0.54Zm4.41 13.1 0 3.63a17.1 17.1 0 0 1 -0.21 2.37 0.26 0.26 0 0 0 0 0.2 0.43 0.43 0 0 0 -0.16 -0.05c-2.95 0.08 -5.88 0 -8.82 0 -1.27 0 -2.53 0 -3.81 0.13a21 21 0 0 1 -2.61 0.09 4.23 4.23 0 0 1 -0.92 -0.12c-0.12 0 -0.23 0 -0.27 -0.11s0 -0.24 0 -0.4c0.07 -0.39 0.2 -0.82 0.23 -1 0.14 -0.91 0.27 -1.83 0.37 -2.75 0.08 -0.62 0.14 -1.23 0.2 -1.85a41.49 41.49 0 0 0 0.07 -5.35c-0.13 -2.66 -0.44 -5.33 -0.68 -8a0.39 0.39 0 0 0 -0.06 -0.11c1.77 -0.08 3.55 -0.2 5.32 -0.29 0.92 -0.08 1.79 -0.14 2.66 -0.14 0.6 0 1.41 -0.11 2.17 -0.11l0.7 0 -0.49 1.91a13 13 0 0 0 -0.45 2 1.78 1.78 0 0 0 0.23 1.14 1.29 1.29 0 0 0 0.73 0.46 4.51 4.51 0 0 0 1.44 0.07c1.08 -0.09 2.2 -0.35 3.3 -0.41a8.26 8.26 0 0 1 0.86 0 11.35 11.35 0 0 1 0.4 2.86c0.06 2.01 -0.18 4.14 -0.2 5.83Z';

  static const _path2 =
      'M14.77 8.36a6.18 6.18 0 0 0 -3 -0.75 8.35 8.35 0 0 0 -3.37 0.76 5.76 5.76 0 0 0 -2.6 2.35 5.51 5.51 0 0 0 -0.39 4 4.7 4.7 0 0 0 2.41 3.15 6.35 6.35 0 0 0 1.71 0.47 6.46 6.46 0 0 0 1.76 0 0.26 0.26 0 1 0 -0.07 -0.51 5.83 5.83 0 0 1 -1.61 0 5.34 5.34 0 0 1 -1.51 -0.48 3.94 3.94 0 0 1 -1.93 -2.75 4.76 4.76 0 0 1 0.43 -3.36 4.92 4.92 0 0 1 2.19 -1.98 7.74 7.74 0 0 1 3 -0.67 5.42 5.42 0 0 1 2.56 0.61 4 4 0 0 1 1.79 1.8 4.27 4.27 0 0 1 0.11 3.39A5 5 0 0 1 13.89 17a4.73 4.73 0 0 1 -1 0.42 2.41 2.41 0 0 1 -0.64 0.12 0.29 0.29 0 0 0 0 0.58 2.63 2.63 0 0 0 0.85 -0.12 6.93 6.93 0 0 0 1.08 -0.42 5.64 5.64 0 0 0 2.76 -2.86 5.11 5.11 0 0 0 0 -4 4.84 4.84 0 0 0 -2.17 -2.36Z';

  static const _path3 =
      'M11.89 10.11a0.28 0.28 0 0 0 -0.2 -0.32 0.27 0.27 0 0 0 -0.31 0.2c-0.19 0.57 -0.35 1.14 -0.5 1.72l-0.21 0.85c-0.06 0.28 -0.11 0.56 -0.17 0.84 0 0 0 0.58 0.47 0.61h0.2L12 14l2.11 -0.26a0.3 0.3 0 1 0 0 -0.59l-2.17 0h-0.38c0 -0.16 0.06 -0.32 0.08 -0.48 0.12 -0.93 0.13 -1.75 0.25 -2.56Z';

  static const _path4 =
      'M22.14 9.4c-0.06 -0.65 -0.66 -0.58 -0.64 0s0 1 0 1.29a51.82 51.82 0 0 1 0.32 7.93 16.83 16.83 0 0 1 -0.38 2.86 2.2 2.2 0 0 1 -0.5 0.68 3.6 3.6 0 0 1 -1.61 0.41c-0.6 0.07 -6.12 0.48 -8.06 0.51l-4 0c-1 -0.06 -1.38 0.77 -0.55 0.91a70.85 70.85 0 0 0 8.22 -0.17c2 -0.19 5.78 -0.2 6.62 -1a2.81 2.81 0 0 0 0.9 -2c0.5 -4 0 -6.86 -0.27 -10.08 -0.07 -0.4 -0.04 -0.88 -0.05 -1.34Z';

  static Path? _p1;
  static Path? _p2;
  static Path? _p3;
  static Path? _p4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!],
          colors: [blue, blue, blue, dark],
        ),
      ),
    );
  }
}

/// Shop Assistant Icon (Employer / Hiring Mode)
class MfShopAssistantIcon extends StatelessWidget {
  const MfShopAssistantIcon({
    super.key,
    this.size = 72,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M9.49 19.42a23.07 23.07 0 0 0 2 3.94s0.62 0.32 0.88 -0.22c0 -0.08 0.12 -0.24 0.22 -0.46 0.72 -1.59 1.15 -2.61 1.41 -3.26 0.55 -0.62 -0.45 -1.17 -0.76 -0.29s-1 1.83 -1.38 2.57c-0.08 0.15 0.19 0.41 -1.58 -2.57 -0.34 -0.79 -1.28 -0.58 -0.79 0.29Zm8.2 -7.27C21.33 8.41 20.07 1.21 14.78 0.6a0.34 0.34 0 0 0 -0.37 0.29c-0.09 0.71 1.31 0 3 2a6.32 6.32 0 0 1 1.23 4.66A6 6 0 0 1 16.32 6a9.61 9.61 0 0 1 -2.11 -2.15 0.29 0.29 0 0 0 -0.21 -0.2c-0.3 -0.22 -0.23 0 -2.44 1.2a35.48 35.48 0 0 1 -5.5 2.39A6.66 6.66 0 0 1 12.85 0.59a0.3 0.3 0 0 0 0 -0.59C4.07 -0.24 3 10 8 13.29a0.33 0.33 0 0 0 0.38 -0.54 6.26 6.26 0 0 1 -2.29 -4.84c2.47 -0.58 3.68 -0.25 7.72 -3.55A6.85 6.85 0 0 0 16 7.12c1.43 1.1 1.79 0.8 2.58 1.17a6.6 6.6 0 0 1 -1.33 3.4c-0.25 0.5 -0.05 0.61 0.44 0.46Z';

  static const _path2 =
      'M6.85 14.89c-3.63 1.8 -5.51 3.56 -6 7.51a6.41 6.41 0 0 0 0 0.88 0.29 0.29 0 0 0 0.58 0 5 5 0 0 1 0.13 -0.77A10.55 10.55 0 0 1 5.06 17c0.2 0.71 0.34 0.65 0.16 3.27a18.85 18.85 0 0 1 -0.52 3.48 0.35 0.35 0 0 0 0.67 0 11.16 11.16 0 0 0 0.92 -3.06A7.7 7.7 0 0 0 6.14 18a4.11 4.11 0 0 0 -0.51 -1.22 0.45 0.45 0 0 0 -0.07 -0.18 14.9 14.9 0 0 1 1.6 -1.11 0.33 0.33 0 0 0 -0.31 -0.6Z';

  static const _path3 =
      'M20.83 17.21a9.33 9.33 0 0 0 -2.81 -2 0.29 0.29 0 0 0 -0.29 0.51c0.28 0.18 0.54 0.38 0.78 0.57 -0.2 0.12 -0.16 0.36 -0.44 1.3a13.89 13.89 0 0 0 -0.77 2.47 5.66 5.66 0 0 0 0.39 3s0 0.3 0 0.34a0.34 0.34 0 1 0 0.68 0.07 6.12 6.12 0 0 0 -0.18 -1.56 27.39 27.39 0 0 1 0.83 -5.12 14.27 14.27 0 0 1 3.14 4.94 5.81 5.81 0 0 1 0.27 1.65 0.33 0.33 0 0 0 0.66 0 8.7 8.7 0 0 0 -2.26 -6.17Z';

  static const _path4 =
      'M10.19 9.86a0.33 0.33 0 0 0 0.33 -0.33c0.15 -0.69 -1.12 -1.42 -1.94 -0.92a1.39 1.39 0 0 0 -0.5 1c-0.08 0.44 0.46 0.45 0.49 0.38 0.67 -0.99 1.51 -0.13 1.62 -0.13Z';

  static const _path5 =
      'M13.37 9.52c0.08 0 1.44 -0.85 1.62 0.14a0.33 0.33 0 0 0 0.66 0 1.45 1.45 0 0 0 -2 -1.48 3.33 3.33 0 0 0 -0.72 0.79c-0.09 0.24 -0.07 0.41 0.07 0.48a0.36 0.36 0 0 0 0.37 0.07Z';

  static const _path6 =
      'M10.94 11c-0.39 0.19 0.27 1.1 0.66 1.35 0.82 0.33 1.48 0.16 2.09 -0.85 0.29 -0.32 -0.21 -0.76 -0.5 -0.44a1.2 1.2 0 0 1 -0.89 0.34c-0.92 -0.01 -0.85 -0.7 -1.36 -0.4Z';

  static const _path7 =
      'M16.84 12.88c-0.4 -0.45 -1 -1 -2.43 -0.41a8 8 0 0 0 -2.24 1.66C11 13.35 8.45 12.72 7.86 14a6.37 6.37 0 0 0 -0.17 2.51 1.69 1.69 0 0 0 1.09 1.29l0.81 0.1a3.91 3.91 0 0 0 2.22 -1.78 3.56 3.56 0 0 0 2 2.08h0.83a0.94 0.94 0 0 0 0.35 -0.15c0.75 -0.47 1.2 -1.84 1.49 -2.58a3.73 3.73 0 0 0 0.36 -2.59Zm-7.91 3.95c-0.5 -0.29 -0.43 -1.22 -0.4 -1.84 0 -0.78 0 -1 1.09 -1a4.57 4.57 0 0 1 2 0.5c-0.33 1.05 -1.75 2.88 -2.69 2.34Zm6.62 -1.69a7 7 0 0 1 -1 1.88c-0.39 0.41 -0.73 0 -1.11 -0.27a3.18 3.18 0 0 1 -0.82 -2.12l0.85 -0.74c1.39 -1 2.46 -0.89 2.54 -0.68 0.23 0.47 -0.27 1.49 -0.46 1.93Z';

  static Path? _p1;
  static Path? _p2;
  static Path? _p3;
  static Path? _p4;
  static Path? _p5;
  static Path? _p6;
  static Path? _p7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);
    _p6 ??= SvgPathParser.parse(_path6);
    _p7 ??= SvgPathParser.parse(_path7);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!, _p6!, _p7!],
          colors: [blue, blue, blue, blue, blue, blue, dark],
        ),
      ),
    );
  }
}

/// Certified Ribbon Check 2 (Bookmark / Save Icon)
class MfBookmarkRibbonIcon extends StatelessWidget {
  const MfBookmarkRibbonIcon({
    super.key,
    this.size = 22,
    this.isActive = false,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final bool isActive;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M11.82 19.24a44.21 44.21 0 0 1 -6 3.76 10.47 10.47 0 0 1 -2.43 1 1.42 1.42 0 0 1 -0.88 -0.06 0.58 0.58 0 0 1 -0.23 -0.27A4.51 4.51 0 0 1 2 22.52c-0.23 -1.92 -0.35 -6.08 -0.33 -10.24A89.67 89.67 0 0 1 2.15 2 3.32 3.32 0 0 1 2.57 0.66 2.25 2.25 0 0 1 3.83 0.22 74 74 0 0 1 12.38 0a84.28 84.28 0 0 1 8.52 0.5 3.35 3.35 0 0 1 1 0.27 0.6 0.6 0 0 1 0.32 0.37c0.23 0.67 0 6 -0.35 11.27 -0.29 4 -0.66 8.07 -0.94 10a3.71 3.71 0 0 1 -0.36 1.3 0.71 0.71 0 0 1 -0.59 0.19 8.38 8.38 0 0 1 -2.59 -1 36.75 36.75 0 0 1 -5.58 -3.61Zm9.4 -17.56c-0.17 0 -0.42 0 -0.66 -0.07 -1.95 -0.26 -6.24 -0.43 -10.08 -0.46a56.83 56.83 0 0 0 -6.68 0.22l-0.41 0.08a8.1 8.1 0 0 0 -0.23 1.4C3 4.52 2.8 7.17 2.71 10c-0.15 4.64 -0.15 9.81 0.06 12.18 0 0.46 0.27 0.89 0.21 1a1.85 1.85 0 0 0 0.41 -0.07 15.06 15.06 0 0 0 3 -1.29 34.89 34.89 0 0 0 5.24 -3.31c0.47 -0.37 0.16 0.18 4.43 2.66a22.72 22.72 0 0 0 3.42 1.7 2.72 2.72 0 0 0 0.43 0.11c0 -0.17 0.17 -0.46 0.21 -0.78 0.26 -1.86 0.57 -5.88 0.8 -9.9a106.07 106.07 0 0 0 0.3 -10.69Z';

  static const _path2 =
      'M6.71 11.94A28.23 28.23 0 0 0 9 14.11a2.64 2.64 0 0 0 1.48 0.63 2.61 2.61 0 0 0 1.51 -0.9 19.21 19.21 0 0 0 2.1 -2.59 31.63 31.63 0 0 0 3.38 -6.2 0.36 0.36 0 0 0 -0.2 -0.44 0.34 0.34 0 0 0 -0.44 0.2 33.43 33.43 0 0 1 -3 4.85 36.52 36.52 0 0 1 -2.41 3.16 5.67 5.67 0 0 1 -0.78 0.78c-0.08 0.07 -0.12 0.14 -0.18 0.14a2.37 2.37 0 0 1 -1.32 -0.58c-0.67 -0.47 -1.38 -1.11 -2.07 -1.67a0.3 0.3 0 0 0 -0.42 0 0.31 0.31 0 0 0 0 0.43Z';

  static Path? _p1;
  static Path? _p2;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    final ribbonColor = isActive ? blue : dark;
    final checkColor = isActive ? (isDark ? Colors.white : MfColors.primary) : blue;

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!],
          colors: [ribbonColor, checkColor],
        ),
      ),
    );
  }
}

/// Logic Connection 2 (Share / Network Icon)
class MfShareNetworkIcon extends StatelessWidget {
  const MfShareNetworkIcon({
    super.key,
    this.size = 20,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'm9.64 9.59 1.13 -0.48L12 8.59l1.19 -0.53 1.22 -0.56c0.68 -0.74 0.81 -1.17 -0.26 -0.88 -0.46 0.13 -0.92 0.28 -1.37 0.44s-0.83 0.3 -1.24 0.48 -0.81 0.37 -1.2 0.58 -0.74 0.42 -1.1 0.65c-0.71 0.6 -1.02 1.07 0.4 0.82Z';

  static const _path2 =
      'M8.84 12.8A4.33 4.33 0 0 0 7.1 8.5a4.75 4.75 0 0 0 -2.4 -0.63 5 5 0 0 0 -4 1.76 3.48 3.48 0 0 0 -0.7 1.88 5.72 5.72 0 0 0 0.54 2.78 4.1 4.1 0 0 0 3 2.18 4.42 4.42 0 0 0 5.3 -3.67ZM6.6 14.88a3.62 3.62 0 0 1 -2.8 0.51 3.05 3.05 0 0 1 -2.21 -1.6A4.84 4.84 0 0 1 1.14 12a2.81 2.81 0 0 1 0.37 -1.72 4.08 4.08 0 0 1 3.17 -1.61c3.75 -0.16 3.51 3.25 3.36 4a3.71 3.71 0 0 1 -1.44 2.21Z';

  static const _path3 =
      'M14.06 16.87c-0.48 -0.25 -1 -0.48 -1.44 -0.7 -0.69 -0.31 -1.4 -0.56 -2.1 -0.86 -0.29 -0.1 -0.62 -0.25 -1 -0.39 -1 -0.47 -1.25 -0.28 -0.56 0.7 0.39 0.24 0.76 0.5 1.09 0.68 0.7 0.31 1.39 0.63 2.1 0.91 0.47 0.18 1 0.34 1.42 0.51 1.18 0.28 1.17 -0.11 0.49 -0.85Z';

  static const _path4 =
      'M19.2 0.33a5.4 5.4 0 0 0 -3.69 2.58 4.08 4.08 0 0 0 -0.56 3 6.4 6.4 0 0 0 0.79 1.62A4.55 4.55 0 0 0 19.19 9a4.78 4.78 0 0 0 3.45 -1.38A5.17 5.17 0 0 0 24 4.7 4 4 0 0 0 19.2 0.33Zm4 4.26A4.3 4.3 0 0 1 22 7a3.88 3.88 0 0 1 -2.76 1 3.45 3.45 0 0 1 -2.59 -1.16 2.85 2.85 0 0 1 -0.2 -3.34 4.52 4.52 0 0 1 2.92 -2.31 3 3 0 0 1 3.8 3.4Z';

  static const _path5 =
      'M22.89 16.13a0.34 0.34 0 1 0 -0.5 0.46 2.27 2.27 0 0 1 0.49 1 4 4 0 0 1 0.12 1.13 4.38 4.38 0 0 1 -0.31 1.48 3.41 3.41 0 0 1 -0.82 1.22 4.17 4.17 0 0 1 -2.74 1.19 3 3 0 0 1 -2.56 -1.06 3.3 3.3 0 0 1 -0.63 -2.92A4.67 4.67 0 0 1 17.65 16a4.06 4.06 0 0 1 2 -0.73 2.23 2.23 0 0 1 1.91 0.66 0.32 0.32 0 0 0 0.43 0 0.29 0.29 0 0 0 0 -0.42 2.7 2.7 0 0 0 -1.88 -1 4.88 4.88 0 0 0 -3 0.71 5.56 5.56 0 0 0 -1.95 2.24 6.22 6.22 0 0 0 -0.42 1.54 4.28 4.28 0 0 0 0.9 3.23 4 4 0 0 0 3.54 1.44 5.15 5.15 0 0 0 3.35 -1.63 4.53 4.53 0 0 0 0.95 -1.57 5.61 5.61 0 0 0 0.29 -1.77 4.86 4.86 0 0 0 -0.18 -1.37 3.14 3.14 0 0 0 -0.7 -1.2Z';

  static Path? _p1;
  static Path? _p2;
  static Path? _p3;
  static Path? _p4;
  static Path? _p5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!],
          colors: [dark, blue, dark, blue, blue],
        ),
      ),
    );
  }
}

/// Light Mode Icon (Light-Mode-Dark-Light)
class MfLightModeIcon extends StatelessWidget {
  const MfLightModeIcon({
    super.key,
    this.size = 22,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M16.12 8.84a5.35 5.35 0 0 0 -4.53 -2.36 7.67 7.67 0 0 0 -2.65 0.43C4.87 8.47 3.32 15.65 9 17c2.67 0.66 5.37 0.74 7 -1.46a6.17 6.17 0 0 0 0.12 -6.7ZM15.34 15c-1.45 1.79 -3.79 1.55 -6 1a4.93 4.93 0 0 1 -1.18 -0.42C5 13.94 6.28 8.89 9.23 7.63c0.61 -0.26 3.84 -1.43 6.08 1.37a3.76 3.76 0 0 1 0.81 1.64 5.28 5.28 0 0 1 -0.78 4.36Z';
  static const _path2 =
      'M11.89 10a5 5 0 0 1 -0.26 -2.17c0.1 -0.43 -0.74 -0.5 -0.82 0a4.1 4.1 0 0 0 1.08 3.78 5.44 5.44 0 0 0 3.67 1.84 0.37 0.37 0 1 0 0.06 -0.74A4.89 4.89 0 0 1 11.89 10Z';
  static const _path3 =
      'M11.22 5a0.33 0.33 0 0 0 0.32 -0.33 10.56 10.56 0 0 0 0.17 -1.29 5.88 5.88 0 0 0 -0.44 -2 0.31 0.31 0 0 0 -0.56 0.22c-0.02 0.29 -0.23 3.4 0.51 3.4Z';
  static const _path4 =
      'M3.31 12.18c-0.44 -0.07 -0.83 -0.21 -1.25 -0.28S0 11.94 0 12.26c-0.09 0.64 2.11 0.77 3.31 0.57a0.33 0.33 0 0 0 0 -0.65Z';
  static const _path5 =
      'M21.94 11.93c-0.42 0.08 -0.81 0.22 -1.24 0.29a0.33 0.33 0 0 0 0 0.65A8.7 8.7 0 0 0 22 13c0.55 0 2 -0.42 2 -0.74s-1.74 -0.38 -2.06 -0.33Z';
  static const _path6 =
      'M12.33 19.53c0 -0.11 -0.17 -0.15 -0.38 -0.09 -0.37 0.11 -0.81 2.18 -0.09 3.11a0.32 0.32 0 0 0 0.58 -0.29 8.55 8.55 0 0 0 -0.11 -2.73Z';
  static const _path7 =
      'M6.67 18.05c-0.39 0.36 -2.13 1.43 -2.35 2.23 -0.05 0.18 -0.06 0.31 0 0.41a0.36 0.36 0 0 0 0.21 0.12 5.13 5.13 0 0 0 2.6 -2.35 0.32 0.32 0 0 0 -0.46 -0.41Z';
  static const _path8 =
      'M17.37 18.11a0.33 0.33 0 0 0 -0.5 0.42 6.2 6.2 0 0 0 0.79 1.09 7.17 7.17 0 0 0 1.84 1.24 0.32 0.32 0 0 0 0.2 -0.13c0.63 -0.58 -2.18 -2.48 -2.33 -2.62Z';
  static const _path9 =
      'M5.74 7.91a0.32 0.32 0 0 0 0.46 -0.45 6 6 0 0 0 -2.7 -2.19c-0.37 -0.16 -0.56 0.05 -0.54 0.21 0 0.35 1.09 1.36 1.54 1.65s0.84 0.49 1.24 0.78Z';
  static const _path10 =
      'M21 5.52c0 -0.15 -0.16 -0.38 -0.54 -0.2a5.9 5.9 0 0 0 -2.68 2.2 0.32 0.32 0 0 0 0.46 0.45C18.43 7.82 21 6.24 21 5.52Z';

  static Path? _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);
    _p6 ??= SvgPathParser.parse(_path6);
    _p7 ??= SvgPathParser.parse(_path7);
    _p8 ??= SvgPathParser.parse(_path8);
    _p9 ??= SvgPathParser.parse(_path9);
    _p10 ??= SvgPathParser.parse(_path10);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!, _p6!, _p7!, _p8!, _p9!, _p10!],
          colors: [blue, dark, dark, dark, dark, dark, dark, dark, dark, dark],
        ),
      ),
    );
  }
}

/// Night Mode Icon (Weather-Night-Clear)
class MfNightModeIcon extends StatelessWidget {
  const MfNightModeIcon({
    super.key,
    this.size = 22,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M19 13.63a0.27 0.27 0 0 0 -0.3 0.3 8.66 8.66 0 0 1 -0.6 3.2 7.44 7.44 0 0 1 -1.6 2.7 12 12 0 0 1 -2.1 1.7 13.44 13.44 0 0 1 -2.4 1.2 5.33 5.33 0 0 1 -2.5 0.2 11.7 11.7 0 0 1 -2.5 -0.7l-1.8 -0.9c-0.6 -0.4 -1.1 -0.8 -1.6 -1.2a7.15 7.15 0 0 1 -2.2 -4.4 10.64 10.64 0 0 1 0.6 -5 10.07 10.07 0 0 1 4.5 -5.3 5.1 5.1 0 0 1 4.5 -0.5c0.2 0.1 0.3 0 0.4 -0.2s0 -0.3 -0.2 -0.4a6.08 6.08 0 0 0 -5.1 0.4 12 12 0 0 0 -5.1 5.6 10.59 10.59 0 0 0 -0.8 5.5 7.77 7.77 0 0 0 2.5 5 8.32 8.32 0 0 0 1.8 1.3 17.38 17.38 0 0 0 1.9 1 12.9 12.9 0 0 0 2.8 0.8 7 7 0 0 0 2.9 -0.3 11.88 11.88 0 0 0 2.5 -1.3 19.17 19.17 0 0 0 2.2 -1.8 7.53 7.53 0 0 0 1.7 -3 11.34 11.34 0 0 0 0.6 -3.2c0.1 -0.6 -0.1 -0.7 -0.1 -0.7Z';
  static const _path2 =
      'M8.3 14.43a5.54 5.54 0 0 1 -1 -2.2 7 7 0 0 1 -0.1 -2.5 7 7 0 0 1 1.7 -3.3 2.54 2.54 0 0 1 2.1 -0.9 0.27 0.27 0 0 0 0.3 -0.3 0.27 0.27 0 0 0 -0.3 -0.3 3.19 3.19 0 0 0 -2.7 1 7.12 7.12 0 0 0 -2.1 3.6 7.08 7.08 0 0 0 0 2.9 8.08 8.08 0 0 0 1.1 2.7 6.79 6.79 0 0 0 3.6 2.4 6.12 6.12 0 0 0 4.2 -0.5 6.45 6.45 0 0 0 1.6 -1.1 5 5 0 0 0 1.1 -1.6 0.36 0.36 0 1 0 -0.6 -0.4 3.45 3.45 0 0 1 -1 1.3 4.83 4.83 0 0 1 -1.4 0.9 5 5 0 0 1 -3.6 0.2 4.67 4.67 0 0 1 -2.9 -1.9Z';
  static const _path3 =
      'M14.2 3h0.8v0.2c0.1 0.5 0.1 1.1 0.2 1.6a0.3 0.3 0 0 0 0.6 0c0 -0.5 0.2 -1.8 0.2 -1.9a7.07 7.07 0 0 1 1.2 -0.2 0.27 0.27 0 0 0 0.3 -0.3 0.27 0.27 0 0 0 -0.3 -0.3c-0.4 -0.1 -0.7 -0.1 -1.1 -0.2 -0.1 -0.5 -0.2 -1.1 -0.3 -1.6a0.3 0.3 0 0 0 -0.6 0 8.75 8.75 0 0 0 -0.2 1.6V2a5.39 5.39 0 0 0 -1 0.3c-0.3 0.13 -0.3 0.63 0.2 0.7Z';
  static const _path4 =
      'M23.6 7.63a4.87 4.87 0 0 1 -1.2 -0.1L22.1 6a0.3 0.3 0 0 0 -0.6 0 7.72 7.72 0 0 1 -0.2 1.5l-1.2 0.3a0.3 0.3 0 1 0 0 0.6 5 5 0 0 0 1.2 0.2v0.3a9.36 9.36 0 0 0 0.4 1.6c0 0.2 0.2 0.3 0.4 0.3s0.3 -0.2 0.3 -0.4V8.73l1.2 -0.3c0.2 0 0.3 -0.2 0.3 -0.4s-0.2 -0.4 -0.3 -0.4Z';

  static Path? _p1, _p2, _p3, _p4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!],
          colors: [blue, blue, dark, dark],
        ),
      ),
    );
  }
}

/// Unified Theme Toggle Icon (renders Light or Night icon based on current state)
class MfThemeToggleIcon extends StatelessWidget {
  const MfThemeToggleIcon({
    super.key,
    required this.isDark,
    this.size = 22,
  });

  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return isDark
        ? MfLightModeIcon(size: size)
        : MfNightModeIcon(size: size);
  }
}

/// Logout / Login Door Icon (Logout-Door)
class MfLogoutDoorIcon extends StatelessWidget {
  const MfLogoutDoorIcon({
    super.key,
    this.size = 28,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M6.48 10.78a0.33 0.33 0 0 0 -0.29 0.38 1.38 1.38 0 0 1 -0.8 1.27 0.84 0.84 0 0 1 -1.13 -0.31 1.18 1.18 0 0 1 -0.26 -0.81 1.17 1.17 0 0 1 0.31 -0.83 1.05 1.05 0 0 1 0.25 -0.18 0.66 0.66 0 0 1 0.31 -0.06c0.08 0 0.29 0.08 0.34 0.06l0.11 0a0.29 0.29 0 0 0 0.24 -0.07 0.3 0.3 0 0 0 -0.08 -0.52A4 4 0 0 0 5 9.56a1.56 1.56 0 0 0 -0.61 0 1.64 1.64 0 0 0 -0.56 0.24A2 2 0 0 0 3 11.2a2.19 2.19 0 0 0 0.39 1.63 1.83 1.83 0 0 0 2.54 0.44 2.18 2.18 0 0 0 1 -2.21 0.33 0.33 0 0 0 -0.45 -0.28Z';
  static const _path2 =
      'M12.57 2.42a13 13 0 0 1 2.13 0.08 1.64 1.64 0 0 1 1 0.4 0.83 0.83 0 0 1 0.16 0.45A11.79 11.79 0 0 1 16 4.53l0.3 2.82a0.34 0.34 0 0 0 0.35 0.33 0.33 0.33 0 0 0 0.35 -0.35l0 -2.85a6.76 6.76 0 0 0 -0.09 -1.58 1.75 1.75 0 0 0 -0.44 -0.82 2.18 2.18 0 0 0 -1.32 -0.52 9.66 9.66 0 0 0 -2.67 0.26 0.3 0.3 0 0 0 0.06 0.6Z';
  static const _path3 =
      'M16.92 17.55a0.31 0.31 0 0 0 -0.3 0.3c-0.36 3.87 0.64 3 -3.94 3.28a0.35 0.35 0 0 0 -0.34 0.35 0.34 0.34 0 0 0 0.35 0.33c0.91 0.05 2.39 0.26 3.33 0.25a2.06 2.06 0 0 0 1.16 -0.27 0.8 0.8 0 0 0 0.24 -0.38 2.79 2.79 0 0 0 0 -0.68l-0.25 -2.88a0.29 0.29 0 0 0 -0.25 -0.3Z';
  static const _path4 =
      'M24 11.73a1.27 1.27 0 0 0 -0.43 -0.46A24.38 24.38 0 0 0 21.21 10a9 9 0 0 0 -3 -1.1 0.48 0.48 0 0 0 -0.44 0.43 1.31 1.31 0 0 0 0 0.44c0.1 0.38 0.35 1.09 0.47 1.65l0 0.42a1.9 1.9 0 0 1 -1.77 0.43 8.16 8.16 0 0 1 -2.85 -1.32 1.91 1.91 0 0 0 -0.32 -0.19 0.31 0.31 0 0 0 -0.4 0.08 0.3 0.3 0 0 0 0 0.42 2 2 0 0 0 0.33 0.2 9.36 9.36 0 0 0 3 1.56 2.69 2.69 0 0 0 2.77 -0.71 1.05 1.05 0 0 0 0.18 -0.83c0 -0.41 -0.19 -1 -0.3 -1.44l0.77 0.38c0.95 0.46 2.09 1.1 2.79 1.53l0.29 0.2 -0.06 0.13c-0.41 0.94 -1.37 2.79 -2 3.91a9 9 0 0 0 -0.42 -1 1.13 1.13 0 0 0 -0.6 -0.63 2.26 2.26 0 0 0 -0.78 0 14.51 14.51 0 0 1 -2.23 0.34 4.07 4.07 0 0 1 -2.12 -1 8.81 8.81 0 0 1 -1.48 -2 0.34 0.34 0 1 0 -0.58 0.35A9.33 9.33 0 0 0 14 14.48a4.8 4.8 0 0 0 2.47 1.27 3 3 0 0 0 0.74 0c2.51 -0.26 2 -0.51 2.23 0.05s0.39 1.19 0.5 1.54a2.06 2.06 0 0 0 0.15 0.34 0.5 0.5 0 0 0 0.7 0.2 1.37 1.37 0 0 0 0.44 -0.48c0.37 -0.56 1.09 -1.81 1.69 -2.95a21.19 21.19 0 0 0 1 -2.09 1 1 0 0 0 0.08 -0.63Z';
  static const _path5 =
      'M11.31 5.23c-0.07 -0.73 -0.06 -2 -0.23 -3a3.7 3.7 0 0 0 -0.46 -1.29 0.58 0.58 0 0 0 -0.37 -0.23C9.94 0.65 9.07 0.47 8.75 0.79c-0.11 0.12 0.09 0.53 0.23 0.62s0.49 0 0.71 0a1 1 0 0 1 0.38 0.07 4.14 4.14 0 0 1 0.26 1.34c0.05 0.9 0 1.88 0 2.51 0.1 2.12 0.1 4.24 0.11 6.37s0 4.25 0 6.37l0 3 0 0.63a0.7 0.7 0 0 1 -0.08 0.37c-0.12 0.13 -0.67 0.16 -0.88 0.31a0.45 0.45 0 0 0 -0.09 0.58c0.18 0.17 0.46 0.09 0.68 0a2.06 2.06 0 0 0 0.87 -0.41 1.15 1.15 0 0 0 0.26 -0.53 4.24 4.24 0 0 0 0.06 -1l0.11 -2.93c0.11 -2.14 0.21 -4.28 0.19 -6.42s-0.1 -4.31 -0.25 -6.44Z';
  static const _path6 =
      'M8 1a0.7 0.7 0 0 0 -0.32 -0.15 9.53 9.53 0 0 0 -2 0.26c-1.55 0.31 -3.52 0.82 -4.41 1.08l-0.47 0.15c-0.23 0.1 -0.31 0.56 -0.31 0.58L0.23 7.85l-0.17 7.6 0 3.61A7.34 7.34 0 0 0 0 20a1.37 1.37 0 0 0 0.16 0.58 1.43 1.43 0 0 0 0.58 0.4c0.61 0.28 1.94 0.78 3.29 1.26s2.71 0.92 3.35 1.09a1.36 1.36 0 0 0 0.79 0 1.18 1.18 0 0 0 0.5 -1c0 -0.91 0.27 -3.26 0.27 -5.91a134.8 134.8 0 0 0 -0.65 -14.9c-0.05 -0.43 -0.1 -0.38 -0.29 -0.52Zm-0.37 20.54c0 0.22 -0.06 0.44 -0.09 0.62l-0.2 0c-1.44 -0.42 -4.55 -1.47 -5.89 -2a3.75 3.75 0 0 1 -0.37 -0.21L1 19l0 -3.56V7.86c0.18 -5.94 -0.07 -5 0.62 -5.14a46.34 46.34 0 0 1 5.63 -1.09 0.8 0.8 0 0 1 0.28 0 82.39 82.39 0 0 1 0.31 8.28c0.05 4.45 0.01 9.37 -0.21 11.63Z';

  static Path? _p1, _p2, _p3, _p4, _p5, _p6;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);
    _p6 ??= SvgPathParser.parse(_path6);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!, _p6!],
          colors: [blue, dark, dark, blue, blue, blue],
        ),
      ),
    );
  }
}

/// Worker Rating Man Icon (Human-Resources-Rating-Man)
class MfWorkerRatingManIcon extends StatelessWidget {
  const MfWorkerRatingManIcon({
    super.key,
    this.size = 36,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M15.81 19.4a4.24 4.24 0 0 0 -0.71 -0.4c-1.53 -0.6 -1.38 -0.15 -0.62 -0.74 2.43 -1.86 2.11 -6.44 -1.11 -7.07a0.34 0.34 0 0 0 -0.4 0.26c-0.13 0.6 0.79 0.21 1.67 1.33 1.38 1.78 0.34 6.1 -4.14 5.06 -3.45 -0.7 -3 -6.77 1.71 -6.46a0.3 0.3 0 1 0 0.06 -0.59 4.24 4.24 0 0 0 -2.83 7.88c-2.19 0.89 -4 2.67 -3.67 5a0.3 0.3 0 0 0 0.6 0 3.61 3.61 0 0 1 0.81 -1.82 12.84 12.84 0 0 1 2.22 -2.22c0.94 -0.57 0.89 -0.53 0.95 -0.61a7.56 7.56 0 0 0 1 0.13 8.14 8.14 0 0 0 -0.08 3.94 0.13 0.13 0 0 0 0 0.06 0.29 0.29 0 0 0 0.38 0.22 0.27 0.27 0 0 0 0.27 -0.2 0.29 0.29 0 0 0 0 -0.09 14.27 14.27 0 0 0 0.25 -3c-0.17 -1 -0.15 -0.8 -0.14 -0.9a4.43 4.43 0 0 0 1.1 -0.18 19 19 0 0 1 2 1.28 9 9 0 0 1 2.07 3.36 0.34 0.34 0 1 0 0.66 -0.14 5.82 5.82 0 0 0 -2.05 -4.1Z';
  static const _path2 =
      'M11.19 13.94a4.3 4.3 0 0 1 -2.38 0.64 0.3 0.3 0 0 0 -0.05 0.59c2 0.38 2.77 0 4.41 -1.07 0.62 0.62 1.18 1.41 1.54 1a0.34 0.34 0 0 0 0 -0.48c-0.85 -0.89 -0.93 -1.87 -1.81 -1.62a17.16 17.16 0 0 0 -1.71 0.94Z';
  static const _path3 =
      'M10.07 5.44c-0.49 0.93 -1.7 2.71 -0.65 3 0.89 0.26 1.82 -0.76 2.42 -1.45 0 0 0.21 -0.14 0.36 -0.27 0.24 0.25 0.5 0.5 0.77 0.73a5.52 5.52 0 0 0 1.74 1c1.07 0.1 0.64 -1.78 0.45 -2.85L15 5.38c0.76 -0.37 2.11 -1 2.05 -1.87 -0.07 -1 -1.51 -0.9 -2.62 -1h-0.29L13.12 0.63c-0.72 -0.9 -1.55 -0.74 -2 0.16l-0.67 1.48c0 0.06 -0.15 0.19 -0.18 0.28A6.2 6.2 0 0 0 8 2.84c-0.49 0.28 -0.47 0.89 -0.06 1.34a8.81 8.81 0 0 0 2.13 1.26Zm0 -2c0.19 0 0.41 0.14 0.71 0s0.39 -0.55 1.29 -2.3a1.3 1.3 0 0 1 0.2 0.17c0.15 0.2 0.84 1.75 1.14 2.08a0.8 0.8 0 0 0 0.41 0.22 10.81 10.81 0 0 1 2 0.23 10.58 10.58 0 0 1 -1.7 0.75 0.68 0.68 0 0 0 -0.27 0.71 10.26 10.26 0 0 1 0.4 1.89 7.63 7.63 0 0 1 -1.75 -1.41c-0.81 -0.83 -1.69 1.79 -2.75 2a1.2 1.2 0 0 1 0 -0.19c0.11 -0.54 0.81 -1.68 1 -2.23 0 0.14 0.11 -0.45 -0.28 -0.45l-0.92 -0.45c-0.16 -0.12 -1 -0.59 -1.14 -0.84 0.12 -0.03 1.59 -0.2 1.68 -0.21Z';
  static const _path4 =
      'M24 6.4c-0.1 -1 -1.48 -0.83 -2.56 -0.94a1.73 1.73 0 0 0 -0.36 0l-1 -1.68c-0.67 -0.78 -1.37 -0.63 -1.75 0.14l-0.64 1.39a0.34 0.34 0 0 0 0.61 0.3c0.91 -1.83 0.81 -1.74 1.13 -1.31 0.13 0.17 0.83 1.67 1.1 2s0.66 0.18 0.82 0.21c0.47 0.07 1.29 0 1.61 0.11 0 0 -1.67 0.74 -1.79 0.8a0.65 0.65 0 0 0 -0.28 0.72 9.47 9.47 0 0 1 0.36 1.66c-2 -1.05 -1.64 -2.32 -3 -0.59 -0.16 0.19 -0.92 1.24 -1.35 1.31a5 5 0 0 1 0 -1.86 0.3 0.3 0 0 0 -0.56 -0.22 6.1 6.1 0 0 0 -0.21 2c0.07 0.87 0.7 1 1.42 0.58a6.63 6.63 0 0 0 1.35 -1.3l0.32 -0.23a7.14 7.14 0 0 0 1.62 1.28c0.51 0.27 1 0.56 1.36 0.17s0 -2 -0.07 -2.81c0.7 -0.34 1.94 -0.96 1.87 -1.73Z';
  static const _path5 =
      'M1.87 8.18a14.51 14.51 0 0 0 -0.25 1.94 1.1 1.1 0 0 0 0.18 0.88c0.39 0.39 0.85 0.1 1.36 -0.17a7.14 7.14 0 0 0 1.62 -1.29l0.32 0.23A6.92 6.92 0 0 0 6.45 11c0.71 0.4 1.35 0.3 1.42 -0.58a6.07 6.07 0 0 0 -0.21 -2 0.3 0.3 0 0 0 -0.56 0.22 5 5 0 0 1 0 1.86c-0.44 -0.07 -1.21 -1.14 -1.35 -1.31 -1.37 -1.73 -1 -0.46 -3 0.59a9.7 9.7 0 0 1 0.36 -1.66 0.65 0.65 0 0 0 -0.28 -0.72c-0.12 -0.07 -1.78 -0.82 -1.79 -0.8 0.32 -0.08 1.14 0 1.61 -0.11 0.16 0 0.58 0 0.82 -0.21S4.66 4 4.84 4.05s0.19 0.16 0.89 1.56a0.34 0.34 0 0 0 0.61 -0.3L5.7 3.92C5.32 3.15 4.62 3 4 3.78L3 5.46a1.73 1.73 0 0 0 -0.36 0C1.49 5.62 0.1 5.47 0 6.45c-0.07 0.77 1.17 1.38 1.87 1.73Z';

  static Path? _p1, _p2, _p3, _p4, _p5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!],
          colors: [blue, blue, dark, dark, dark],
        ),
      ),
    );
  }
}

/// NIDA OTP Key Smartphone Icon (Technology-Otp-Key-Smartphone)
class MfNidaOtpSmartphoneIcon extends StatelessWidget {
  const MfNidaOtpSmartphoneIcon({
    super.key,
    this.size = 24,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M15.432 15.991c-0.32 0.02 -0.638 0.045 -0.957 0.072 -0.423 0.143 -0.505 0.643 -0.597 3.793 -0.068 2.264 -0.217 3.265 0.211 3.715 0.383 0.401 1.226 0.363 3 0.392a31.716 31.716 0 0 0 6.51 -0.357c0.341 -0.342 0.334 -2.133 0.33 -2.957l0 -0.196c0.008 -3.274 -0.013 -4.331 -0.529 -4.25a43.43 43.43 0 0 0 -0.533 -0.06 4.493 4.493 0 0 0 -0.83 -4.43c-2.121 -2.147 -7.171 -1.262 -6.605 4.278Zm0.635 -0.036a43.81 43.81 0 0 1 6.113 0.121l0.002 -0.013 0.005 -0.061c0.13 -1.425 0.232 -2.548 -0.878 -3.54 -1.49 -1.385 -5.232 -0.908 -5.242 3.493Zm-0.966 1.018a52.034 52.034 0 0 1 8.011 -0.244 41.942 41.942 0 0 1 -0.188 6.087 62.043 62.043 0 0 1 -7.545 -0.074 0.765 0.765 0 0 0 -0.1 0c-0.299 0.016 -0.352 0.018 -0.246 -4.184 0.015 -0.6 0.034 -1.155 0.068 -1.585Z';
  static const _path2 =
      'M23.24 9.874c0.248 -7.461 1.056 -9.46 -4.148 -9.713C16.978 0.07 4.312 -0.281 2.177 0.47 0.354 1.118 0.227 3.195 0.158 5.08c-0.322 9.533 0.12 10.714 3.333 11.1 2.821 0.284 5.658 0.384 8.492 0.298a0.412 0.412 0 0 0 0.407 -0.423 0.414 0.414 0 0 0 -0.423 -0.406 65.315 65.315 0 0 1 -8.336 -0.53c-2.151 -0.314 -2.154 -1.056 -2.241 -3.435 -0.09 -2.114 -0.048 -4.416 0.04 -6.533 0.047 -1.187 0.04 -3.048 1.176 -3.436 5.467 -0.45 10.957 -0.572 16.439 -0.365 3.922 0.09 3.383 0.545 3.404 8.547a0.396 0.396 0 0 0 0.79 -0.023Z';
  static const _path3 =
      'M3.599 12.358a4.015 4.015 0 0 1 6.819 0.116 0.415 0.415 0 0 0 0.764 -0.325 4.427 4.427 0 0 0 -8.273 -0.174 0.395 0.395 0 0 0 0.69 0.383Z';
  static const _path4 =
      'M19.1 5.389a0.415 0.415 0 0 0 0.048 -0.83 16.151 16.151 0 0 0 -5.104 -0.296c-0.703 -0.082 -1.517 1.625 5.056 1.126Z';
  static const _path5 =
      'M12.805 8.343c2.47 0.32 4.97 0.329 7.442 0.024a0.415 0.415 0 0 0 0 -0.83 25.97 25.97 0 0 0 -7.458 0.019 0.394 0.394 0 0 0 0.016 0.787Z';
  static const _path6 =
      'M16.883 19.396c0.313 0.475 0.579 0.98 0.792 1.507a0.622 0.622 0 0 0 0.816 0.276 0.624 0.624 0 0 0 0.242 -0.2c1.057 -1.44 3.171 -2.378 2.796 -3.013 -0.405 -0.671 -2.577 0.854 -3.277 1.623 -1.359 -1.564 -1.681 -0.507 -1.37 -0.193Z';
  static const _path7 =
      'M7.117 4.18c-0.618 0 -1.22 0.192 -1.725 0.549a3.082 3.082 0 0 0 2.94 5.336 3.513 3.513 0 0 0 1.9 -2.58c0.104 -0.55 0.026 -1.12 -0.223 -1.623C9.52 4.875 8.197 4.18 7.117 4.18Zm1.97 2.055c0.13 0.337 0.149 0.706 0.053 1.055a2.31 2.31 0 0 1 -1.282 1.612 1.964 1.964 0 0 1 -1.905 -0.492 1.969 1.969 0 0 1 1.124 -3.268c0.85 -0.145 1.697 0.28 2.01 1.093Z';

  static Path? _p1, _p2, _p3, _p4, _p5, _p6, _p7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);
    _p6 ??= SvgPathParser.parse(_path6);
    _p7 ??= SvgPathParser.parse(_path7);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!, _p6!, _p7!],
          colors: [dark, blue, dark, blue, blue, blue, dark],
        ),
      ),
    );
  }
}

/// Bird House Icon (Bird-House)
class MfBirdHouseIcon extends StatelessWidget {
  const MfBirdHouseIcon({
    super.key,
    this.size = 24,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M22.46 9.28A7.7 7.7 0 0 0 20.73 7l-3 -3.09a12.39 12.39 0 0 0 -1.12 -0.94c-0.57 -0.43 -1.16 -0.83 -1.73 -1.25s-1 -0.78 -1.5 -1.15c-0.23 -0.16 -0.46 -0.32 -0.7 -0.47a0.33 0.33 0 0 0 -0.45 0.1s0 0.05 0 0.08l0 -0.12a0.28 0.28 0 0 0 -0.4 0c-1.17 0.78 -2.25 1.68 -3.31 2.6S6.41 4.63 5.39 5.6A31.54 31.54 0 0 0 3 8.09a11.05 11.05 0 0 0 -1.34 2 2.75 2.75 0 0 0 -0.3 0.89 1.64 1.64 0 0 0 0.07 0.73 2 2 0 0 0 1.22 1.19 2 2 0 0 0 1.73 -0.08 4.26 4.26 0 0 0 0.62 -0.49A14 14 0 0 0 5.29 14c0.22 1 0.52 2 0.81 3l0.22 1c0 0.09 0 0.36 0.09 0.48a0.51 0.51 0 0 0 0.14 0.21 1.53 1.53 0 0 0 0.68 0.36 6.28 6.28 0 0 0 1.34 0.18l1 0a7.07 7.07 0 0 0 -0.23 1.52 6.07 6.07 0 0 0 0.07 1.13c0.08 0.56 0.22 1.09 0.31 1.65a0.32 0.32 0 0 0 0.34 0.3 0.32 0.32 0 0 0 0.31 -0.34c0 -0.55 0.07 -1.09 0.08 -1.63l0 -0.69c0 -0.23 0 -0.45 -0.05 -0.68 0 -0.42 -0.1 -0.82 -0.14 -1.24h0.07c0.77 0 1.55 -0.06 2.32 -0.11 -0.06 0.39 -0.12 0.78 -0.15 1.17a6.79 6.79 0 0 0 0 0.78l0 0.78c0 0.61 0.12 1.2 0.18 1.81a0.33 0.33 0 0 0 0.66 0c0.06 -0.6 0.14 -1.2 0.19 -1.8l0 -0.78a6.77 6.77 0 0 0 0 -0.78c0 -0.41 -0.08 -0.82 -0.14 -1.23l2.31 -0.14a4.41 4.41 0 0 0 0.89 -0.1 1.34 1.34 0 0 0 0.5 -0.29 2.67 2.67 0 0 0 0.69 -1.15c0.17 -0.54 0.21 -1.14 0.33 -1.68l0.66 -2.67 0.23 -1.48a4.29 4.29 0 0 0 2 0.67 1.46 1.46 0 0 0 1.29 -0.77 2.45 2.45 0 0 0 0.17 -2.2Zm-4.37 3.6 -0.79 2.63c-0.13 0.51 -0.2 1.08 -0.38 1.58a1.68 1.68 0 0 1 -0.47 0.73 0.37 0.37 0 0 1 -0.23 0.07h-0.57l-2.72 0.11q-1.08 0.07 -2.16 0.12l-2.14 0a7.47 7.47 0 0 1 -1 0c-0.58 -0.1 -0.34 -0.11 -0.4 -0.34l-0.31 -1c-0.33 -0.93 -0.69 -1.89 -1 -2.87a11.91 11.91 0 0 1 -0.39 -1.94s0 -0.06 0 -0.1c0.29 -0.33 0.57 -0.69 0.84 -1l2.1 -2.5c0.79 -0.88 1.66 -1.68 2.49 -2.52q0.47 -0.48 0.9 -1 0.39 0.48 0.81 0.93c0.48 0.52 1 1 1.45 1.54a35.73 35.73 0 0 0 2.51 2.56 13.65 13.65 0 0 0 1.81 1.37Zm3.3 -1.94c-0.19 0.32 -0.54 0.25 -0.88 0.15a7.28 7.28 0 0 1 -1.42 -0.67 13.27 13.27 0 0 1 -1.88 -1.29c-0.9 -0.73 -1.73 -1.55 -2.59 -2.38L13.1 5.29c-0.33 -0.33 -0.65 -0.66 -0.95 -1a0.35 0.35 0 0 0 -0.2 -0.1 0.34 0.34 0 0 0 -0.46 0c-0.33 0.37 -0.69 0.72 -1.05 1.07 -0.86 0.82 -1.78 1.59 -2.6 2.45l-2.23 2.47c-0.33 0.38 -0.66 0.8 -1 1.16a2.93 2.93 0 0 1 -0.72 0.55 1 1 0 0 1 -0.81 0 1 1 0 0 1 -0.59 -0.56 0.58 0.58 0 0 1 0 -0.32 1.92 1.92 0 0 1 0.17 -0.44 11.49 11.49 0 0 1 1.17 -1.79 32 32 0 0 1 2.25 -2.49c1 -1 1.94 -2 2.95 -3s2.05 -1.9 3.1 -2.82a0.53 0.53 0 0 0 0.06 -0.1 0.35 0.35 0 0 0 0.13 0.19 7.36 7.36 0 0 1 0.63 0.47c0.5 0.38 1 0.81 1.47 1.2s1.11 0.86 1.66 1.31a12.38 12.38 0 0 1 1 0.91L20 7.7a6.49 6.49 0 0 1 1.46 2 1.46 1.46 0 0 1 -0.07 1.24Z';
  static const _path2 =
      'M14.2 9.45a4.41 4.41 0 0 0 -4.1 -0.08 3.82 3.82 0 0 0 -1.67 1.93 3.76 3.76 0 0 0 0.07 2.78A3.31 3.31 0 0 0 10.61 16a3.8 3.8 0 0 0 2.63 -0.28 4.26 4.26 0 0 0 1.87 -1.79 3.92 3.92 0 0 0 0.36 -2.39 3 3 0 0 0 -1.27 -2.09Zm0.05 4a3.33 3.33 0 0 1 -1.47 1.28 2.7 2.7 0 0 1 -1.87 0.2 2.3 2.3 0 0 1 -1.46 -1.28 2.83 2.83 0 0 1 -0.18 -2 2.89 2.89 0 0 1 1.2 -1.65 3.42 3.42 0 0 1 3.31 0.07 2.22 2.22 0 0 1 0.84 1.58 3 3 0 0 1 -0.37 1.79Z';

  static Path? _p1, _p2;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!],
          colors: [blue, dark],
        ),
      ),
    );
  }
}

/// Plugin Hands Puzzle Icon (Plugin-Hands-Puzzle)
class MfPluginHandsPuzzleIcon extends StatelessWidget {
  const MfPluginHandsPuzzleIcon({
    super.key,
    this.size = 24,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M16 12.06c0 -0.39 -0.26 -0.53 -0.37 -0.73 -0.24 -0.46 -0.77 -0.89 -0.62 -1.24 0.24 -0.53 1 -0.64 1.57 -0.5a10.88 10.88 0 0 0 1.23 0.48c0.37 0.06 0.66 -0.31 1 -0.72a5.23 5.23 0 0 0 1.06 -1.81 0.56 0.56 0 0 0 -0.08 -0.33 9.4 9.4 0 0 0 -2.09 -1.65s-0.14 -0.14 -0.24 -0.21a3.61 3.61 0 0 0 0.42 -1.74 2.38 2.38 0 0 0 -4 -1.48c-0.51 0.57 0.34 0.87 0.41 0.38l0.32 -0.25a1.76 1.76 0 0 1 2.59 1.66 3.92 3.92 0 0 1 -0.48 1.29c-0.39 0.8 0.49 0.66 2.3 2.36a6 6 0 0 1 -1.17 1.51l-1 -0.42a2.31 2.31 0 0 0 -2.76 1c-0.46 1 0.28 1.53 0.62 2.18 0.22 0.44 0.35 0.14 0 0.82a7.15 7.15 0 0 1 -1 1.48c-1 -0.32 -6.5 -3.23 -7.16 -4.34a5.59 5.59 0 0 1 1 -2c1.13 0.6 1.81 1.11 2.84 0.52 2.1 -1.22 1.42 -3.62 -0.95 -4a8.62 8.62 0 0 1 1 -1.72c0.25 -0.27 1.26 0.23 1.56 0.38a0.32 0.32 0 0 0 0.29 -0.58C10.06 1.2 10 1.84 8.77 4c-0.16 0.28 -0.36 0.59 -0.13 0.87s0.92 0.21 1.18 0.3c0.7 0.25 1.28 0.94 0.92 1.59 -0.24 0.42 -0.83 0.94 -1.32 0.87 -2 -0.85 -1.89 -1.5 -2.8 -0.17a4.86 4.86 0 0 0 -1 2.37c0 1.79 7.75 5.39 8.25 5.41 0.88 0.05 2.13 -2.62 2.13 -3.18Z';
  static const _path2 =
      'M8.71 19.57c-0.32 -1.39 0.26 -5.08 -1.38 -5.05 -1.46 0 -1.18 1.19 -1.7 2.6 -0.14 0.39 -0.12 0.43 -1 -0.38a3.45 3.45 0 0 1 -0.45 -0.56c0.08 -0.39 -0.08 -0.1 0.22 -2.6 0.11 -0.89 0.07 -1.93 -0.72 -2.35a1.3 1.3 0 0 0 -1.55 0.22A1.09 1.09 0 0 0 1.06 11C0 11.12 0 12.34 0 13.37c0.06 2.74 2.2 5.68 4.24 7.51l0.62 1.58c0.09 0.27 0.67 -0.05 0.57 -0.32L5 20.47c0 -0.13 -4.23 -3.48 -4.19 -7.11 0 -0.41 0 -1.52 0.38 -1.56 0.58 -0.06 0.47 0.46 1.27 2.55a12.47 12.47 0 0 0 1.09 2.25 4.34 4.34 0 0 0 1.78 1.5c1.25 0.23 1.08 -1.82 1.46 -2.4 0.09 -0.15 0.26 -0.22 0.54 -0.23 1 0 0.22 4.36 0.88 4.65 0.23 0.11 0.69 -0.21 0.54 -0.41 0.02 -0.02 -0.03 -0.08 -0.04 -0.14Zm-6.3 -7.65a0.71 0.71 0 0 1 0.95 -0.1c0.4 0.27 0.31 1.25 0.27 1.8a6.89 6.89 0 0 0 0.05 1.61 33 33 0 0 1 -1.27 -3.31Z';
  static const _path3 =
      'M15.25 19.71c-0.15 0.2 0.31 0.52 0.54 0.41 0.66 -0.29 -0.09 -4.69 0.88 -4.65 0.28 0 0.45 0.08 0.54 0.23 0.38 0.58 0.21 2.63 1.46 2.4a4.34 4.34 0 0 0 1.78 -1.5 12.47 12.47 0 0 0 1.13 -2.25c0.8 -2.09 0.69 -2.61 1.27 -2.55 0.41 0 0.38 1.15 0.38 1.56 0 3.63 -4.14 7 -4.19 7.11l-0.47 1.67c-0.1 0.27 0.48 0.59 0.57 0.32l0.62 -1.58c2 -1.83 4.18 -4.77 4.24 -7.51 0 -1 0 -2.25 -1.06 -2.37a1.09 1.09 0 0 0 -1.1 0.45 1.3 1.3 0 0 0 -1.55 -0.22c-0.79 0.42 -0.83 1.46 -0.72 2.35 0.31 2.6 0.14 2.23 0.22 2.6a3.45 3.45 0 0 1 -0.45 0.56c-0.85 0.81 -0.83 0.77 -1 0.38 -0.52 -1.41 -0.24 -2.58 -1.7 -2.6 -1.65 0 -1.06 3.66 -1.38 5.05 0.02 0.06 -0.03 0.12 -0.01 0.14Zm5.07 -4.48a6.89 6.89 0 0 0 0.05 -1.61c0 -0.55 -0.13 -1.53 0.27 -1.8a0.71 0.71 0 0 1 0.95 0.1 33 33 0 0 1 -1.27 3.31Z';

  static Path? _p1, _p2, _p3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!],
          colors: [dark, blue, blue],
        ),
      ),
    );
  }
}

/// Performance Increase Clipboard Icon (Performance-Increase-Clipboard)
class MfPerformanceClipboardIcon extends StatelessWidget {
  const MfPerformanceClipboardIcon({
    super.key,
    this.size = 24,
    this.primaryColor,
    this.secondaryColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  static const _path1 =
      'M15.6 2c0.08 0.41 0.06 0.78 0.45 0.79s0.35 -0.29 0.56 -0.78c0.72 -0.13 1 -0.07 1 -0.42s-0.3 -0.44 -0.87 -0.64c-0.17 -0.86 -0.25 -1 -0.48 -1s-0.28 0.15 -0.62 0.83c-1.06 0.17 -1.15 0.28 -1.18 0.49s-0.05 0.43 1.14 0.73Z';
  static const _path2 =
      'M21.53 13.9c-0.2 -0.51 -0.21 -0.89 -0.57 -0.85s-0.26 0.28 -0.42 0.91l-0.09 0c-1.45 0.4 -1.38 0.58 -1.37 0.73s0.18 0.38 1.43 0.47c0.33 1.42 0.62 1.31 0.75 1.3s0.39 -0.16 0.47 -1.41V15c1 -0.29 1.24 -0.28 1.23 -0.65s-0.13 -0.35 -1.43 -0.45Z';
  static const _path3 =
      'M5.19 8a3.13 3.13 0 0 0 -0.89 0.18 0.89 0.89 0 0 0 -0.51 0.65 8.06 8.06 0 0 0 -0.12 1.45c0 1.06 -0.07 2.12 -0.06 3.19 0 0.72 0 1.44 0.09 2.15 0.07 1 0 3.4 0.06 4.44a3.91 3.91 0 0 0 0 0.53 0.62 0.62 0 0 0 0.37 0.52 6.81 6.81 0 0 0 1.64 0.15c1.71 0 4.49 -0.06 5.59 -0.09l2.95 -0.14s0.58 0 0.79 -0.05a0.51 0.51 0 0 0 0.46 -0.44 9.41 9.41 0 0 0 0 -1c-0.06 -0.78 -0.19 -1.66 -0.27 -2.24a0.38 0.38 0 0 0 -0.42 -0.34 0.39 0.39 0 0 0 -0.34 0.43c0 0.49 0.13 1.21 0.17 1.9l0 0.75 -0.41 0.09 -2.93 0c-0.84 0 -2.62 0 -4.17 -0.06 -0.91 0 -1.73 0 -2.18 -0.06 0 -1.07 0 -3.51 -0.06 -4.5 -0.06 -0.69 -0.08 -1.38 -0.1 -2.07l0 -3.17C4.83 8.81 4 9.22 7.1 8.94l6.12 -0.4a0.34 0.34 0 0 0 -0.05 -0.68L7 8 5.19 8Z';
  static const _path4 =
      'M2.39 10.79c0 -1.43 0.12 -2.85 0.27 -4.27l0.12 0a9.13 9.13 0 0 1 1.59 -0.14c0.35 0 0.71 0 1.07 -0.06C8.11 6 7 6.37 7.9 5.13a2 2 0 0 1 0.47 -0.5 2.18 2.18 0 0 1 0.68 -0.39 1.13 1.13 0 0 1 0.92 0 3 3 0 0 1 1.33 1.7 0.38 0.38 0 0 0 0.47 0.27 0.39 0.39 0 0 0 0.23 -0.47A3.47 3.47 0 0 0 10 3a2.06 2.06 0 0 0 -1.64 0.21 2.94 2.94 0 0 0 -0.76 0.64 3 3 0 0 0 -0.51 0.89 5.76 5.76 0 0 0 -0.18 0.59 8 8 0 0 0 -1.24 -0.22 4.45 4.45 0 0 0 -0.73 0 5.73 5.73 0 0 0 -0.74 0.11c-2.25 0.52 -2.52 0 -3 6.35 -0.07 0.81 -0.1 1.62 -0.1 2.43l0 2.42c0.11 1.88 0.31 3.75 0.54 5.62a0.38 0.38 0 0 0 0.42 0.35 0.4 0.4 0 0 0 0.35 -0.41c-0.1 -2.23 -0.1 -4.46 -0.07 -6.7l0 -2.66c0.04 -0.62 0.04 -1.24 0.05 -1.83Z';
  static const _path5 =
      'M17.54 14.15a0.34 0.34 0 0 0 -0.4 -0.27 0.35 0.35 0 0 0 -0.27 0.4 25.38 25.38 0 0 1 0.05 3.27c0 0.72 0 1.44 -0.05 2.15a13.28 13.28 0 0 1 -0.29 2.3 0.4 0.4 0 0 0 0.25 0.49 0.39 0.39 0 0 0 0.48 -0.25 12.13 12.13 0 0 0 0.79 -2.8 8.41 8.41 0 0 0 0.11 -1.24 10.34 10.34 0 0 0 0 -1.24 17 17 0 0 0 -0.67 -2.81Z';
  static const _path6 =
      'M16.16 22.47a12.3 12.3 0 0 1 -2.38 0.26c-1.23 0 -2.49 0 -3.67 -0.05 -0.61 0 -1.21 0 -1.81 0.07 -0.9 0.05 -1.8 0.14 -2.7 0.17l-1.92 0a0.34 0.34 0 0 0 -0.38 0.3 0.35 0.35 0 0 0 0.3 0.37 28.08 28.08 0 0 0 3.28 0.35c0.44 0 0.87 0 1.31 0.06l1.94 0c1.21 -0.06 2.48 -0.08 3.74 -0.23a13.78 13.78 0 0 0 2.49 -0.53 0.39 0.39 0 0 0 0.27 -0.48 0.39 0.39 0 0 0 -0.47 -0.29Z';
  static const _path7 =
      'M19.44 10.67c0.06 0 0.1 0.14 0.17 0.21a1.17 1.17 0 0 0 0.27 0.21 0.62 0.62 0 0 0 0.42 0 0.64 0.64 0 0 0 0.41 -0.33 1.7 1.7 0 0 0 0.2 -0.7 9.39 9.39 0 0 0 0 -1.2c0 -0.47 0 -0.94 -0.11 -1.4 -0.14 -1.08 -0.38 -2.13 -0.58 -3.2a0.38 0.38 0 0 0 -0.44 -0.26 0.37 0.37 0 0 0 -0.31 0.33c-0.93 0.22 -1.88 0.29 -2.83 0.44 -0.44 0.08 -0.88 0.18 -1.3 0.29a5.18 5.18 0 0 0 -1.21 0.49 1 1 0 0 0 -0.43 0.45 0.54 0.54 0 0 0 0.13 0.54l0.3 0.23 1 0.76s-0.08 0 -0.1 0.08c-0.5 0.78 -1 1.57 -1.5 2.34 -0.34 0.5 -0.69 1 -1.06 1.47 0 0 -0.23 0.47 -0.44 0.76 -0.37 -0.25 -0.73 -0.52 -1.11 -0.77a6.61 6.61 0 0 0 -0.69 -0.41 6.66 6.66 0 0 0 -0.76 -0.38 0.74 0.74 0 0 0 -0.58 0 2 2 0 0 0 -0.57 0.51c-0.27 0.34 -0.5 0.8 -0.7 1.07l-2.31 3.47a0.34 0.34 0 0 0 0.08 0.47 0.35 0.35 0 0 0 0.48 -0.08q0.48 -0.64 1 -1.26c0.55 -0.62 1.13 -1.22 1.66 -1.8 0.19 -0.21 0.42 -0.55 0.66 -0.85l0.17 -0.18c0.13 0.09 0.27 0.22 0.3 0.24l2.05 1.32a0.75 0.75 0 0 0 0.91 -0.21 12.32 12.32 0 0 0 0.83 -1.15c0.34 -0.53 0.67 -1.07 1 -1.63 0.46 -0.82 0.87 -1.65 1.31 -2.47a0.4 0.4 0 0 0 0 -0.32l0.08 0a0.34 0.34 0 0 0 0 -0.48l-0.73 -0.82c0.23 -0.06 0.46 -0.1 0.57 -0.12 0.68 -0.2 1.38 -0.35 2.08 -0.54a14.73 14.73 0 0 0 1.73 -0.6l0.13 3.8 0 0.67a2.36 2.36 0 0 1 -0.36 -0.26 4.59 4.59 0 0 1 -0.64 -0.61 0.32 0.32 0 0 0 -0.46 -0.08 0.31 0.31 0 0 0 -0.1 0.4c-0.89 1.14 -1.79 2.29 -2.73 3.4 -0.62 0.73 -1.25 1.44 -1.93 2.12 -1.83 1.78 -0.79 1.27 -2.73 0.28a4.6 4.6 0 0 0 -0.73 -0.29 0.63 0.63 0 0 0 -0.54 0.11 19.76 19.76 0 0 0 -1.72 1.6c-0.79 0.84 -1.54 1.73 -2.31 2.56a0.34 0.34 0 0 0 0 0.48 0.36 0.36 0 0 0 0.49 0c0.82 -0.76 1.64 -1.57 2.51 -2.33a17 17 0 0 1 1.41 -1.13c0.11 0.05 0.28 0.08 0.3 0.1 0.39 0.22 0.8 0.57 1.21 0.84a3 3 0 0 0 0.72 0.35 0.75 0.75 0 0 0 0.5 0 4.35 4.35 0 0 0 0.56 -0.4l1.26 -1.27c0.66 -0.74 1.27 -1.52 1.86 -2.31 0.81 -1.11 1.57 -2.26 2.34 -3.4 0.06 0.07 0.1 0.15 0.16 0.22a6.29 6.29 0 0 0 0.75 0.63Z';

  static Path? _p1, _p2, _p3, _p4, _p5, _p6, _p7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = primaryColor ?? (isDark ? MfColors.primarySoft : MfColors.primary);
    final dark = secondaryColor ?? (isDark ? Colors.white70 : MfColors.ink);

    _p1 ??= SvgPathParser.parse(_path1);
    _p2 ??= SvgPathParser.parse(_path2);
    _p3 ??= SvgPathParser.parse(_path3);
    _p4 ??= SvgPathParser.parse(_path4);
    _p5 ??= SvgPathParser.parse(_path5);
    _p6 ??= SvgPathParser.parse(_path6);
    _p7 ??= SvgPathParser.parse(_path7);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiPathPainter(
          paths: [_p1!, _p2!, _p3!, _p4!, _p5!, _p6!, _p7!],
          colors: [blue, blue, blue, blue, blue, blue, dark],
        ),
      ),
    );
  }
}
