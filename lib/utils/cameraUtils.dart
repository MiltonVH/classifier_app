import 'package:camera/camera.dart';
import 'package:classifier_app/utils/logUtils.dart';
import 'package:classifier_app/utils/tfliteUtils.dart';

class CameraUtils {
  static CameraController camera;

  static bool isDetecting = false;
  static CameraLensDirection _direction = CameraLensDirection.back;
  static Future<void> initializeControllerFuture;

  static Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  static void initializeCamera() async {
    LogUtils.log("_initializeCamera", "Initializing camera..");

    camera = CameraController(
      await _getCamera(_direction),
      ResolutionPreset.high,
      enableAudio: false,
    );
    initializeControllerFuture = camera.initialize().then((value) {
      LogUtils.log(
          "_initializeCamera", "Camera initialized, starting camera stream..");

      camera.startImageStream((CameraImage image) {
        if (!TfliteUtils.modelLoaded) return;
        if (isDetecting) return;
        isDetecting = true;
        try {
          TfliteUtils.classifyImage(image);
        } catch (e) {
          print(e);
        }
      });
    });
  }
}
