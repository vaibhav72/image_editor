import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_text_overlay/cubits/cubit/image_editor_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ImageEditor extends StatefulWidget {
  const ImageEditor({super.key});

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor>
    with SingleTickerProviderStateMixin {
  ScreenshotController screenshotController = ScreenshotController();
  double left = 0;
  double top = 0;
  bool enableText = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<ImageEditorCubit, ImageEditorState>(
        builder: (context, state) {
          if (state.imagePath != null) {
            return FloatingActionButton(
                child: Icon(Icons.share),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  await screenshotController
                      .capture(delay: const Duration(milliseconds: 100))
                      .then((Uint8List? image) async {
                    context.read<ImageEditorCubit>().shareImage(image);
                  });
                });
          }
          return SizedBox();
        },
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Editor"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  enableText = !enableText;
                });
              },
              icon: enableText
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.abc_rounded,
                        color: Colors.teal,
                      ),
                    )
                  : Icon(
                      Icons.abc_rounded,
                      size: 30,
                    )),
          BlocBuilder<ImageEditorCubit, ImageEditorState>(
            builder: (context, state) {
              return state.imagePath != null
                  ? IconButton(
                      onPressed: () {
                        context.read<ImageEditorCubit>().updateImagePath(null);
                      },
                      icon: Icon(Icons.close))
                  : SizedBox.shrink();
            },
          )
        ],
      ),
      body: Container(
        // color: Colors.red,
        height: double.maxFinite,
        width: double.maxFinite,
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              const Center(child: ImageWidget()),
              if (enableText)
                BlocBuilder<ImageEditorCubit, ImageEditorState>(
                  builder: (context, state) {
                    return Positioned(
                        top: top,
                        left: left,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            // print("local-${details.localPosition}");
                            // print("global -${details.globalPosition}");
                            top += details.delta.dy;
                            left += details.delta.dx;
                            setState(() {});
                            context.read<ImageEditorCubit>().updateTextPosition(
                                Offset(
                                    state.textPosition!.dx + details.delta.dx,
                                    state.textPosition!.dy + details.delta.dy));
                          },
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: TextField(
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  context
                                      .read<ImageEditorCubit>()
                                      .updateText(value);
                                },
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    hintText: 'Caption Here',
                                    focusedBorder: UnderlineInputBorder(),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                              )),
                        ));
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  final ImagePicker _picker = ImagePicker();
  getAndSetImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<ImageEditorCubit>().updateImagePath(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageEditorCubit, ImageEditorState>(
      builder: (context, state) {
        return state.imagePath == null
            ? Center(
                child: InkWell(
                  onTap: () {
                    getAndSetImage();
                  },
                  child: Container(
                      color: Colors.tealAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Pick Image"),
                      )),
                ),
              )
            : InteractiveViewer(
                panEnabled: false,
                child: Image(image: FileImage(File(state.imagePath!))));
      },
    );
  }
}
