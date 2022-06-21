import 'package:flutter/material.dart';
import 'dart:math' as math;

final COLORS = [
  // name, color to compare, color to show
  CubeColor("YELLOW", PieceRGB(255, 160, 0), PieceRGB(255, 255, 51)),
  CubeColor("BLUE", PieceRGB(0, 0, 255), PieceRGB(0, 0, 255)),
  CubeColor("RED", PieceRGB(255, 0, 0), PieceRGB(255, 0, 0)),
  CubeColor("GREEN", PieceRGB(0, 255, 0), PieceRGB(0, 255, 0)),
  CubeColor("ORANGE", PieceRGB(255, 100, 45), PieceRGB(255, 165, 0)),
  CubeColor("WHITE", PieceRGB(200, 200, 200), PieceRGB(255, 255, 255))
];

// top, right, bottom, left
final Map<CubeColor, List<CubeColor>> COLORS_CORNER = {
  COLORS[0]: [COLORS[4], COLORS[3], COLORS[2], COLORS[1]],
  
  COLORS[1]: [COLORS[0], COLORS[2], COLORS[5], COLORS[4]],
  
  COLORS[2]: [COLORS[0], COLORS[3], COLORS[5], COLORS[1]],
  
  COLORS[3]: [COLORS[0], COLORS[4], COLORS[5], COLORS[2]],
  
  COLORS[4]: [COLORS[0], COLORS[1], COLORS[5], COLORS[3]],

  COLORS[5]: [COLORS[2], COLORS[3], COLORS[4], COLORS[1]]
};

class Cube {
  List<Face> faces = List.generate(6, (index) => Face(COLORS[index]));
  final int NFACES = 6;

  bool isComplete() {
    for (int i = 0; i < NFACES; i++) {
      if (faces[i].captured == false) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    String ret = "";
    // wowgybwyogygybyoggrowbrgywrborwggybrbwororbwborgowryby
    if (isComplete() == false) {
      return "";
    }
    for (int f = 0; f < NFACES; f++) {
      String face = "";
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          face = face + faces[f].pieces[j][i].name[0].toLowerCase();
        }
      }
      print(faces[f].colorCenter.name + " " + face);
      ret = ret + face;
    }
    return ret;
  }

}

class PieceRGB {
  int R, G, B;

  PieceRGB(this.R, this.G, this.B);
}

class Face {
  bool captured = false;
  CubeColor colorCenter;
  List<List<CubeColor>> pieces = [];

  Face(this.colorCenter);

  void setFace(List<List<CubeColor>> captured_face) {
    pieces = captured_face.map((e) => e.map((f) => CubeColor(f.name, f.color, f.trueColor)).toList()).toList();
    captured = true;
  }

  List<List<CubeColor>> getPieces() {
    return pieces.toList();
  }

}

class CubeColor {
  PieceRGB color, trueColor;
  String name;
  CubeColor(this.name, this.color, this.trueColor);

  double distance(int R, int G, int B) {
    double dis = math.sqrt(math.pow(R - color.R, 2) + math.pow(G - color.G, 2) + math.pow(B - color.B, 2));
    return dis;
  }

  Color getColor() {
    return Color.fromARGB(255, color.R, color.G, color.B);
  }

  Color getTrueColor() {
    return Color.fromARGB(255, trueColor.R, trueColor.G, trueColor.B);
  }
}



