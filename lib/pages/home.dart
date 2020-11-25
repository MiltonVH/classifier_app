import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:classifier_app/utils/logUtils.dart';
import 'package:classifier_app/utils/cameraUtils.dart';
import 'package:classifier_app/utils/tfliteUtils.dart';
import 'package:classifier_app/utils/result.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> with TickerProviderStateMixin {
  AnimationController _colorAnimController;
  Animation _colorTween;
  AudioPlayer fixplay = AudioPlayer();
  AudioCache player;

  List<Result> outputs;

  void initState() {
    super.initState();

    TfliteUtils.loadModel().then((value) {
      setState(() {
        TfliteUtils.modelLoaded = true;
      });
    });

    CameraUtils.initializeCamera();

    _setupAnimation();

    _loadSounds();

    TfliteUtils.tfLiteResultsController.stream.listen(
        (value) {
          value.forEach((element) {
            _colorAnimController.animateTo(element.confidence,
                curve: Curves.bounceIn, duration: Duration(milliseconds: 500));
          });

          outputs = value;

          setState(() {
            CameraUtils.isDetecting = false;
          });
        },
        onDone: () {},
        onError: (error) {
          LogUtils.log("error:", error);
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue[900],
      ),
      body: GestureDetector(
        onDoubleTap: () async {
          player.play(
            '${outputs[0].label.split('_')[0]}.mp3',
            volume: 2.0,
          );
        },
        child: FutureBuilder<void>(
          future: CameraUtils.initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: <Widget>[
                  CameraPreview(CameraUtils.camera),
                  _buildResultsWidget(width, outputs)
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    TfliteUtils.disposeModel();
    CameraUtils.camera.dispose();
    LogUtils.log("dispose", "Clear resources.");
    super.dispose();
  }

  Widget _buildResultsWidget(double width, List<Result> outputs) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          outputs[index].label,
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 20.0,
                          ),
                        ),
                        AnimatedBuilder(
                            animation: _colorAnimController,
                            builder: (context, child) => LinearPercentIndicator(
                                  width: width * 0.88,
                                  lineHeight: 14.0,
                                  percent: outputs[index].confidence,
                                  progressColor: _colorTween.value,
                                )),
                        Text(
                          "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    );
                  })
              : Center(
                  child: Text('Esperando al modelo ...',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }

  void _setupAnimation() {
    _colorAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _colorTween = ColorTween(begin: Colors.green, end: Colors.red)
        .animate(_colorAnimController);
  }

  void _loadSounds() {
    player = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: fixplay,
    );
    player.loadAll([
      'uno.mp3',
      'cinco.mp3',
      'diez.mp3',
      'veinte.mp3',
      'cincuenta.mp3',
      'cien.mp3',
      'doscientos.mp3',
      'a.mp3'
    ]);
  }
}
