// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library route.url_pattern;

// From the PatternCharacter rule here:
// http://ecma-international.org/ecma-262/5.1/#sec-15.10
// removed '( and ')' since we'll never escape them when not in a group
final _specialChars = new RegExp(r'[\^\$\.\|\+\[\]\{\}]');

UrlPattern urlPattern(final String pattern) => new UrlPattern(pattern);

/// A pattern, similar to a [RegExp], that is designed to match against URL
/// paths, easily return groups of a matched path, and produce paths from a list
/// of arguments - this is they are "reversible".
///
/// `UrlPattern`s also allow for handling plain paths and URLs with a fragment in
/// a uniform way so that they can be used for client side routing on browsers
/// that support `window.history.pushState` as well as legacy browsers.
///
/// The differences from a plain [RegExp]:
/// All non-literals must be in a group. Everything outside of a groups is
/// considered a literal and special regex characters are escaped.
/// There can only be one match, and it must match the entire string. `^` and
/// `$` are automatically added to the beginning and end of the pattern,
/// respectively.
///
/// The pattern must be un-ambiguous, eg `(.///)(.///)` is not allowed at the
/// top-level.
///
/// The hash character (#) matches both '#' and '/', and it is only allowed
/// once per pattern. Hashes are not allowed inside groups.
///
/// With those differences, `UrlPatterns` become much more useful for routing
/// URLs and constructing them, both on the client and server. The best practice
/// is to define your application's set of URLs in a shared library.
///
/// urls.dart:
///
///     library urls;
///
///     final articleUrl = new UrlPattern(r'/articles/(\d+)');
///
/// Use with older browsers
/// -----------------------
///
/// Since '#' matches both '#' and '/' it can be used in as a path separator
/// between the "static" portion of your URL and the "dynamic" portion. The
/// dynamic portion would be the part that change when a user navigates to new
/// data that's loaded dynamically rather than loading a new page.
///
/// In newer browsers that support `History.pushState()` an entire new path can
/// be pushed into the location bar without reloading the page. In older browsers
/// only the fragment can be changed without reloading the page. By matching both
/// characters, and by producing either, we can use pushState in newer browsers,
/// but fall back to fragments when necessary.
///
/// Examples:
///
///     var pattern = new UrlPattern(r'/app#profile/(\d+)');
///     pattern.matches('/app/profile/1234'); // true
///     pattern.matches('/app#profile/1234'); // true
///     pattern.expand([1234], useFragment: true); // /app#profile/1234
///     pattern.expand([1234], useFragment: false); // /app/profile/1234
///
class UrlPattern implements Pattern {
    final String pattern;
    RegExp _regex;
    bool _hasFragment;
    RegExp _baseRegex;

    UrlPattern(this.pattern) {
        _parse(pattern);
    }

    RegExp get regex => _regex;

    /// Replaces pattern-groups with args
    String expand(final Iterable args, { final bool useFragment: false }) {
        final buffer = new StringBuffer();
        var chars = pattern.split('');
        var argsIter = args.iterator;

        int depth = 0;
        int groupCount = 0;
        bool escaped = false;

        for (int i = 0; i < chars.length; i++) {
            var c = chars[i];
            if (c == '\\' && escaped == false) {
                escaped = true;
            }
            else {
                if (c == '(') {
                    if (escaped && depth == 0) {
                        buffer.write(c);
                    }
                    if (!escaped) {
                        depth++;
                    }
                }
                else if (c == ')') {
                    if (escaped && depth == 0) {
                        buffer.write(c);
                    }
                    else if (!escaped) {
                        if (depth == 0) throw new ArgumentError('unmatched parentheses');
                        
                        depth--;
                        if (depth == 0) {
                            // append the nth arg
                            if (argsIter.moveNext()) {
                                buffer.write(argsIter.current.toString());
                            }
                            else {
                                throw new ArgumentError('more groups than args');
                            }
                        }
                    }
                }
                else if (depth == 0) {
                    if (c == '#' && !useFragment) {
                        buffer.write('/');
                    }
                    else {
                        buffer.write(c);
                    }
                }
                escaped = false;
            }
        }
        if (depth > 0) {
            throw new ArgumentError('unclosed group');
        }
        return buffer.toString();
    }

