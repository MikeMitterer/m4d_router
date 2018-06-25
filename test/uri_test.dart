// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'package:test/test.dart';

import 'package:uri/uri.dart';
import 'package:console_log_handler/print_log_handler.dart';


main() {
    final Logger _logger = new Logger('test.uri_test');

    configLogging(show: Level.INFO);

    group("UriTemplat", () {
        test('should return URL with replaced params', () {
            var template = new UriTemplate("http://example.com/{username}/");
            expect(template.expand({"username" : "Mike"}), "http://example.com/Mike/");

            template = new UriTemplate("/{username}");
            expect(template.expand({"username" : "Mike"}), "/Mike");
        });
    });

    group("UriPattern", () {
        test('should match', () {
            final template = new UriTemplate("/#/names/{username}");
            final parser = new UriParser(template,fragmentPrefixMatching: true);

            final uri = Uri.parse("/#/names/Mike/");
            print("T ${uri.path}");

            final Map<String,String> values = parser.parse(uri);
            expect(values.length, 1);
        }); // end of '' test

    });
}
