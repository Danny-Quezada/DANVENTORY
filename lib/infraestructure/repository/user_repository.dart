import 'package:danventory/domain/db/firebase_data_source.dart';
import 'package:danventory/domain/db/supabase_db.dart';
import 'package:danventory/domain/entities/user_model.dart';
import 'package:danventory/domain/interfaces/iuser_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository implements IUserModel {
  final FirebaseDataSource _fDataSource = FirebaseDataSource();
  final _db = SupabaseDB();

  @override
  Future<String> create(UserModel t) async {
    try {
      UserCredential credential = await _fDataSource.auth
          .createUserWithEmailAndPassword(email: t.email, password: t.password);
      t.userIdAuth = credential.user!.uid;
      await _db.client.from("users").insert(t.toMap());

      return credential.user!.uid;
    } catch (e) {
      throw Exception("Problemas con el servidor");
    }
  }

  @override
  Future<bool> delete(UserModel t) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response =
          await _db.client.from("users").select().eq("userIdAuth", id).single();

      return UserModel.fromMap(response);
    } catch (e) {
      throw Exception("Problemas con el servidor: ${e.toString()}");
    }
  }

  @override
  Future<List<UserModel>> read(int readById) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _fDataSource.googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return false;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential credential =
          await _fDataSource.auth.signInWithCredential(authCredential);

      if (credential.user == null) {
        return false;
      }

      final List<dynamic> response = await _db.client
          .from('users')
          .select()
          .eq('userIdAuth', credential.user!.uid);

      if (response.isEmpty) {
        final UserModel userGoogle = UserModel(
          userIdAuth: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          password: "",
          userId: 0,
        );

        final List<dynamic> insertResponse =
            await _db.client.from('users').insert(userGoogle.toMap()).select();

        if (insertResponse.isNotEmpty) {
          throw Exception("Usuario insertado correctamente: $insertResponse");
        } else {
          throw Exception("No se pudo insertar el usuario.");
        }
      }
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception("Problemas con FirebaseAuth: $e");
    } on PostgrestException catch (e) {
      throw Exception("Error en Supabase: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<bool> update(UserModel t) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<UserModel> verifyUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _fDataSource.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception("No se pudo autenticar el usuario.");
      }

      String uid = userCredential.user!.uid;

      final response = await _db.client
          .from("users")
          .select()
          .eq("userIdAuth", uid)
          .single();

      UserModel user = UserModel.fromMap(response);
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("El usuario no está registrado.");
      } else if (e.code == 'wrong-password') {
        throw Exception("La contraseña es incorrecta.");
      } else {
        throw Exception("Error de autenticación: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<UserModel> recoverAccount(UserModel t, String newPassword) {
    // TODO: implement recoverAccount
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyEmail(String email) async {
    try {
      final response =
          await _db.client.from("users").select().eq("email", email);
      if (response.isEmpty) {
        return true;
      }
      throw Exception("Ya existe una cuenta con este correo.");
    } catch (e) {
      throw Exception("Problemas con el servidor: ${e.toString()}");
    }
  }
}
