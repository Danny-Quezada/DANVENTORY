
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

class FirebaseDataSource {

 FirebaseAuth get auth => FirebaseAuth.instance;
   GoogleSignIn get googleSignIn => GoogleSignIn();

  
}