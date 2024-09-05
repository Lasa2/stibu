import 'package:appwrite/appwrite.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:result_type/result_type.dart';

class AvatarsRepository {
  final Avatars _avatars;

  AvatarsRepository(this._avatars);

  Future<Result<Image, String>> getAvatar({
    String? name,
    int? width,
    int? height,
    String? background,
  }) async {
    try {
      final response = await _avatars.getInitials(
        name: name,
        width: width,
        height: height,
        background: background,
      );
      return Success(Image.memory(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Failed to get avatar");
    }
  }
}
