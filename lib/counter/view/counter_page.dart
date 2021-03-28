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
    );
  }
}
