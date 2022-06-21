import 'package:flutter/material.dart';
import '../utils/classes.dart';

class CubePreviewPainter extends CustomPainter {

  final Cube mycube;

  CubePreviewPainter(this.mycube);

  void drawFace(Canvas canvas, Size sz, Offset of, Face fc) {
    double pieceH = sz.height / 3;
    double pieceW = sz.width / 3;
    Size pieceSize = Size(pieceW, pieceH);
    final pieces = fc.getPieces();
    
    if (fc.captured) {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final paint = Paint()
            ..style = PaintingStyle.fill
            ..color = pieces[i][j].getTrueColor();
          Offset op = Offset(of.dx + i * pieceW, of.dy + j * pieceH);
          
          canvas.drawRect(op & pieceSize, paint);
          final paintBorder = Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.black
            ..strokeWidth = 3;
          canvas.drawRect(op & pieceSize, paintBorder);
        }
      }
    }
    else {
      final paint = Paint()
              ..style = PaintingStyle.fill
              ..color = Color.fromARGB(255, 200, 200, 200);
              
      
      canvas.drawRect(of & sz, paint);
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          Offset op = Offset(of.dx + i * pieceW, of.dy + j * pieceH);
          if (i == 1 && j == 1) {
            final paint = Paint()
              ..style = PaintingStyle.fill
              ..color = fc.colorCenter.getTrueColor();
            canvas.drawRect(op & pieceSize, paint);
          }
          
          final paintBorder = Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.black
            ..strokeWidth = 3;
          canvas.drawRect(op & pieceSize, paintBorder);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double faceH = size.height / 3;
    double faceW = faceH;
    Size szFace = Size(faceW, faceH);
    
    final left = Offset(0, faceH);
    final front = Offset(faceW, faceH);
    final right = Offset(faceW * 2, faceH);
    final back = Offset(faceW * 3, faceH);
    final top = Offset(faceW, 0);
    final bottom = Offset(faceW, faceH * 2);


    drawFace(canvas, szFace, top, mycube.faces[0]);
    drawFace(canvas, szFace, left, mycube.faces[1]);
    drawFace(canvas, szFace, front, mycube.faces[2]);
    drawFace(canvas, szFace, right, mycube.faces[3]);
    drawFace(canvas, szFace, back, mycube.faces[4]);
    drawFace(canvas, szFace, bottom, mycube.faces[5]);
  }

  @override
  bool shouldRepaint(CubePreviewPainter oldDelegate) => true;
}