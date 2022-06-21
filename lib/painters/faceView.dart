import 'package:flutter/material.dart';
import '../utils/classes.dart';

class FacePainter extends CustomPainter {
  List<List<CubeColor>> pieces;

  FacePainter(this.pieces);
  

  @override
  void paint(Canvas canvas, Size size) {
    
    final pW = size.width / 3;
    final pH = size.height / 3;
    final pSize = Size(pW, pH);

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = pieces[i][j].getTrueColor();
        Offset op = Offset(pW * i, pH * j);
        canvas.drawRect(op & pSize, paint);
        final paintBorder = Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = 3;
        canvas.drawRect(op & pSize, paintBorder);
      }
    }

  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) => true;
}