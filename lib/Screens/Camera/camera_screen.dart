import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:chat_app/Core/theme.dart';
import 'package:chat_app/Screens/Map/map_screen.dart';
import 'package:chat_app/Widgets/Video%20Component/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_watermark/video_watermark.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  late bool isControllerInitialised = false;

  bool isVideoRecording = false;
  bool isCameraLoading = false;
  bool isVideoLoading = false;

  FlashMode currentFlashMode = FlashMode.auto;

  bool isFrontCameraSelected = false;

  ScreenshotController screenshotController = ScreenshotController();

  String? screenshotPath;

  GlobalKey metaDataKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Obtain a list of the available cameras on the device.
    initialiseCamera();
    // availableCameras().then((camera) => {
    //       // create a CameraController.
    //       _controller = CameraController(
    //         // Get a specific camera from the list of available cameras.
    //         camera.first,
    //         // Define the resolution to use.
    //         ResolutionPreset.medium,
    //       ),

    //       // Next, initialize the controller. This returns a Future.
    //       _initializeControllerFuture = _controller.initialize()
    //     });
  }

  initialiseCamera() async {
    var cameras = await availableCameras();
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      isFrontCameraSelected ? cameras[1] : cameras.first,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    _controller.setFlashMode(currentFlashMode);
    setState(() {
      isControllerInitialised = true;
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Widget cameraWidget(context) {
    var camera = _controller.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(
          _controller,
        ),
      ),
    );
  }

  Future<String?> _captureScreenshotOfMetadata() async {
    //Capture!!
    final directory = (await getApplicationDocumentsDirectory())
        .path; //from path_provide package
    int fileName = DateTime.now().microsecondsSinceEpoch;

    String? imagePath = await screenshotController.captureAndSave(directory,
        fileName: '$fileName.png', pixelRatio: window.devicePixelRatio);
    // screenshotPath = imagePath;
    print('Screenshot is captured: $imagePath');
    return imagePath;
  }

  Future<File> writeToFile(Uint8List data) async {
    final buffer = data.buffer;

    int fileName = DateTime.now().microsecondsSinceEpoch;

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath +
        '/$fileName.png'; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(data);
  }

  _navigateToPreviewPage(String filePath, String type) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayMediaScreen(
          // Pass the automatically generated path to
          // the DisplayPictureScreen widget.
          mediaPath: filePath,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
              isFrontCameraSelected ? Icons.camera_front : Icons.camera_rear),
          onPressed: () {
            setState(() {
              isFrontCameraSelected = !isFrontCameraSelected;
            });
            initialiseCamera();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(currentFlashMode == FlashMode.auto
                ? Icons.flash_auto
                : currentFlashMode == FlashMode.off
                    ? Icons.flash_off
                    : Icons.flash_on),
            onPressed: () {
              if (currentFlashMode == FlashMode.auto) {
                currentFlashMode = FlashMode.off;
              } else if (currentFlashMode == FlashMode.off) {
                currentFlashMode = FlashMode.always;
              } else if (currentFlashMode == FlashMode.always) {
                currentFlashMode = FlashMode.auto;
              }
              _controller.setFlashMode(currentFlashMode);
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(snapshot.error.toString()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Ok')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Open Settings'))
                ],
              ),
            );
            return Container();
          } else if (snapshot.hasData) {
            return isControllerInitialised
                ? FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, display the preview.
                        return cameraWidget(context);
                      } else {
                        // Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : const Center(child: CircularProgressIndicator());
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                key: metaDataKey,
                color: Colors.white60,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(minutes: 1)),
                        builder: (context, snapshot) => Text(
                          '${DateFormat.yMMMEd().format(DateTime.now())} at ${DateFormat('HH:mm a').format(DateTime.now())}',
                          style: const TextStyle(
                              color: ApplicationColors.blueColor),
                        ),
                      ),
                      FutureBuilder(
                        future: _determinePosition(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                Text(
                                  'Lat: ${snapshot.data?.latitude}, Lon: ${snapshot.data?.longitude}',
                                  style: const TextStyle(
                                      color: ApplicationColors.blueColor),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isVideoLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        onPressed: () async {
                          if (isVideoRecording) {
                            var videoFile =
                                await _controller.stopVideoRecording();
                            isVideoRecording = false;
                            setState(() {
                              isVideoLoading = true;
                            });
                            String? imagePath =
                                await _captureScreenshotOfMetadata();

                            // setState(() {});

                            final keyContext = metaDataKey.currentContext;
                            final box =
                                keyContext?.findRenderObject() as RenderBox;
                            final pos = box.localToGlobal(Offset.zero);

                            var pixelRatio = window.devicePixelRatio;
                            print('pixelRatio:- $pixelRatio');

                            VideoWatermark videoWatermark = VideoWatermark(
                              sourceVideoPath: videoFile.path,
                              watermark: Watermark(
                                  image: WatermarkSource.file(imagePath!),
                                  watermarkSize: WatermarkSize(
                                      box.size.width * pixelRatio,
                                      box.size.height * pixelRatio),
                                  watermarkAlignment:
                                      WatermarkAlignment.bottomCenter),
                              onSave: (path) {
                                setState(() {
                                  isVideoLoading = false;
                                });
                                // Get output file path
                                print('Watermark complete');
                                _navigateToPreviewPage(path!, 'video');
                              },
                              progress: (value) {
                                print(
                                  'Progress value: $value',
                                );
                                // Get video generation progress
                              },
                            );
                            videoWatermark.generateVideo();

                            // If the picture was taken, display it on a new screen.
                            // _navigateToPreviewPage(
                            //     videoWatermark.sourceVideoPath /*videoFile.path*/,
                            //     'video');
                          } else {
                            _controller.startVideoRecording();
                            isVideoRecording = true;
                          }
                          setState(() {});
                        },
                        icon: Stack(alignment: Alignment.center, children: [
                          const Icon(Icons.circle_outlined),
                          Icon(
                            isVideoRecording
                                ? Icons.square_rounded
                                : Icons.circle,
                            color: Colors.red,
                            size: isVideoRecording ? 28 : 35,
                          )
                        ]),
                        iconSize: 60,
                      ),
                isCameraLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        onPressed: () async {
                          // Take the Picture in a try / catch block. If anything goes wrong,
                          // catch the error.
                          try {
                            setState(() {
                              isCameraLoading = true;
                            });
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Attempt to take a picture and get the file `image`
                            // where it was saved.
                            XFile image = await _controller.takePicture();
                            String? imagePath =
                                await _captureScreenshotOfMetadata();

                            var byteData = await File(imagePath!).readAsBytes();

                            // Uint8List bytesOfWMImage = byteData.buffer.asUint8List();
                            print('byte image:- $byteData');
                            final keyContext = metaDataKey.currentContext;
                            final box =
                                keyContext?.findRenderObject() as RenderBox;
                            final pos = box.localToGlobal(Offset.zero);

                            var pixelRatio = window.devicePixelRatio;
                            print('pixelRatio:- $pixelRatio');
                            final watermarkedImgBytes =
                                await ImageWatermark.addImageWatermark(
                              originalImageBytes:
                                  await image.readAsBytes(), //image bytes
                              waterkmarkImageBytes:
                                  byteData, //watermark img bytes
                              imgHeight: (box.size.width * pixelRatio)
                                  .toInt(), //watermark img height
                              imgWidth: (box.size.height * pixelRatio)
                                  .toInt(), //watermark img width
                              dstY: ((MediaQuery.of(context).size.height *
                                          pixelRatio) -
                                      (box.size.height * pixelRatio) -
                                      (MediaQuery.of(context).padding.top *
                                              pixelRatio +
                                          MediaQuery.of(context)
                                                  .padding
                                                  .bottom *
                                              pixelRatio) -
                                      150 * pixelRatio)
                                  .toInt(),
                              dstX: ((MediaQuery.of(context).size.width *
                                              pixelRatio) /
                                          2 -
                                      (box.size.width * pixelRatio) / 2)
                                  .toInt(),
                            );
                            print('watermark added');
                            File imagefile =
                                await writeToFile(watermarkedImgBytes);
                            setState(() {
                              isCameraLoading = false;
                            });
                            _navigateToPreviewPage(imagefile.path, 'Image');
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                        icon: const Icon(
                          Icons.circle_outlined,
                          size: 60,
                        ),
                        iconSize: 60,
                      ),
              ],
            ),
            screenshotPath != null
                ? Image.file(File(screenshotPath!))
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayMediaScreen extends StatelessWidget {
  final String mediaPath;
  final String type;

  const DisplayMediaScreen(
      {super.key, required this.mediaPath, required this.type});

  @override
  Widget build(BuildContext context) {
    print(mediaPath);
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: type == 'Image'
          ? Image.file(File(mediaPath))
          : VideoViewPage(path: mediaPath),
    );
  }
}
