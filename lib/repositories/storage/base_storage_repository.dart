import 'dart:io';

abstract class BaseStorageRepository {
  Future<String> updateProfileImage({String url, File image});
  // we take url because we want to update the existing image with the help of url
  Future<String> uploadPostImage({File image});
}
