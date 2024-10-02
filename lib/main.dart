import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<(String, Color)> paletteColorRecords = [];

  _generateColorsFromImage() async {
    paletteColorRecords.clear();
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final Image image;
      if (!kIsWeb) {
        final file = File(result.files.single.path!);
        final fileBytes = await file.readAsBytes();
        image = Image.memory(fileBytes, width: 218);
      } else {
        image = Image.memory(result.files.single.bytes!, width: 218);
      }

      final paletteGenerator =
          await PaletteGenerator.fromImageProvider(image.image);
      paletteColorRecords = paletteGenerator.paletteColors
          .mapIndexed(
            (i, e) => ('Color ${i + 1}', e.color),
          )
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _generateColorsFromImage(),
              child: const Text('Generate Colors from Image'),
            ),
            const SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              children: paletteColorRecords
                  .map((e) => ListTile(
                        title: Text(e.$1),
                        tileColor: e.$2,
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
