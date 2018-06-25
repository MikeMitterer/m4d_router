library url_template;

import 'url_matcher.dart';
import 'utils/map_utils.dart';

final _specialChars = new RegExp(r'[\\()$^.+[\]{}|]');
final _paramPattern = r'([^/?]+)';
final _paramWithSlashesPattern = r'([^?]+)';

/// A reversible URL template class that can match/parse and reverse URL
/// templates like: /foo/:bar/baz
class UrlTemplate {

    /// Template
    final String _rawTemplate;

    /// Parameter names of the template ie  `['bar']` for `/foo/:bar/baz`
    List<String> _fields;

    /// The compiled template
    RegExp _pattern;

    ///  The template exploded as parts
    ///  - even indexes contain text
    ///  - odd indexes contain closures that return the parameter value
    ///
    ///  `/foo/:bar/baz` produces:
    ///  - [0] = `/foo/`
    ///  - [1] = `(p) => p['bar']`
    ///  - [2] = `/baz`
    List _chunks;

    UrlTemplate(this._rawTemplate) {
        _compileTemplate(_rawTemplate);
    }

    @override
    String toString() => 'UrlTemplate($_pattern)';

    UrlMatch match(final String url) {
        Match match = _pattern.firstMatch(url);
        if (match == null) {
            return null;
        }
        var parameters = new Map();
        for (var i = 0; i < match.groupCount; i++) {
            parameters[_fields[i]] = match[i + 1];
        }
        var tail = url.substring(match[0].length);
        return new UrlMatch(match[0], tail, parameters);
    }

    /// Replaces params in given template with [params]
    String construct({final Map params = const {}, final String tail = ''}) {
        return _chunks.map((final chunk) => chunk is Function ? chunk(params) : chunk).join() +
            tail;
    }

    List<String> get urlParameterNames => _fields;

    @override
    bool operator ==(final Object other) {
        if (identical(this, other)) {
            return true;
        }

        if (other is UrlTemplate) {
            return runtimeType == other.runtimeType &&
                isListEqual(_fields,other._fields) &&
                _pattern == other._pattern &&
                isListEqual(_chunks,other._chunks);
        }

        if (other is String) {
            final temp = new UrlTemplate(other);
            return _pattern == temp._pattern;
        }

        return false;
    }

    @override
    int get hashCode => _fields.hashCode ^ _pattern.hashCode ^ _chunks.hashCode;

    // - private -------------------------------------------------------------------------------------

    void _compileTemplate(final String rawTemplate) {
        // Escape special characters
        final template = rawTemplate.replaceAllMapped(_specialChars, (m) => r'\' + m[0]);

        _fields = <String>[];
        _chunks = [];

        final exp = new RegExp(r':(\w+\*?)');
        StringBuffer buffer = new StringBuffer('^');
        int start = 0;
        exp.allMatches(template).forEach((Match m) {
            final paramName = m[1];
            final txt = template.substring(start, m.start);

            _fields.add(paramName);
            _chunks.add(txt);
            _chunks.add((final Map params) {
                if (!params.containsKey(paramName)) {
                    throw new ArgumentError("'$paramName' not available for $rawTemplate");
                }
                return params[paramName];
            });

            buffer.write(txt);
            if (paramName.endsWith(r'*')) {
                buffer.write(_paramWithSlashesPattern);
            }
            else {
                buffer.write(_paramPattern);
            }

            start = m.end;
        });

        if (start != template.length) {
            final txt = template.substring(start, template.length);
            buffer.write(txt);
            _chunks.add(txt);
        }

        _pattern = new RegExp (buffer.toString());
    }
}
