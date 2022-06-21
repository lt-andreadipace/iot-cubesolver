import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:io';


import './classes.dart';

int abgrToArgb(int abgr) {
  int r = (abgr >> 16) & 0xFF;
  int b = abgr & 0xFF;
  return (abgr & 0xFF00FF00) | (b << 16) | r;
}

List<List<CubeColor>> getColorName(XFile xf, CubeColor colorCenter) {
  final bytes = File(xf.path).readAsBytesSync();
  final img.Image pixels = img.decodeImage(bytes)!;

  List<List<PieceRGB>> face = [
    [PieceRGB(0, 0, 0), PieceRGB(0, 0, 0), PieceRGB(0, 0, 0)],
    [PieceRGB(0, 0, 0), PieceRGB(0, 0, 0), PieceRGB(0, 0, 0)],
    [PieceRGB(0, 0, 0), PieceRGB(0, 0, 0), PieceRGB(0, 0, 0)]
  ];
  

  CubeColor aaaa = CubeColor("fake", PieceRGB(0, 0, 0), PieceRGB(0, 0, 0));
  List<List<CubeColor>> ONEFACE = [
    [aaaa, aaaa, aaaa],
    [aaaa, aaaa, aaaa],
    [aaaa, aaaa, aaaa],
  ];

  int squareW = (pixels.width / 3).round();
  int squareH = (pixels.height / 3).round();

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      int count = 0;

      for (int pX = i * squareW; pX < (i + 1) * squareW; pX++) {
        for (int pY = j * squareH; pY < (j + 1) * squareH; pY++) {
          int abgr = pixels.getPixelSafe(pX, pY);
          if (abgr == 0) {
            continue;
          }
          int argb = abgrToArgb(abgr);
          Color c = Color(argb);
          face[i][j].R += c.red;
          face[i][j].G += c.green;
          face[i][j].B += c.blue;
          count++;
        }
      }
      if (count > 0) {
        face[i][j].R = (face[i][j].R / count).round();
        face[i][j].G = (face[i][j].G / count).round();
        face[i][j].B = (face[i][j].B / count).round();

        CubeColor res =
            recognizeColor(face[i][j].R, face[i][j].G, face[i][j].B);
        ONEFACE[i][j] = res;
      } else {
        print("no color");
      }
    }
  }
  ONEFACE[1][1] = colorCenter;
  return ONEFACE;
}

CubeColor recognizeColor(int R, int G, int B) {
  int index_min = 0;
  double min = 100000000;
  for (int i = 0; i < COLORS.length; i++) {
    double d = COLORS[i].distance(R, G, B);
    if (d < min) {
      min = d;
      index_min = i;
    }
  }
  return COLORS[index_min];
}