// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library route.url_pattern_test;

import 'package:test/test.dart';
import 'package:m4d_router/url_pattern.dart';

main() {
    test('patterns with no groups', () {
        checkPattern('/', '/', [], ['', 'a', '/a']);
        checkPattern('a', 'a', [], ['', '/', '/a']);
    });

    test('patterns with basic groups', () {
        checkPattern(r'(\w+)', 'ab', ['ab'], ['(ab)', '', ' ']);
    });

    test('patterns with escaping', () {
        checkPattern(r'\\', r'\', []);
        // it's ok to leave a hanging escape?
        checkPattern(r'\\\', r'\', []);
        checkPattern(r'\a', r'a', []);
        checkPattern(r'\(a\)', '(a)', [], ['a']);
        checkPattern(r'(a\))', 'a)', ['a)'], ['a']);
        checkPattern(r'(\\w)', r'\w', [r'\w'], [r'\a']);
    });

    test('patterns with more complicated groups', () {
        checkPattern(r'/(\w+)', '/foo', ['foo'], ['foo']);
        checkPattern(r'/(\w+)/(\w+)', '/foo/bar', ['foo', 'bar']);
        // these are odd cases. maybe we should ban nested groups.
        checkPattern(r'((\w+))', 'a', ['a', 'a'], ['(a)']);
        checkPattern(r'((\w+)(\d+))', 'a1', ['a1', 'a', '1'], ['(a1)']);
    });

    test('disallow ambiguous groups', () {
        expect(() => new UrlPattern(r'(\w+)(\w+)'), throwsArgumentError);
        expect(new UrlPattern(r'(\w+)/(\w+)'), isNot(throwsArgumentError));
    });

    test('disallow unmatched parens', () {
        expect(() => new UrlPattern('('), throwsArgumentError);
        expect(() => new UrlPattern(')'), throwsArgumentError);
        expect(() => new UrlPattern('(()'), throwsArgumentError);
        expect(() => new UrlPattern('())'), throwsArgumentError);
    });

    test('patterns with fragments matches hash and path URLs', () {
        var pattern = new UrlPattern(r'/foo#(\w+)');
        expect(pattern.matches('/foo#abc'), true);
        expect(pattern.matches('/foo/abc'), true);
        expect(pattern.expand(['abc'], useFragment: true), '/foo#abc');
        expect(pattern.expand(['abc'], useFragment: false), '/foo/abc');
    });


    test('special chars outside groups', () {
        checkPattern('^', '^', []);
        checkPattern(r'$', r'$', []);
        checkPattern('.', '.', [], ['a']);
        checkPattern('|', '|', [], ['a']);
        checkPattern('+', '+', [], ['a']);
        checkPattern('[', '[', [], ['a']);
        checkPattern(']', ']', [], ['a']);
        checkPattern('{', '{', [], ['a']);
        checkPattern('}', '}', [], ['a']);
    });

    test('matchesNonFragment() only matches the path', () {
        var pattern = new UrlPattern(r'/foo#(\w+)');
        expect(pattern.matches('/foo'), false);
        expect(pattern.matchesNonFragment('/foo'), true);
        expect(() {
            new UrlPattern(r'(#)');
        }, throwsArgumentError);
        expect(() {
            new UrlPattern(r'##');
        }, throwsArgumentError);
    });

    group("ReactPattern", () {
        test('should automatically add /# prefix', () {
            var pattern = new ReactPattern(r'/test');
            expect(pattern.matches('/#/test'), true);
            expect(pattern.matches('/test'), false);
        });

        test('should add no prefix if hash already exists', () {
            var pattern = new ReactPattern(r'/foo#(\w+)');
            expect(pattern.matches('/foo#abc'), true);
            expect(pattern.matches('/foo/abc'), true);
            expect(pattern.expand(['abc'], useFragment: true), '/foo#abc');
            expect(pattern.expand(['abc'], useFragment: false), '/foo/abc');

            pattern = new ReactPattern(r'/foo#/(\w+)');
            expect(pattern.matches('/foo#/abc'), true);
            expect(pattern.matches('/foo//abc'), true);
            expect(pattern.expand(['abc'], useFragment: true), '/foo#/abc');
            expect(pattern.expand(['abc'], useFragment: false), '/foo//abc');

        });

    });
}

/**
 * Performs the following checks on a UrlPattern constructed from [p]:
 *  * [url] matches the pattern.
 *  * Using the pattern to parse [url] produces the arguments in [args].
 *  * Reversing the pattern with [args] produces the String [url].
 *  * None of the Strings in [nonMatches] match the pattern.
 */
checkPattern(final String p,final String url,final List args, [final List nonMatches]) {
    final pattern = new UrlPattern(p);

    expect(pattern.matches(url), true);
    expect(pattern.expand(args), url);
    expect(pattern.parse(url), orderedEquals(args));

    if (nonMatches != null) {
        for (var url in nonMatches) {
            expect(pattern.matches(url), false);
        }
    }
}
