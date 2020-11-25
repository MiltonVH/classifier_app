import 'dart:async';
import 'package:camera/camera.dart';
import 'package:classifier_app/utils/result.dart';
import 'package:tflite/tflite.dart';
import 'package:classifier_app/utils/logUtils.dart';

class TfliteUtils {
  static StreamController<List<Result>> tfLiteResultsController =
      new StreamController.broadcast();
  static List<Result> _outputs = List();
  static var modelLoaded = false;

  static Future<String> loadModel() async {
    LogUtils.log("loadModel", "Loading model..");

    return Tflite.loadModel(
      model: "assets/modelo_float16.tflite",
      labels: "assets/labels.txt",
    );
  }

  static classifyImage(CameraImage image) async {
    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: image.height,
            imageWidth: image.width,
            imageMean: 0,
            imageStd: 255.0,
            numResults: 5)
        .then((value) {
      if (value.isNotEmpty) {
        // AppUtils.log("clasificacion", "Results loaded. ${value.length}");

        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));

          // AppUtils.log("clasificacion",
          //     "${element['confidence']} , ${element['index']}, ${element['label']}");
        });
      }

      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
