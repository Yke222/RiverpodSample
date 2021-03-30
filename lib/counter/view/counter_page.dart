// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_sample/controller/auth_controller.dart';
import 'package:riverpod_sample/controller/item_list_controller.dart';
import 'package:riverpod_sample/models/item_model.dart';
import 'package:riverpod_sample/repositories/custom_exception.dart';

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider.state);
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Shopping list')),
        leading: authControllerState != null
            ? IconButton(
                icon: const Icon(Icons.logout),
                onPressed: context.read(authControllerProvider).signOut,
              )
            : null,
      ),
      body: ProviderListener(
        provider: itemListExceptionProvider,
        onChange: (
          BuildContext context,
          StateController<CustomException?> customException,
        ) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(customException.state!.message!),
            ),
          );
        },
        child: const ItemList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddItemDialog.show(context, Item.empty()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddItemDialog extends HookWidget {
  const AddItemDialog({
    Key? key,
    required this.item,
  }) : super(key: key);

  static void show(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(item: item),
    );
  }

  final Item item;

  bool get isUpdating => item.id != null;

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: item.name);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Item name'),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: isUpdating
                      ? Colors.orange
                      : Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  isUpdating
                      ? context.read(itemListControllerProvider).updateItem(
                            updatedItem: item.copyWith(
                              name: textController.text.trim(),
                              obtained: item.obtained,
                            ),
                          )
                      : context
                          .read(itemListControllerProvider)
                          .addItem(name: textController.text.trim());
                  Navigator.of(context).pop();
                },
                child: Text(isUpdating ? 'Update' : 'Add'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

final currentItem = ScopedProvider<Item>((_) => throw UnimplementedError());

class ItemList extends HookWidget {
  const ItemList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemListState = useProvider(itemListControllerProvider.state);
    return itemListState.when(
      data: (items) => items.isEmpty
          ? const Center(
              child: Text(
                'Tap + to add an item',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ProviderScope(
                  overrides: [currentItem.overrideWithValue(item)],
                  child: const ItemTile(),
                );
              },
            ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => ItemListError(
        message:
            error is CustomException ? error.message! : 'Something went wrong!',
      ),
    );
  }
}

class ItemTile extends HookWidget {
  const ItemTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = useProvider(currentItem);

    return ListTile(
      key: ValueKey(item.id),
      title: Text(item.name),
      trailing: Checkbox(
        value: item.obtained,
        onChanged: (val) => context.read(itemListControllerProvider).updateItem(
              updatedItem: item.copyWith(obtained: !item.obtained),
            ),
      ),
      onTap: () => AddItemDialog.show(context, item),
      onLongPress: () =>
          context.read(itemListControllerProvider).deleteItem(itemId: item.id!),
    );
  }
}

class ItemListError extends StatelessWidget {
  const ItemListError({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: const TextStyle(fontSize: 20.0),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () => context
              .read(itemListControllerProvider)
              .retrieveItems(isRefreshing: true),
          child: const Text('Retry'),
        ),
      ],
    ));
  }
}
