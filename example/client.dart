// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library example;

import 'dart:html';
import 'package:route/browser.dart';
import 'package:logging/logging.dart';
import 'urls.dart' as urls;

main() {
  Logger.root
      ..level = Level.FINEST
      ..onRecord.listen((LogRecord r) { print(r.message); });

  querySelector('#warning').remove();
  querySelector('#one').classes.add('selected');

  new Router()
      ..addRoute(urls.one, showOne)
      ..addRoute(urls.two, showTwo)
      ..addRoute(urls.home, (_) => null)
      ..listen();
}

void showOne(String path) {
  print("showOne");
  querySelector('#one').classes.add('selected');
  querySelector('#two').classes.remove('selected');
}

void showTwo(String path) {
  print("showTwo");
  querySelector('#one').classes.remove('selected');
  querySelector('#two').classes.add('selected');
}
