part of 'image_editor_cubit.dart';

abstract class ImageEditorState extends Equatable {
  const ImageEditorState({this.imagePath, this.text, this.textPosition});
  final String? imagePath;
  final String? text;
  final Offset? textPosition;
  ImageEditorState copyWith(
      {String? imagePath, String? text, Offset? textPosition}) {
    return ImageEditorUpdated(
        imagePath: imagePath ?? this.imagePath,
        textPosition: textPosition ?? this.textPosition,
        text: text ?? this.text);
  }

  @override
  List<Object?> get props => [imagePath, text, textPosition];
}

class ImageEditorUpdated extends ImageEditorState {
  ImageEditorUpdated({String? imagePath, String? text, Offset? textPosition})
      : super(imagePath: imagePath, text: text, textPosition: textPosition);
}
