import 'package:e_amazon/utils/shared_preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        "948737216499-0rlal03tl2q1jld87c41o9j7vub2ppo5.apps.googleusercontent.com",
  );

  Future<String> handleGoogleSignIn() async {
    try {
      await _googleSignIn.signOut();
      print("object");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Google sign-in failed";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;
      print("useree");

      if (user != null) {
        SharedPreferenceHelper.setUserId(user.uid);
        print("objecsasast");

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'phone': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return 'Success';
      }
      return "User not found";
    } on FirebaseAuthException catch (e) {
      print("errreeer");
      return _handleFirebaseError(e);
    } catch (e) {
      print("unkonw");
      print(e.toString());
      return "An unknown error occurred.";
    }
  }

  Future<String?> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        SharedPreferenceHelper.setUserId(user.uid);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user?.uid;
      if (userId != null) {
        SharedPreferenceHelper.setUserId(userId);
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  Future<void> addProduct() async {
    final collection = _fireStore.collection('products');

    final docRef = collection.doc(); // generate document ID
    final productId = docRef.id;

    final product = {
      'id': productId,
      'name': 'BULLMER',
      "description":
          "Men Floral Print Regular Fit Shirt , BULLMER Trendy Regular Fit Printed Causal Half sleeve Shirt For Men Wrinkle Free , Stretchable , Breathable , Maintenance free , trigene fabric , Soil Resistant",
      'price': "₹1,999 ",
      "images": [
        'https://assets.ajio.com/medias/sys_master/root/20240911/cPAa/66e0f0db6f60443f316d0646/-473Wx593H-700401877-cream-MODEL.jpg',
        'https://assets.ajio.com/medias/sys_master/root/20240911/UhtA/66e0f0db6f60443f316d05d1/-473Wx593H-700401877-cream-MODEL3.jpg',

        'https://assets.ajio.com/medias/sys_master/root/20240911/AiPM/66e0f0db6f60443f316d05ce/-473Wx593H-700401877-cream-MODEL5.jpg',

        'https://assets.ajio.com/medias/sys_master/root/20240911/AiPM/66e0f0db6f60443f316d05ce/-473Wx593H-700401877-cream-MODEL5.jpg',
      ],
      'review': 'Perfect!,Comfort to wear',
      'rating': "4.2",
      'specs': {
        'SLEEVE TYPE':
            'Short Sleeve. Designed to offer an energetic look, the shirt combines the warmth of comfortable and casual feel. Offering an elevated look, it showcases a perfect fit.',
        'ENHANCED STRETCH':
            "This enhanced stretch shirt provides maximum comfort and flexibility. Made with high-quality fabric, This shirt offers a tailored fit and modern design, perfect for any occasion. Upgrade your wardrobe with Campus Sutra's enhanced stretch shirts for a stylish and comfortable look.",
        'FABRICS':
            "his shirt is fabricated with top-grade and durable material. Made of fabric that holds its shape throughout the day, lets you have no restriction and feel relaxed.",
        "Package contains": "1 shirt",
      },
    };
    await docRef.set(product);
  }

  Future<void> _toggleProductInCollection(
    String userId,
    String productId,
    String collectionName,
  ) async {
    if (productId.isNotEmpty) {
      final productRef = _fireStore
          .collection(collectionName)
          .doc(userId)
          .collection('products')
          .doc(productId);

      final doc = await productRef.get();
      if (doc.exists) {
        await productRef.delete();
      } else {
        await productRef.set({'productId': productId});
      }
    }
  }

  Future<void> toggleWishlist(String userId, String productId) {
    return _toggleProductInCollection(userId, productId, 'wishlists');
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    required int count,
  }) async {
    final cartItemRef = FirebaseFirestore.instance
        .collection('saved_card')
        .doc(userId)
        .collection('products')
        .doc(productId);

    await cartItemRef.set({
      'count': count,
    }, SetOptions(merge: true)); // merges if item already exists
  }

  Future<void> incrementCartItem({
    required String userId,
    required String productId,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('saved_card')
        .doc(userId)
        .collection('products')
        .doc(productId);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({'count': FieldValue.increment(1)});
    } else {
      await docRef.set({'count': 1});
    }
  }

  Future<void> decrementCartItem({
    required String userId,
    required String productId,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('saved_card')
        .doc(userId)
        .collection('products')
        .doc(productId);

    final doc = await docRef.get();

    if (doc.exists) {
      int currentCount = doc['count'] ?? 1;

      if (currentCount > 1) {
        await docRef.update({'count': FieldValue.increment(-1)});
      } else {
        await docRef.delete();
      }
    }
  }

  /*
  Future<void> addToCard(String userId, String productId) {
    return _toggleProductInCollection(userId, productId, 'saved_card');
  }
*/

  Future<List<String>> getWishlistProductIds(String userId) async {
    final snapshot =
        await _fireStore
            .collection('wishlists')
            .doc(userId)
            .collection('products')
            .get();

    return snapshot.docs.map((doc) => doc['productId'] as String).toList();
  }
}
