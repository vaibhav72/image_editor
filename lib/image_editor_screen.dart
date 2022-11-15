import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  double scaleFactor = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<ImageEditorCubit, ImageEditorState>(
        builder: (context, state) {
          if (state.imagePath != null) {
            return FloatingActionButton(
                child: const Icon(Icons.share),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  await screenshotController
                      .capture(delay: const Duration(milliseconds: 100))
                      .then((Uint8List? image) async {
                    context.read<ImageEditorCubit>().shareImage(image);
                  });
                });
          }
          return const SizedBox();
        },
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Editor"),
        actions: [
          if (enableText)
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
                        context.read<ImageEditorCubit>().updateText('');
                      },
                      icon: const Icon(Icons.close))
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              Center(
                  child: ImageWidget(showTextField: (TapDownDetails details) {
                log(details.globalPosition.toString());
                setState(() {
                  if (!enableText) {
                    enableText = true;
                    top = details.localPosition.dy;
                    left = details.localPosition.dx;
                  }
                });
              })),
              if (enableText)
                BlocBuilder<ImageEditorCubit, ImageEditorState>(
                  builder: (context, state) {
                    return Positioned(
                        top: top,
                        left: left,
                        child: GestureDetector(
                          onScaleUpdate: (details) {
                            top += details.focalPointDelta.dy;
                            left += details.focalPointDelta.dx;
                            if (details.scale != 1) scaleFactor = details.scale;

                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                  textScaleFactor: scaleFactor,
                                  size: Size(
                                    MediaQuery.of(context).size.width *
                                        scaleFactor,
                                    MediaQuery.of(context).size.height,
                                  )),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: TextField(
                                  maxLines: null,
                                  textAlign: TextAlign.start,
                                  onChanged: (value) {
                                    context
                                        .read<ImageEditorCubit>()
                                        .updateText(value);
                                  },
                                  decoration: const InputDecoration(
                                      // alignLabelWithHint: true,

                                      hintText: 'Caption Here',
                                      // focusedBorder: UnderlineInputBorder(),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                ),
                              ),
                            ),
                          ),
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
  ImageWidget({
    Key? key,
    required this.showTextField,
  }) : super(key: key);
  Function(TapDownDetails)? showTextField;
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
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Pick Image"),
                      )),
                ),
              )
            : GestureDetector(
                onTapDown: widget.showTextField,
                child: Image(image: FileImage(File(state.imagePath!))),
              );
      },
    );
  }
}
