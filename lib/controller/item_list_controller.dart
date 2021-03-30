import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_sample/controller/auth_controller.dart';
import 'package:riverpod_sample/models/item_model.dart';
import 'package:riverpod_sample/repositories/custom_exception.dart';
import 'package:riverpod_sample/repositories/item_repository.dart';

final itemListExceptionProvider = StateProvider<CustomException?>((_) => null);

final itemListControllerProvider =
    StateNotifierProvider<ItemListController>((ref) {
  final user = ref.watch(authControllerProvider.state);
  return ItemListController(ref.read, user?.uid);
});

class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  ItemListController(this._reader, this._userId)
      : super(const AsyncValue.loading());

  final Reader _reader;
  final String? _userId;

  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = const AsyncValue.loading();

    try {
      final items =
          await _reader(itemRepositoryProvider).retrieveItems(userId: _userId!);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } on CustomException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem({required String name, bool obtained = false}) async {
    try {
      final item = Item(name: name, obtained: obtained);
      final itemId = await _reader(itemRepositoryProvider)
          .createItem(userId: _userId!, item: item);
      state.whenData((items) =>
          state = AsyncValue.data(items..add(item.copyWith(id: itemId))));
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider).state = e;
    }
  }

  Future<void> updateItem({required Item updatedItem}) async {
    try {
      await _reader(itemRepositoryProvider)
          .updateItem(userId: _userId!, item: updatedItem);
      state.whenData((items) {
        state = AsyncValue.data([
          for (var item in items)
            if (item.id == updatedItem.id) updatedItem else item
        ]);
      });
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider).state = e;
    }
  }

  Future<void> deleteItem({required String itemId}) async {
    try {
      await _reader(itemRepositoryProvider)
          .deleteItem(userId: _userId!, itemId: itemId);
      state.whenData(
        (items) => state = AsyncData(
          items..removeWhere((item) => item.id == itemId),
        ),
      );
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider).state = e;
    }
  }
}
