import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'image_list_screen.dart';

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen> {
  late Box<String> imageBox;
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    imageBox = await Hive.openBox<String>('imagesBox');
    setState(() {});
  }

  void pickRandomImage() {
    final images = imageBox.values.toList();
    if (images.isNotEmpty) {
      final random = Random();
      setState(() {
        selectedImage = images[random.nextInt(images.length)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spinner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImageListScreen()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickRandomImage,
              child: const Text('Spin Random Image'),
            ),
            const SizedBox(height: 20),
            if (selectedImage != null && File(selectedImage!).existsSync())
              Image.file(
                File(selectedImage!),
                height: 200,
                width: 200,
              )
            else
              const Text('No image selected'),
          ],
        ),
      ),
    );
  }
}
