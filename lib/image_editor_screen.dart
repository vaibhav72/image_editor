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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageEditorCubit(),
      child: Container(
          child: Scaffold(
        floatingActionButton: BlocBuilder<ImageEditorCubit, ImageEditorState>(
          builder: (context, state) {
            if (state.imagePath != null) {
              return FloatingActionButton(onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());

                await screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((Uint8List? image) async {
                  context.read<ImageEditorCubit>().shareImage(image);
                });
              });
            }
            return SizedBox();
          },
        ),
        appBar: AppBar(),
        body: Container(
          // color: Colors.red,
          height: double.maxFinite,
          width: double.maxFinite,
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                const Center(child: ImageWidget()),
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
                                onChanged: (value) {
                                  context
                                      .read<ImageEditorCubit>()
                                      .updateText(value);
                                },
                                decoration: InputDecoration(
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
      )),
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
                  child: Text("Pick Image"),
                ),
              )
            : InteractiveViewer(
                panEnabled: false,
                child: Image(image: FileImage(File(state.imagePath!))));
      },
    );
  }
}
