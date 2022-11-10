import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_text_overlay/image_editor_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'image_editor_state.dart';

class ImageEditorCubit extends Cubit<ImageEditorState> {
  ImageEditorCubit()
      : super(ImageEditorUpdated(textPosition: Offset(0, 0), text: ''));

  updateImagePath(String? path) {
    emit(state.copyWith(imagePath: path));
  }

  updateTextPosition(Offset offset) {
    emit(state.copyWith(textPosition: offset,imagePath: state.imagePath));
  }

  updateText(String text) {
    emit(state.copyWith(text: text,imagePath: state.imagePath));
  }

  shareImage(Uint8List? image) async {
    if (state.imagePath != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/image.png').create();
      await imagePath.writeAsBytes(image!);

      await Share.shareXFiles([XFile(imagePath.path)]);
    }
  }
}
