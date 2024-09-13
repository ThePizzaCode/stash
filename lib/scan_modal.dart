import 'dart:io';
import 'package:Stash/add_barcode.dart';
import 'package:Stash/store_modal.dart';
import 'package:camera/camera.dart';
import 'package:Stash/add_card_name.dart';
import 'package:Stash/alert_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glass/glass.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ScanModal {
  static Future<void> show(BuildContext context) async {
    // Request camera permission
    print('Requesting camera permission...');
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      print('Camera permission not granted, requesting...');
      await Permission.camera.request();
    } else {
      print('Camera permission already granted.');
    }

    // Get the list of available cameras.
    print('Fetching available cameras...');
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print('No cameras found.');
      AlertBox.show(context,
          title: "No Camera Detected",
          content: "We couldn't find an available camera on your device.",
          accept: "Dismiss",
          decline: "Dismiss",
          acceptColor: Colors.red, declineCallback: () async {
        Navigator.pop(context);
      }, acceptCallback: () async {});
      return;
    }

    print('Available cameras: ${cameras.length}');
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    print('Using camera: ${firstCamera.name}');

    // Initialize a CameraController
    print('Initializing CameraController...');
    final controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    // Initialize the controller. This returns a Future.
    await controller.initialize();
    print('CameraController initialized.');

    // Specify the formats you want to scan (in this case, all formats)
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    final barcodeScanner = BarcodeScanner(formats: formats);
    print('BarcodeScanner initialized with formats: $formats');

    // State to control the blur and tick animation
    bool hasScanned = false;

    showModalBottomSheet(
      backgroundColor: Theme.of(context).shadowColor,
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            print('Starting image stream...');
            controller.startImageStream((CameraImage image) async {
              print('Received image stream.');

              if (!hasScanned) {
                print('Processing image...');
                final inputImage =
                    _inputImageFromCameraImage(controller, image);
                if (inputImage == null) {
                  print('InputImage is null.');
                  return;
                }

                try {
                  // Process the image to detect barcodes
                  print('Scanning image for barcodes...');
                  final List<Barcode> barcodes =
                      await barcodeScanner.processImage(inputImage);
                  print('Barcodes found: ${barcodes.length}');

                  if (barcodes.isNotEmpty) {
                    setState(() {
                      hasScanned = true;
                      Haptics.vibrate(HapticsType.success);
                    });

                    // Optionally: Stop the image stream to avoid multiple scans
                    print('Stopping image stream...');
                    await controller.stopImageStream();

                    Future.delayed(const Duration(seconds: 1), () {
                      print('Barcode format: ${barcodes[0].format}');
                      Navigator.pop(context); // Dismiss the modal first
                      StoreModal.show(context, barcodes[0].rawValue ?? "Null",
                          barcodes[0].format.toString());
                      // Navigate to the EnterCardNamePage
                    });

                    // Process barcodes (example handling)
                    for (Barcode barcode in barcodes) {
                      final BarcodeType type = barcode.type;
                      final String? displayValue = barcode.displayValue;
                      final String? rawValue = barcode.rawValue;

                      // Example switch case to handle different barcode types
                      switch (type) {
                        case BarcodeType.wifi:
                          final BarcodeWifi wifiInfo =
                              barcode.value as BarcodeWifi;
                          print(
                              'Wi-Fi: ${wifiInfo.ssid}, ${wifiInfo.password}');
                          break;
                        case BarcodeType.url:
                          final BarcodeUrl urlInfo =
                              barcode.value as BarcodeUrl;
                          print('URL: ${urlInfo.title}, ${urlInfo.url}');
                          break;
                        default:
                          print('Barcode value: $rawValue');
                          break;
                      }
                    }
                  }
                } catch (e) {
                  print('Error scanning barcode: $e');
                }
              }
            });

            return Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            print('Closing modal and disposing camera...');
                            Navigator.pop(context);
                            controller.dispose();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).shadowColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)!.scan_loyalty_card,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: "SFProRounded",
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display the camera preview
                  Stack(
                    children: [
                      buildCameraPreview(controller),
                      AnimatedOpacity(
                        opacity: hasScanned ? 1.0 : 0.0,
                        duration: const Duration(
                            milliseconds: 500), // Adjust the duration as needed
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 273,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0),
                              ),
                            ).asGlass(
                              enabled: true,
                              tintColor: Colors.transparent,
                              clipBorderRadius: BorderRadius.circular(15.0),
                            ),
                            const Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              color: Colors.green,
                              size: 60,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      print('Navigating to AddBarcode page...');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddBarcode()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.add_manually_button,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() async {
      // Dispose of the controller when the modal is closed
      print('Modal closed, disposing camera controller...');
      await controller.dispose();

      // Close the barcode scanner to release resources
      print('Closing barcode scanner...');
      barcodeScanner.close();
    });
  }

  static InputImage? _inputImageFromCameraImage(
      CameraController controller, CameraImage image) {
    print('Creating InputImage from CameraImage...');

    // Get image rotation
    final sensorOrientation = controller.description.sensorOrientation;
    InputImageRotation rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation)!;
      print('iOS rotation: $rotation');
    } else if (Platform.isAndroid) {
      final rotationCompensation =
          _getRotationCompensation(controller, sensorOrientation);
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation)!;
      print('Android rotation: $rotation');
    } else {
      print('Unsupported platform for rotation');
      return null;
    }

    // Get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.yuv_420_888) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      print('Unsupported format: $format');
      return null;
    }

    // Handle YUV_420_888 format
    if (format == InputImageFormat.yuv_420_888) {
      final nv21Image = _convertYUV420toNV21(image);
      if (nv21Image == null) {
        print('Error converting YUV_420_888 to NV21');
        return null;
      }

      // Create InputImage from NV21 bytes
      return InputImage.fromBytes(
        bytes: nv21Image,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    }

    // Handle NV21 or BGRA8888 format
    if (image.planes.length != 1) {
      print('Unexpected number of planes: ${image.planes.length}');
      return null;
    }

    final plane = image.planes.first;
    print(
        'Plane data - bytesPerRow: ${plane.bytesPerRow}, bytes length: ${plane.bytes.length}');

    // Compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static Uint8List? _convertYUV420toNV21(CameraImage image) {
    try {
      final yPlane = image.planes[0].bytes;
      final uPlane = image.planes[1].bytes;
      final vPlane = image.planes[2].bytes;

      print('Y plane length: ${yPlane.length}');
      print('U plane length: ${uPlane.length}');
      print('V plane length: ${vPlane.length}');

      final uvPlane = _mergeUVPlanes(uPlane, vPlane, image.width, image.height);
      final nv21Bytes = Uint8List.fromList([...yPlane, ...uvPlane]);

      print('NV21 bytes length: ${nv21Bytes.length}');
      return nv21Bytes;
    } catch (e) {
      print('Error converting YUV_420_888 to NV21: $e');
      return null;
    }
  }

  static Uint8List _mergeUVPlanes(
      Uint8List uPlane, Uint8List vPlane, int width, int height) {
    final uvPlane = Uint8List(width * height ~/ 2);

    for (int i = 0; i < uvPlane.length; i += 2) {
      uvPlane[i] = uPlane[i ~/ 2];
      uvPlane[i + 1] = vPlane[i ~/ 2];
    }

    print('UV plane length: ${uvPlane.length}');
    return uvPlane;
  }

  static int _getRotationCompensation(
      CameraController controller, int sensorOrientation) {
    print('Calculating rotation compensation...');
    final orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    var rotationCompensation = orientations[controller.value.deviceOrientation];
    if (rotationCompensation == null) {
      print('No rotation compensation found, using sensorOrientation');
      return sensorOrientation;
    }
    if (controller.description.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    print('Rotation compensation: $rotationCompensation');
    return rotationCompensation;
  }

  static void _showNoCameraDialog(BuildContext context) {
    print('Showing no camera dialog...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Camera Found'),
          content:
              const Text('No available cameras were found on this device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Widget buildCameraPreview(CameraController cameraController) {
  print('Building camera preview...');
  const double previewAspectRatio = 0.7;
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: AspectRatio(
      aspectRatio: 1 / previewAspectRatio,
      child: ClipRect(
        child: Transform.scale(
          scale: cameraController.value.aspectRatio / previewAspectRatio,
          child: Center(
            child: CameraPreview(cameraController),
          ),
        ),
      ),
    ),
  );
}
