/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../app.dart';
import '../type.dart';
import 'fair_decoder.dart';
import 'global_state.dart';

class FairBundle {
  BundleLoader? _provider;

  BundleLoader obtain(BuildContext context) {
    _provider ??= FairApp.of(context)?.bundleProvider ?? _DefaultProvider();
    return _provider!;
  }
}

class _DefaultProvider extends BundleLoader {
  var client = http.Client();
  static const JSON = '.json';
  static const FLEX = '.bin';

  @override
  Future<Map?> onLoad(String? path, FairDecoder decoder,
      {bool cache = true, Map<String, String>? h}) {
    if (path == null) {
      return Future.value(null);
    }
    bool isFlexBuffer;
    if (path.endsWith(FLEX)) {
      isFlexBuffer = true;
    } else if (path.endsWith(JSON)) {
      isFlexBuffer = false;
    } else {
      throw ArgumentError(
          'unknown format, please use either $JSON or $FLEX;\n $path');
    }
    if (path.startsWith('http')) {
      return _http(path, isFlexBuffer, headers: h, decode: decoder);
    }
    return _asset(path, isFlexBuffer, cache: cache, decode: decoder);
  }

  Future<Map?> _asset(String key, bool isFlexBuffer,
      {bool cache = true, FairDecoder? decode}) async {
    var watch = Stopwatch()..start();
    int end, end2;
    Map? map;
    if (isFlexBuffer) {
      var data = await rootBundle.load(key);
      end = watch.elapsedMilliseconds;
      map = await decode?.decode(data.buffer.asUint8List(), isFlexBuffer);
      end2 = watch.elapsedMilliseconds;
    } else {
      var data = await rootBundle.loadString(key, cache: cache);
      end = watch.elapsedMilliseconds;
      map = await decode?.decode(data, isFlexBuffer);
      end2 = watch.elapsedMilliseconds;
    }

    log('[Fair] $key load: $end ms, stream decode: $end2 ms');
    return map;
  }

  Future<Map?> _http(String url, bool isFlexBuffer,
      {Map<String, String>? headers, FairDecoder? decode}) async {
    var start = DateTime.now().millisecondsSinceEpoch;
    var response = await client.get(Uri.parse(url), headers: headers);
    var end = DateTime.now().millisecondsSinceEpoch;
    if (response.statusCode != 200) {
      throw FlutterError('code=${response.statusCode}, unable to load : $url');
    }
    var data = response.bodyBytes;
    if (data == null) {
      throw FlutterError('bodyBytes=null, unable to load : $url');
    }
    Map? map;
    map = await decode?.decode(data, isFlexBuffer);
    var end2 = DateTime.now().millisecondsSinceEpoch;
    log('[Fair] load $url, time: ${end - start} ms, json parsing time: ${end2 - end} ms');
    return map;
  }
}
