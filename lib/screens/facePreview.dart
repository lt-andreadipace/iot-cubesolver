
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'dart:collection';
import 'package:flutter/material.dart';

import '../utils/classes.dart';
import '../painters/faceView.dart';

class DisplayPictureScreen extends StatefulWidget {
  
  final List<List<CubeColor>> face;
  final CubeColor colorCenter;

  const DisplayPictureScreen(
      {Key? key, required this.face, required this.colorCenter})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

List<int> getIndex(TapDownDetails event, int width, int height) {
  int posX = event.localPosition.dx.round();
  int posY = event.localPosition.dy.round();

  int w1 = (width / 3).round();
  int h1 = (height / 3).round();
  int iX = -1, iY = -1;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      int startX = w1 * i;
      int startY = h1 * j;
      int endX = w1 * (i + 1);
      int endY = h1 * (j + 1);
      if (posX > startX &&
          posX < endX &&
          posY > startY &&
          posY < endY) {
        iX = i;
        iY = j;
        break;
      }
    }
    if (iX != -1) break;
  }
  return [iX, iY];
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<Color> avColors = [];
  HashMap hashMap = HashMap<Color, CubeColor>();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < COLORS.length; i++) {
      avColors.add(COLORS[i].getTrueColor());
      hashMap[COLORS[i].getTrueColor()] = COLORS[i];
    }
  }

  void repaint(setState, face, i, j, color) {
    setState(() {
      face[i][j] = hashMap[color];
    });
  }

  @override
  Widget build(BuildContext context) {
    StateSetter mystate = setState;
    return Scaffold(
        appBar: AppBar(title: const Text('Edit face')),
        body: Column(children: [
          GestureDetector(
            onTapDown: null,
            child: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Container(
                  width: 400,
                  height: 400,
                  color: Colors.white,
                  child: GestureDetector(
                    child: CustomPaint(painter: FacePainter(widget.face)),
                    onTapDown: (event) async {
                      
                      List<int> index = getIndex(event, 400, 400);
                      int iX = index[0], iY = index[1];

                      if (iX == 1 && iY == 1) return;
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.grey,
                            title: const Text('Pick a color!'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                availableColors: avColors,
                                pickerColor: widget.face[iX][iY].getTrueColor(),
                                onColorChanged: (Color color) {
                                  repaint(mystate, widget.face, iX, iY, color);
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('DONE'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); //dismiss the color picker
                                },
                              ),
                            ],
                          );
                        }
                      );
                    }
                  )
                )
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btnRetry",
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: const Icon(Icons.party_mode),
                ),
                FloatingActionButton(
                  heroTag: "btnAccept",
                  onPressed: () {
                    Navigator.pop(context, widget.face);
                  },
                  child: const Icon(Icons.check),
                )
              ],
            ),
          )
        ]
      )
    );
  }
}
