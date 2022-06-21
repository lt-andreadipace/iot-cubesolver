import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'screens/photo.dart';
import 'screens/facePreview.dart';
import 'screens/loading.dart';

import 'utils/classes.dart';
import 'painters/cubePreview.dart';
import 'painters/faceView.dart';

late CameraDescription CAMERA;
String HOSTIP = "192.168.43.76";

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final CameraDescription firstCamera = cameras.first;
  CAMERA = firstCamera;

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.dark(),
      home: MyApp(),
    ),
  );
}

class CubeCanvas extends StatelessWidget {
  List<List<CubeColor>> pieces;
  
  CubeCanvas({ Key? key, required this.pieces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Container(
        color: Colors.white,
        child: CustomPaint(painter: FacePainter(pieces)),
      )
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Cube mycube = Cube();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Cube Solver'),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    mycube = Cube();
                  });
                },
                child: const Icon(
                  Icons.refresh,
                  size: 26.0,
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Insert host IP'),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          child: TextFormField(
                            initialValue: HOSTIP,
                            onChanged: (String newString) {
                              HOSTIP = newString;
                            },
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Enter your username',
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('DONE'),
                            onPressed: () {
                              Navigator.of(context).pop(); //dismiss the color picker
                            },
                          ),
                        ],
                      );
                    });
                },
                child: const Icon(
                  Icons.computer,
                  size: 26.0,
                ),
              )
            )
          ],
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Center(child: 
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: Container(
                    color: Colors.transparent,
                    child: CustomPaint(painter: CubePreviewPainter(mycube))
                  )
                )
              )
              
            ),
            
            GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            children: List.generate(6, (index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  
                  child: (mycube.faces[index].captured)
                    ? Column(
                      children: [
                        Text(
                          mycube.faces[index].colorCenter.name,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final res = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DisplayPictureScreen(
                                    face: mycube.faces[index].pieces, colorCenter: mycube.faces[index].colorCenter),
                              ),
                            );
                            if (res != null) {
                              setState(() {
                                mycube.faces[index].setFace(res);
                              });
                            } 
                          },
                          child: CubeCanvas(pieces: mycube.faces[index].pieces),
                        )
                        
                    ])
                    : Column(
                      children: [
                        Text(
                          mycube.faces[index].colorCenter.name,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: IconButton(
                            iconSize: 75,
                            icon: const Icon(Icons.add),
                            tooltip: 'Add face',
                            onPressed: () async {
                              final res = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TakePictureScreen(
                                    camera: CAMERA,
                                    colorCenter: mycube.faces[index].colorCenter
                                  ),
                                ),
                              );
                              if (res != null) {
                                setState(() {
                                  mycube.faces[index].setFace(res);
                                });
                              }
                            }
                          )
                        )
                      ],
                    )
                  )
              );
            }),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            height: 70,
            child: ElevatedButton(  
              onPressed: (mycube.isComplete())
                ? () async {
                  buildLoading(context);
                  final URL = 'http://${HOSTIP}:5000/solve';
                  http.Response res;
                  try {
                      res = await http.post(
                      Uri.parse(URL),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{
                        'cube': mycube.toString(),
                      }),
                    ).timeout(const Duration(seconds: 1));;
                  }
                  catch (e) {
                    const snackBar = SnackBar(
                      content: Text('Server offline or bad config!'),
                      duration: Duration(seconds: 3),
                    );
                    ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(snackBar);
                    
                    // dismiss loading
                    Navigator.of(context).pop();
                    return;
                  }


                  // dismiss loading
                  Navigator.of(context).pop();
                  
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Server response'),
                        content: Text(res.body),
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
                    });
                }
                : null,
              child: const Text('SOLVE', style: TextStyle(fontSize: 30)),
            )
          )
          
        ])
      ),
    );
  }
}