    /// Parses a URL path, or path + fragment, and returns the group matches.
    /// Throws [ArgumentError] if this pattern does not match [path].
    List<String> parse(final String path) {
        var match = regex.firstMatch(path);
        if (match == null) {
            throw new ArgumentError('no match for $path');
        }
        var result = <String>[];
        for (int i = 1; i <= match.groupCount; i++) {
            result.add(match[i]);
        }
        return result;
    }

    /// Returns true if this pattern matches [path].
    bool matches(final String str) => _matches(regex, str);

    Match matchAsPrefix(final String string, [final int start = 0]) => regex.matchAsPrefix(string, start);

    /// Returns true if the path portion of the pattern, the part before the
    /// fragment, matches [str]. If there is no fragment in the pattern, this is
    /// equivalent to calling [matches].
    ///
    /// This method is most useful on a server that is serving the HTML of a
    /// single page app. Clients that don't support pushState will not send the
    /// fragment to the server, so the server will have to handle just the path
    /// part.
    bool matchesNonFragment(final String str) {
        if (!_hasFragment) {
            return matches(str);
        }
        else {
            return _matches(_baseRegex, str);
        }
    }

    @override
    Iterable<Match> allMatches(String str, [int start = 0]) {
        return regex.allMatches(str);
    }

    bool operator ==(other) => (other is UrlPattern) && (other.pattern == pattern);

    int get hashCode => pattern.hashCode;

    String toString() => pattern.toString();

    // - private -----------------------------------------------------------------------------------

    bool _matches(final Pattern p,final String str) {
        final iter = p.allMatches(str).iterator;
        if (iter.moveNext()) {
            var match = iter.current;
            return (match.start == 0) && (match.end == str.length) && (!iter.moveNext());
        }
        return false;
    }

    _parse(final String pattern) {
        final buffer = new StringBuffer();
        int depth = 0;
        int lastGroupEnd = -2;
        bool escaped = false;

        buffer.write('^');
        var chars = pattern.split('');
        for (var i = 0; i < chars.length; i++) {
            var c = chars[i];

            if (depth == 0) {
                // outside of groups, transform the pattern to matches the literal
                if (c == r'\') {
                    if (escaped) {
                        buffer.write(r'\\');
                    }
                    escaped = !escaped;
                }
                else {
                    if (_specialChars.hasMatch(c)) {
                        buffer.write('\\$c');
                    }
                    else if (c == '(') {
                        if (escaped) {
                            buffer.write(r'\(');
                        }
                        else {
                            buffer.write('(');
                            if (lastGroupEnd == i - 1) {
                                throw new ArgumentError('ambiguous adjecent top-level groups');
                            }
                            depth = 1;
                        }
                    }
                    else if (c == ')') {
                        if (escaped) {
                            buffer.write(r'\)');
                        }
                        else {
                            throw new ArgumentError('unmatched parenthesis');
                        }
                    }
                    else if (c == '#') {
                        _setBasePattern(buffer.toString());
                        buffer.write('[/#]');
                    }
                    else {
                        buffer.write(c);
                    }
                    escaped = false;
                }
            }
            else {
                // in a group, don't modify the pattern, but track escaping and depth
                if (c == '(' && !escaped) {
                    depth++;
                }
                else if (c == ')' && !escaped) {
                    depth--;
                    if (depth < 0) throw new ArgumentError('unmatched parenthesis');
                    if (depth == 0) {
                        lastGroupEnd = i;
                    }
                }
                else if (c == '#') {
                    throw new ArgumentError('illegal # inside group');
                }
                escaped = (c == r'\' && !escaped);
                buffer.write(c);
            }
        }
        buffer.write(r'$');
        try {
            _regex = new RegExp(buffer.toString());

        } on FormatException catch(e) {
            throw new ArgumentError(e);
        }
    }

    _setBasePattern(final String basePattern) {
        if (_hasFragment == true) {
            throw new ArgumentError('multiple # characters');
        }
        _hasFragment = true;
        _baseRegex = new RegExp('$basePattern\$');
    }
}

/// If pattern starts with / and has no hash [ReactPattern]
/// automatically prefixes [pattern] with '/#'
///
///     var pattern = new ReactPattern(r'/test');
///     expect(pattern.matches('/#/test'), true);
///     
class ReactPattern extends UrlPattern {
  ReactPattern(final String pattern)
      : super(!pattern.contains("#") && pattern.startsWith("/") ? "/#$pattern" : pattern );
}
