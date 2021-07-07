/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/widgets.dart';

import 'internal/error_tips.dart';
import 'render/decode.dart';

class Loader {
  Decoder? _decoder;

  Future<Widget> parse(BuildContext context,
      {required String page,
      required String? url,
      required Map<String, dynamic>? data}) async {
    // Cache decoder for same state instance
    if (_decoder == null) {
      _decoder = Decoder(page, url: url, dataSource: data);
      await _decoder!.resolve(context);
    }
    Widget widget;
    try {
      widget = _decoder!.toWidget(context);
      return widget;
    } catch (e) {
      widget = WarningWidget(name: page, url: url, error: e);
    }
    return widget;
  }
}
