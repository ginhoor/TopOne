import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotoLibraryManager {
  PhotoLibraryManager._internal();

  static final PhotoLibraryManager instance = PhotoLibraryManager._internal();
  factory PhotoLibraryManager() => instance;

  Future saveVideo(String filepath) async {
    return await ImageGallerySaver.saveFile(filepath);
  }
}
