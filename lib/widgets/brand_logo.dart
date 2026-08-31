import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

/// Renders the official MchongoFasta electric bolt brand emblem natively.
class MfBrandIcon extends StatelessWidget {
  const MfBrandIcon({
    super.key,
    this.size = 22,
    this.color = Colors.white,
    this.accentColor,
  });

  final double size;
  final Color color;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * (1005 / 1407),
      height: size,
      child: CustomPaint(
        painter: _MfBrandIconPainter(
          primaryColor: color,
          accentColor: accentColor ?? color.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

/// Brand logo badge in rounded square container
class MfBrandBadge extends StatelessWidget {
  const MfBrandBadge({
    super.key,
    this.size = 36,
    this.borderRadius = 12,
    this.backgroundColor = MfColors.primary,
    this.iconColor = Colors.white,
  });

  final double size;
  final double borderRadius;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: MfBrandIcon(
          size: size * 0.58,
          color: iconColor,
        ),
      ),
    );
  }
}

class _MfBrandIconPainter extends CustomPainter {
  _MfBrandIconPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  final Color primaryColor;
  final Color accentColor;

  static Path? _cachedPath1;
  static Path? _cachedPath2;
  static Path? _cachedPath3;

  @override
  void paint(Canvas canvas, Size size) {
    const origWidth = 1005.0;
    const origHeight = 1407.0;

    final scaleX = size.width / origWidth;
    final scaleY = size.height / origHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Center in bounds
    final dx = (size.width - origWidth * scale) / 2;
    final dy = (size.height - origHeight * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final paintMain = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final paintAccent = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    _cachedPath1 ??= _buildMainBoltPath();
    _cachedPath2 ??= _buildLeftBoltPath();
    _cachedPath3 ??= _buildBottomAccentPath();

    canvas.drawPath(_cachedPath1!, paintMain);
    canvas.drawPath(_cachedPath2!, paintAccent);
    canvas.drawPath(_cachedPath3!, paintAccent);

    canvas.restore();
  }

  Path _buildMainBoltPath() {
    final p = Path();
    p.moveTo(292.945, 721.123);
    p.cubicTo(297.247, 711.333, 300.886, 699.042, 304.586, 688.675);
    p.lineTo(331.756, 610.933);
    p.lineTo(442.367, 295.127);
    p.lineTo(489.78, 159.03);
    p.cubicTo(495.738, 141.318, 501.816, 123.646, 508.015, 106.016);
    p.cubicTo(510.621, 98.6398, 513.246, 91.2682, 515.952, 83.9316);
    p.cubicTo(516.472, 81.6913, 519.686, 79.082, 521.964, 79.0785);
    p.cubicTo(535.794, 79.0545, 549.593, 79.3609, 563.408, 78.4829);
    p.cubicTo(567.81, 78.2033, 572.394, 78.2363, 576.818, 78.2115);
    p.cubicTo(626.31, 78.1964, 675.799, 77.473, 725.268, 76.0426);
    p.cubicTo(749.297, 75.4477, 773.299, 74.1321, 797.411, 74.7792);
    p.cubicTo(803.387, 74.94, 816.934, 73.9789, 822.127, 75.1894);
    p.lineTo(822.244, 76.257);
    p.cubicTo(820.726, 76.0763, 821.193, 75.9849, 819.771, 76.3099);
    p.cubicTo(815.745, 84.4427, 813.121, 93.0221, 809.164, 101.062);
    p.cubicTo(800.468, 118.699, 792.451, 136.624, 784.139, 154.391);
    p.lineTo(696.78, 340.205);
    p.lineTo(660.129, 417.957);
    p.cubicTo(656.427, 425.617, 641.362, 454.709, 640.107, 460.478);
    p.cubicTo(643.013, 462.779, 706.707, 454.55, 718.206, 453.364);
    p.lineTo(851.068, 439.282);
    p.cubicTo(862.691, 437.97, 874.026, 436.545, 885.745, 435.74);
    p.cubicTo(890.135, 435.438, 896.049, 433.206, 900.397, 433.866);
    p.lineTo(900.762, 434.597);
    p.cubicTo(893.507, 445.511, 886.617, 457.569, 879.775, 468.846);
    p.lineTo(842.275, 530.643);
    p.lineTo(741.349, 696.342);
    p.lineTo(485.585, 1116.48);
    p.lineTo(430.869, 1205.59);
    p.cubicTo(418.236, 1226.41, 400.836, 1257.42, 386.474, 1278.31);
    p.cubicTo(386.919, 1277.66, 384.176, 1280.45, 384.536, 1280.09);
    p.cubicTo(385.758, 1284.99, 351.527, 1332.65, 348.431, 1343.41);
    p.lineTo(347.702, 1343.88);
    p.cubicTo(346.967, 1342.38, 347.303, 1339.77, 347.844, 1338.22);
    p.cubicTo(350.802, 1330.65, 354.413, 1310.74, 356.181, 1302.23);
    p.cubicTo(359.194, 1287.74, 362.519, 1273.34, 365.66, 1258.87);
    p.lineTo(406.736, 1068.63);
    p.lineTo(464.603, 801.64);
    p.lineTo(481.708, 722.318);
    p.cubicTo(483.702, 712.7, 487.684, 695.889, 488.784, 686.607);
    p.lineTo(390.215, 703.075);
    p.cubicTo(383.912, 704.181, 377.516, 705.857, 371.258, 706.901);
    p.lineTo(315.824, 716.616);
    p.cubicTo(308.031, 718.052, 300.569, 718.787, 292.945, 721.123);
    p.close();
    return p;
  }

  Path _buildLeftBoltPath() {
    final p = Path();
    p.moveTo(440.64, 205.318);
    p.cubicTo(439.859, 208.672, 438.256, 213.692, 438.725, 216.849);
    p.cubicTo(437.622, 222.103, 433.064, 228.485, 430.973, 233.993);
    p.cubicTo(426.739, 245.145, 424.157, 257.513, 418.466, 268.09);
    p.cubicTo(416.592, 271.571, 415.141, 273.162, 413.629, 277.084);
    p.lineTo(384.751, 353.022);
    p.cubicTo(377.593, 372.063, 370.293, 391.003, 362.683, 409.86);
    p.cubicTo(360.332, 415.684, 357.923, 421.499, 355.563, 427.319);
    p.cubicTo(354.738, 429.392, 356.177, 431.36, 354.16, 434.693);
    p.lineTo(353.473, 432.449);
    p.lineTo(353.729, 432.637);
    p.cubicTo(352.579, 433.783, 349.769, 442.945, 349.16, 444.947);
    p.cubicTo(343.302, 464.186, 332.389, 483.103, 326.568, 502.195);
    p.lineTo(326.848, 501.916);
    p.cubicTo(324.516, 508.653, 321.776, 514.669, 319.344, 521.197);
    p.cubicTo(315.588, 531.276, 314.515, 538.56, 308.597, 547.929);
    p.cubicTo(306.439, 551.345, 302.536, 562.375, 301.57, 566.436);
    p.cubicTo(300.293, 571.807, 298.436, 575.893, 296.223, 580.862);
    p.lineTo(296.229, 580.516);
    p.lineTo(246.789, 708.591);
    p.cubicTo(244.878, 713.441, 242.231, 715.839, 240.368, 720.861);
    p.cubicTo(234.026, 737.947, 230.099, 755.308, 222.189, 771.796);
    p.cubicTo(223.601, 771.61, 223.337, 771.136, 224.63, 770.188);
    p.cubicTo(225.178, 770.415, 225.727, 770.635, 226.275, 770.862);
    p.cubicTo(236.926, 769.769, 252.248, 766.705, 262.19, 764.837);
    p.lineTo(320.124, 753.776);
    p.lineTo(371.528, 744.467);
    p.cubicTo(381.056, 742.694, 393.449, 740.764, 402.4, 737.72);
    p.cubicTo(401.91, 746.061, 400.214, 753.487, 399.471, 761.601);
    p.cubicTo(398.847, 768.423, 399.299, 775.822, 398.882, 782.871);
    p.lineTo(398.412, 782.932);
    p.cubicTo(398.219, 780.775, 398.006, 778.618, 397.772, 776.461);
    p.lineTo(397.582, 776.337);
    p.cubicTo(395.162, 779.133, 396.153, 798.967, 395.044, 804.463);
    p.lineTo(394.036, 802.883);
    p.cubicTo(391.577, 809.163, 393.443, 817.888, 392.639, 824.476);
    p.cubicTo(391.779, 831.532, 390.223, 838.573, 389.296, 845.629);
    p.cubicTo(387.178, 857.549, 386.711, 866.336, 386.176, 878.372);
    p.lineTo(385.335, 875.761);
    p.lineTo(384.831, 875.679);
    p.cubicTo(382.455, 887.551, 384.145, 896.667, 382.166, 905.866);
    p.lineTo(382.205, 899.216);
    p.cubicTo(381.299, 903.963, 379.176, 931.437, 378.804, 931.938);
    p.cubicTo(378.348, 929.843, 378.209, 929.623, 378.593, 927.569);
    p.cubicTo(374.443, 938.472, 379.619, 947.286, 375.132, 958.732);
    p.lineTo(374.54, 958.691);
    p.lineTo(374.027, 956.685);
    p.cubicTo(373.471, 962.799, 374.939, 975.818, 373.17, 979.679);
    p.lineTo(372.236, 978.003);
    p.cubicTo(369.113, 985.223, 371.642, 992.279, 370.562, 998.331);
    p.cubicTo(368.566, 1009.52, 365.959, 1020.76, 364.596, 1032.15);
    p.cubicTo(363.649, 1040.07, 364.321, 1048.77, 363.149, 1056.6);
    p.cubicTo(362.015, 1055.76, 362.276, 1055.7, 361.655, 1054.2);
    p.cubicTo(361.419, 1058.88, 361.392, 1066.07, 360.652, 1070.47);
    p.cubicTo(356.727, 1093.81, 356.351, 1117.67, 351.415, 1140.89);
    p.cubicTo(350.682, 1144.33, 350.894, 1147.82, 349.933, 1151.45);
    p.lineTo(347.47, 1150.73);
    p.cubicTo(347.12, 1127.67, 349.925, 1104.78, 350.064, 1081.95);
    p.cubicTo(350.386, 1028.76, 355.526, 975.048, 354.983, 921.874);
    p.lineTo(355.754, 922.966);
    p.cubicTo(356.198, 922.197, 357.677, 866.789, 357.418, 862.646);
    p.cubicTo(356.703, 851.201, 362.728, 777.361, 359.871, 771.59);
    p.cubicTo(356.048, 771.645, 338.327, 775.327, 333.976, 776.241);
    p.lineTo(336.236, 776.138);
    p.cubicTo(333.103, 777.086, 322.052, 778.604, 317.779, 779.429);
    p.lineTo(318.929, 779.394);
    p.lineTo(166.789, 807.418);
    p.cubicTo(170.792, 800.808, 176.119, 788.133, 179.491, 780.706);
    p.lineTo(200.627, 733.873);
    p.lineTo(252.41, 619.949);
    p.lineTo(440.64, 205.318);
    p.close();
    return p;
  }

  Path _buildBottomAccentPath() {
    final p = Path();
    p.moveTo(384.54, 1280.09);
    p.cubicTo(385.762, 1284.99, 351.531, 1332.65, 348.434, 1343.41);
    p.lineTo(347.705, 1343.88);
    p.cubicTo(346.97, 1342.38, 347.306, 1339.77, 347.847, 1338.22);
    p.cubicTo(350.562, 1335.89, 353.51, 1329.83, 355.536, 1327.02);
    p.cubicTo(362.44, 1317.5, 377.549, 1287.49, 384.54, 1280.09);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
