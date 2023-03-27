
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

  final GoogleSignIn? googleSignIn = GoogleSignIn(scopes: <String>["email"]);
  
  Future<void> sigInWithGoogle() async{
    final GoogleSignInAccount? googleUser = await googleSignIn!.signIn();

    print(googleUser);
    if(googleUser!=null){
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      print(credential);
    }

    await googleSignIn!.signOut();


  }

  


}