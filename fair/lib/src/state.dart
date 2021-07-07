/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'package:fair_version/fair_version.dart';

import 'internal/bind_data.dart';
import 'internal/global_state.dart';
import 'module/module_registry.dart';
import 'public_type.dart';
import 'render/base.dart';
import 'render/proxy.dart';
import 'widget.dart';

mixin AppState {
  final modules = FairModuleRegistry();
  final bindData = <String, BindingData>{};
  final _proxy = ProxyMirror();

  P get proxy => _proxy;

  void setup(
    bool profile,
    Map<String, FairDelegateBuilder>? builder,
    GeneratedModule? generated,
    Map<String, FairModuleBuilder>? module,
  ) {
    modules.addAll(module);
    GlobalState.instance().init(profile, builder);
    _proxy.addGeneratedBinding(generated);
  }

  void register(FairState state) {
    log('register state: ${state.state2key}');
    var delegate = state.delegate;
    bindData.putIfAbsent(
      state.state2key,
      () => BindingData(
        modules,
        functions: delegate?.bindFunction(),
        values: delegate?.bindValue(),
      ),
    );
  }

  void unregister(FairState state) {
    var key = state.state2key;
    log('unregister state: $key');
    bindData.remove(key)?.clear();
  }
}
