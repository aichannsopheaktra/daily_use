import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ImageListScreen extends StatefulWidget {
  const ImageListScreen({super.key});

  @override
  State<ImageListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  late Box<String> imageBox;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    imageBox = Hive.box<String>('imagesBox');
  }

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String extension = p.extension(picked.path);

      final int randomIndex = Random().nextInt(900) + 100;
      final String formattedIndex = randomIndex.toString();
      final String date = DateFormat('dd_MM_yyyy').format(DateTime.now());
      final String newFileName = '$formattedIndex\_$date$extension';

      final String newPath = p.join(appDir.path, newFileName);
      final File newFile = await File(picked.path).copy(newPath);

      imageBox.add(newFile.path);
      setState(() {});
    }
  }

  void deleteImage(int index) {
    final filePath = imageBox.getAt(index);
    if (filePath != null && File(filePath).existsSync()) {
      File(filePath).deleteSync(); // also delete file from storage
    }
    imageBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final images = imageBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Image List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Upload Image from Device'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) {
                final file = File(images[index]);
                return ListTile(
                  leading: file.existsSync()
                      ? Image.file(file, width: 50, height: 50)
                      : const Icon(Icons.broken_image),
                  title: Text(p.basename(images[index])),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteImage(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
