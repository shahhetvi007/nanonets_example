import 'dart:io';
import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanonets_example/helper/api_helper.dart';
import 'package:nanonets_example/models/model_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? imagePicked;
  ModelResponse? modelResponse;
  Uint8List? imageBytes;
  bool _isPredicted = false;
  Image? image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 50),
                    onPressed: imgFromCamera,
                  ),
                  IconButton(
                    icon: const Icon(Icons.image, size: 50),
                    onPressed: imgFromGallery,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              image != null
                  ? Column(
                      children: [
                        Container(
                          // height: 100,
                          // width: 100,
                          child: image,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () async {
                              _isPredicted = false;
                              modelResponse = await ApiHelper()
                                  .checkImageFromFile(imagePicked!);
                              setState(() {
                                if (modelResponse != null) {
                                  _isPredicted = true;
                                }
                              });
                            },
                            child: const Text('Get Details'))
                      ],
                    )
                  : Container(),
              const SizedBox(height: 30),
              modelResponse != null
                  ? Column(
                      children: [
                        Text(modelResponse!.result[0].prediction[0].ocrText),
                        const SizedBox(height: 20),
                        Text(modelResponse!.result[0].prediction[1].ocrText),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future imgFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      imagePicked = File(pickedFile.path);
      setState(() {});
      imageBytes = await pickedFile.readAsBytes();
      // image = await Navigator.push(context,
      //     MaterialPageRoute(builder: (ctx) => CropImagePage(image: (image!)));
    } else {
      print('No image path received');
    }
  }

  Future imgFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imagePicked = File(pickedFile.path);
      image_.Image? image =
          image_.decodeImage(File(pickedFile.path).readAsBytesSync());
      setState(() {});
      imageBytes = await pickedFile.readAsBytes();
      image = await Navigator.push(context,
          MaterialPageRoute(builder: (ctx) => CropImagePage(image: image!)));
      // _imageCropping();
    } else {
      print('No image path received');
    }
  }

  Future _cropImage(File image) async {
    ImageCropper imageCropper = ImageCropper();
    CroppedFile? croppedImage =
        await imageCropper.cropImage(sourcePath: image.path);
    if (croppedImage != null) {
      imagePicked = File(croppedImage.path);
      setState(() {});
    }
  }

  Future _imageCropping() async {
    if (imageBytes != null) {
      await ImageCropping.cropImage(
          context: context,
          imageBytes: imageBytes!,
          outputImageFormat: OutputImageFormat.jpg,
          onImageDoneListener: (data) {
            imageBytes = data;
            setState(() {});
          });
    }
  }
}

class CropImagePage extends StatefulWidget {
  final image_.Image? image;

  const CropImagePage({Key? key, required this.image}) : super(key: key);

  @override
  _CropImagePageState createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final controller = CropController(
    aspectRatio: 3 / 2,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  Image? image;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Crop Image'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CropImage(
              controller: controller,
              image: image!,
              // scale: 1,
              // widget.imageBytes,
              // // height: 800,
              // // width: 800,
              // cacheHeight: 500,
              // cacheWidth: 500,
              // fit: BoxFit.fitHeight,
              // fit: BoxFit.contain,
            ),
          ),
        ),
        bottomNavigationBar: _buildButtons(context),
      );

  Widget _buildButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.aspectRatio = null;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
            },
          ),
          IconButton(
            icon: const Icon(Icons.aspect_ratio),
            onPressed: _aspectRatios,
          ),
          TextButton(
            onPressed: () => _finished(context),
            child: const Text('Done'),
          ),
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _finished(BuildContext context) async {
    image = await controller.croppedImage();
    Navigator.pop(context, image);
    // copyResize(widget.imageBytes);
    // await showDialog<bool>(
    //   context: context,
    //   builder: (context) {
    //     return SimpleDialog(
    //       contentPadding: const EdgeInsets.all(6.0),
    //       titlePadding: const EdgeInsets.all(8.0),
    //       title: const Text('Cropped image'),
    //       children: [
    //         Text('relative: ${controller.crop}'),
    //         Text('pixels: ${controller.cropSize}'),
    //         const SizedBox(height: 5),
    //         image,
    //         TextButton(
    //           onPressed: () => Navigator.pop(context, true),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
