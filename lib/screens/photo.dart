import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;

import '../utils/classes.dart';
import '../utils/function.dart';

import '../painters/overlayFace.dart';
import './facePreview.dart';
import './loading.dart';


class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final CubeColor colorCenter;

  const TakePictureScreen(
      {Key? key, required this.camera, required this.colorCenter})
      : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

void resizeANDcrop(XFile image) {
  RenderBox boxCamera = keyCamera.currentContext!.findRenderObject() as RenderBox;
  Offset positionCamera = boxCamera.localToGlobal(Offset.zero);
  // preview size
  int wCamera = boxCamera.size.width.round();
  int hCamera = boxCamera.size.height.round();

  RenderBox boxCanvas =
      keyCanvas.currentContext!.findRenderObject() as RenderBox;
  Offset positionCanvas = boxCanvas.localToGlobal(Offset.zero);

  int wCanvas = boxCanvas.size.width.round();
  int hCanvas = boxCanvas.size.height.round();

  int startCanvasX = (positionCanvas.dx - positionCamera.dx).round();
  int startCanvasY = (positionCanvas.dy - positionCamera.dy).round();

  // resize image
  final im = img.decodeImage(File(image.path).readAsBytesSync())!;
  final image_resized = img.copyResize(im, width: wCamera, height: hCamera);

  // crop image
  final icrop = img.copyCrop(image_resized, startCanvasX, startCanvasY, wCanvas, hCanvas);
  final fc = File(image.path);
  fc.writeAsBytesSync(img.encodePng(icrop));
}


GlobalKey keyCamera = GlobalKey();
GlobalKey keyCanvas = GlobalKey();

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool busy = false;

    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              key: keyCamera,
              height: 800,
              width: 800,
              child: Stack(
                alignment: FractionalOffset.center,
                children: <Widget>[
                  CameraPreview(_controller),
                  Opacity(
                    opacity: 1,
                    child: Container(
                      key: keyCanvas,
                      width: 400,
                      height: 400,
                      color: Colors.transparent,
                      child: CustomPaint(painter: FaceOverlayPainter(widget.colorCenter)),
                    ),
                  ),
                ],
              )
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            if (busy == true) return;

            buildLoading(context);
            
            busy = true;
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            busy = false;

            resizeANDcrop(image);
            
            // dismiss loading
            Navigator.of(context).pop();

            List<List<CubeColor>> FACE = getColorName(image, widget.colorCenter);

            final res = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  face: FACE,
                  colorCenter: widget.colorCenter
                )
              ),
            );
            if (res != null) {
              Navigator.pop(context, res);
            }
          } catch (e) {
            print(e);
          } finally {
            busy = false;
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

