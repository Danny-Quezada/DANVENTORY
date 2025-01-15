import 'package:danventory/domain/entities/user_model.dart';
import 'package:danventory/domain/interfaces/imodel.dart';

abstract class IUserModel extends IModel<UserModel> {
  Future<UserModel> verifyUser(String email, String password);
  Future<bool> signInWithGoogle();
  Future<UserModel> getUserById(String id);
}
