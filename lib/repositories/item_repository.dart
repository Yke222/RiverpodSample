import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_sample/extensions/firebase_firestore_extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_sample/general_providers.dart';
import 'package:riverpod_sample/models/item_model.dart';
import 'package:riverpod_sample/repositories/custom_exception.dart';

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems({required String userId});
  Future<String> createItem({required String userId, required Item item});
  Future<void> updateItem({required String userId, required Item item});
  Future<void> deleteItem({required String userId, required String itemId});
}

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref.read));

class ItemRepository implements BaseItemRepository {
  const ItemRepository(this._reader);

  final Reader _reader;

  @override
  Future<List<Item>> retrieveItems({required String userId}) async {
    try {
      final snap =
          await _reader(firebaseFirestoreProvider).userListRef(userId).get();

      return snap.docs.map((doc) => Item.fromDocument(doc)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<String> createItem({
    required String userId,
    required Item item,
  }) async {
    try {
      final docRef = await _reader(firebaseFirestoreProvider)
          .userListRef(userId)
          .add(item.toDocument());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateItem({
    required String userId,
    required Item item,
  }) async {
    try {
      await _reader(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(item.id)
          .update(item.toDocument());
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteItem(
      {required String userId, required String itemId}) async {
    try {
      await _reader(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
