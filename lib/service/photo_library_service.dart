import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotoLibraryService {
  PhotoLibraryService._internal();

  static final PhotoLibraryService _instance = PhotoLibraryService._internal();
  factory PhotoLibraryService() => _instance;

  saveVideo(String filepath) async {
    return await ImageGallerySaver.saveFile(filepath);
  }
}
