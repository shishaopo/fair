/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'package:fair_version/fair_version.dart';
import 'package:flutter/widgets.dart';

import '../app.dart';
import '../internal/global_state.dart';
import '../type.dart';
import '../utils.dart';
import '../widget.dart';

FairWidgetBinding provider = () {
  return {
    'FairWidget': (props) => FairWidget(
          name: props['type'],
          path: props['path'],
          data: props['data'],
        ),
    'Color': (props) {
      var color = pa0(props);
      return color is String ? FairUtils.fromHex(color) : Color(color);
    },
    'TextSpan': (props) => TextSpan(
          text: props['text'],
          children: as<InlineSpan>(props['children']),
          style: props['style'],
          recognizer: props['recognizer'],
          semanticsLabel: props['semanticsLabel'],
        ),
    'VoidCallback': (props) => () {
          var func = props['invoke'];
          assert(func is Function, '$func should provide as Function');
          var result = func();
          if (result != null) {
            log('[Fair] result of $func is ignored');
          }
        },
    'Navigator.pushNamed': (props) => () {
          // ignore p0 => context string
          var context = $(props);
          var route = FairApp.of(context)?.routeBuilder;
          if (route != null) {
            route(context, pa1(props), arguments: props['arguments']);
            return null;
          }
          return Navigator.of(context).pushNamed(
            pa1(props),
            arguments: props['arguments'],
          );
        },
    'Navigator.popAndPushNamed': (props) => () {
          var context = $(props);
          var route = FairApp.of(context)?.routeBuilder;
          if (route != null) {
            route(context, pa0(props), arguments: props['arguments']);
            return null;
          }
          return Navigator.of(context).popAndPushNamed(
            pa0(props),
            arguments: props['arguments'],
          );
        },
    'SimpleTextItemBuilder': (props) => (text) => Text(text),
    'double.infinity': double.infinity,
  };
};
