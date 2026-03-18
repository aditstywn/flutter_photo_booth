import 'dart:io';

class CreatePhotoboothRequestModel {
  final int? id;
  final File? photoTemplate;
  final File? gifVidio;
  final List<File>? photoOri;

  CreatePhotoboothRequestModel({
    this.id,
    this.photoTemplate,
    this.gifVidio,
    this.photoOri,
  });
}
