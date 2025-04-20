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

      if (user != null) {
        SharedPreferenceHelper.setUserId(user.uid);

        final userData = {
          'email': user.email,
          'name': user.displayName,
          if (user.phoneNumber != null) 'phone': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDocRef.get();
        if (!docSnapshot.exists) {
          await userDocRef.set(userData);
        } else {
          await userDocRef.set(userData, SetOptions(merge: true));
        }

        return 'Success';
      }
      return "User not found";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  Future<String?> register(String email,
      String password,
      String name,
      String phone,) async {
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

      return null;
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

    final docRef = collection.doc();
    final productId = docRef.id;

    final product = {
      'id': productId,
      'name': 'Casio watch',
      "description":
      "Casio is an electronics manufacturing company that was founded in 1946 by Tadao Kashio. The brand has a versatile portfolio, from musical instruments and digital cameras to analogue and digital watches. The company rose to popularity quickly after releasing its first-ever product, a cigarette holder, which proved to be a huge success. Casio became involved in electronics in 1954 when they released Japan's first electro-mechanical calculator.",
      'price': "29999 ",
      "images": [
        "https://www.casio.com/in/watches/edifice/product.EFB-109D-2AV/",
        "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRHojAC-y2pQTgvNyeVsKG1UiI9UaQrcNYJDnl0ilUoFB-sG_mx1RQ6kpyWNfinrBZIom4SHf2lUCRoiqSzqh0f6nuKMLKA_jg-af3zWGplN2_SFJb6gg8tdlo",
        "https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcRw0TYpozfwSQ6adpwck69Lqq350IUoAPwMXmAziR9LR-3cnGJxtOYYI3YdSep-rsgEe5fYSVHOLqNkTOSjHPzADWb0iCY_Ina3IHcA8DfQ",
        "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQDjiHN3PJGVIoaHDklkjLrV2BRRMsKywHUDbrPkp1iSB9PPAJ6_VtRU9i-9TFNJBcJsIaBTXa6xjY1mBgBpkzJRng9CtRMZUblxyDscWbdll2JNcT9d_Pz9Q",
      ],
      'review': 'Light weighted!',
      'rating': "3.0",
      'specs': {
        'Brand': 'Casio',
        'Model': 'EFB-109D-2AV',
        'Brand Color': "Black",
        'Weight': '127g',
        'Water resistance': '100-meter water resistance',
        'Case and bezel material': 'Stainless steel',
      },
    };
    await docRef.set(product);
  }

  Future<void> addHomeData() async {
    /*    final collection = _fireStore.collection('home_data');

    final docRef = collection.doc();
    final productId = docRef.id;*/

    final List<Map<String, dynamic>> homeItems = [
      {
        'image':
        'https://images-eu.ssl-images-amazon.com/images/G/31/img22/Wireless/devjyoti/GW/Uber/Nov/uber_new_high._CB537689643_.jpg',
      },
      {
        'image':
        "https://images-eu.ssl-images-amazon.com/images/G/31/OHL/24/BAU/feb/PC_hero_1_2x_1._CB582889946_.jpg",
      },
      {
        'image':
        'https://images-eu.ssl-images-amazon.com/images/G/31/img22/Events/Schoolfromhome/GWhero/1242x600_Eng._CB661597880_.jpg',
      },
      {
        'image':
        "https://images-eu.ssl-images-amazon.com/images/G/31/img24/Beauty/Hero/Shampoos__conditioners_pc._CB547405360_.png                                                                                                                                                                                                                                                                                                                                                                                                                                                 ",
      },
    ];
    await addHomeData1(homeItems);
  }

  Future<void> addHomeData1(List<Map<String, dynamic>> items) async {
    try {
      final collection = _fireStore.collection('home_data');
      final batch = _fireStore.batch();

      for (var item in items) {
        final docRef = collection.doc();
        final product = {'id': docRef.id, 'image': item['image'] ?? ''};
        batch.set(docRef, product);
      }

      await batch.commit();
      print('Successfully added ${items.length} items to home_data');
    } catch (e) {
      print('Error adding home_data: $e');
      rethrow;
    }
  }

  Future<void> toggleProductInCollection(String userId,
      String productId,
      String collectionName,) async {
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
    return toggleProductInCollection(userId, productId, 'wishlists');
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

    await cartItemRef.set({'count': count}, SetOptions(merge: true));
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
