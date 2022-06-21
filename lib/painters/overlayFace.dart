import 'package:flutter/material.dart';
import '../utils/classes.dart';

class FaceOverlayPainter extends CustomPainter {

  final CubeColor colorCenter;

  FaceOverlayPainter(this.colorCenter);

  @override
  void paint(Canvas canvas, Size size) {
    final dimW = size.width / 3;
    final dimH = size.height / 3;

    final V1s = Offset(dimW, 0);
    final V1e = Offset(dimW, size.height);

    final V2s = Offset(dimW * 2, 0);
    final V2e = Offset(dimW * 2, size.height);

    final H1s = Offset(0, dimH);
    final H1e = Offset(size.width, dimH);

    final H2s = Offset(0, dimH * 2);
    final H2e = Offset(size.width, dimH * 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black;
    
    List<CubeColor> corners = COLORS_CORNER[colorCenter]!;
    
    final paintT = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = corners[0].getTrueColor();

    final paintR = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = corners[1].getTrueColor();

    final paintB = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = corners[2].getTrueColor();

    final paintL = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = corners[3].getTrueColor();


    // draw border
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paintT);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paintR);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paintB);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paintL);

    canvas.drawLine(V1s, V1e, paint);
    canvas.drawLine(V2s, V2e, paint);

    canvas.drawLine(H1s, H1e, paint);
    canvas.drawLine(H2s, H2e, paint);
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) => false;
}
