library route.url_template_test;

import 'package:test/test.dart';

import 'package:console_log_handler/print_log_handler.dart';

import 'package:route/url_template.dart';
import 'package:route/url_matcher.dart';

main() {
    configLogging(show: Level.INFO);

    group('UrlTemplate', () {
        test('should return URL with replaced params', () {
            final template = new UrlTemplate('/foo/bar:baz/aux');
            expect(template.construct(params: { "baz" : "Mike"}), "/foo/barMike/aux");
        });

        test('should throw ArgumentException if param is not availalbe', () {
            final template = new UrlTemplate('/foo/bar:baz/aux');
            expect(() => template.construct(), throwsArgumentError);
        });

        test('should return template if template has no param defined', () {
            final template = new UrlTemplate('/foo/bar/aux');
            expect(template.construct(), '/foo/bar/aux');
        });

        test('should be equal', () {
            expect(new UrlTemplate('/foo/bar/aux') == '/foo/bar/aux', isTrue);
            expect(new UrlTemplate('/foo/bar/aux') == new UrlTemplate('/foo/bar/aux'), isTrue);
            expect(new UrlTemplate('/foo/bar:param/aux') == '/foo/bar:param/aux', isTrue);
            expect(new UrlTemplate('/foo/bar:param/aux') == new UrlTemplate('/foo/bar:param/aux'), isTrue);
            expect(new UrlTemplate('/foo/bar:p1*/aux') == '/foo/bar:p1*/aux', isTrue);
            expect(new UrlTemplate('/foo/bar:p1*/aux') == new UrlTemplate('/foo/bar:p1*/aux'), isTrue);
        }); // end of '' test


        test('should work with simple templates', () {
            var template = new UrlTemplate('/foo/bar:baz/aux');
            expect( template.construct(params: {'baz': '123'}), '/foo/bar123/aux' );

            template = new UrlTemplate('/foo/:bar');
            expect(template.construct(params: {'bar': '123'}), '/foo/123');

            template = new UrlTemplate('/:foo/bar');
            expect(template.construct(params: {'foo': '123'}), '/123/bar');

            template = new UrlTemplate('/user/:userId/article/:articleId/view');

            expect(
                template.construct(params: {'userId': 'jsmith', 'articleId': '1234'}, tail: '/someotherstuff'),
                '/user/jsmith/article/1234/view/someotherstuff'
            );

            template = new UrlTemplate(r'/foo/:bar$123/aux');
            expect(template.construct(params: {'bar': '123'}), r'/foo/123\$123/aux');
        });

        test('should work with wildcards', () {
            final template = new UrlTemplate('/foo/:bar');
            expect(template.construct(params: {'bar': '123'}), '/foo/123');
        }); // end of '' test


        test('should work with special characters', () {
            var template = new UrlTemplate(r'\^\|+[]{}()');
            expect(template.construct(), r'\^\|+[]{}()');

            template = new UrlTemplate(r'/:foo/^\|+[]{}()');
            expect(template.construct(params: {'foo': '123'}), r'/123/^\|+[]{}()');
        },skip: true);

        test('should only match prefix', () {
            var template = new UrlTemplate(r'/foo');
            expect(template.match(r'/foo/foo/bar'), new UrlMatch(r'/foo', '/foo/bar', {}));
        });

        test('should match without leading slashes', () {
            var template = new UrlTemplate(r'foo');
            expect(template.match(r'foo'), new UrlMatch(r'foo', '', {}));
        });

        test('should construct', () {
            var template = new UrlTemplate('/:a/:b/:c');
            expect(() => template.construct(), throwsArgumentError); // was '/null/null/null'
            expect(template.construct(params: {'a': 'foo', 'b': 'bar', 'c': 'baz'}), '/foo/bar/baz');

            template = new UrlTemplate(':a/bar/baz');
            expect(() => template.construct(), throwsArgumentError); // was 'null/bar/baz'
            expect(
                template.construct(params: {
                    'a': '/foo',
                }),
                '/foo/bar/baz');

            template = new UrlTemplate('/foo/bar/:c');
            expect(() => template.construct(), throwsArgumentError); // was '/foo/bar/null'
            expect(
                template.construct(params: {
                    'c': 'baz',
                }),
                '/foo/bar/baz');

            template = new UrlTemplate('/foo/bar/:c');
            expect(
                template.construct(tail: '/tail', params: {
                    'c': 'baz',
                }),
                '/foo/bar/baz/tail');
        });

        test('should conditionally allow slashes in parameters', () {
            var template = new UrlTemplate('/foo/:bar');
            expect(template.match('/foo/123/456'), new UrlMatch('/foo/123', '/456', {'bar': '123'}));

            template = new UrlTemplate('/foo/:bar*');
            expect(
                template.match('/foo/123/456'), new UrlMatch('/foo/123/456', '', {'bar*': '123/456'})
            );

            expect(
                template.match('/foo/123/456'), new UrlMatch('/foo/', '', {})
            );

            template = new UrlTemplate('/foo/:bar*/baz');
            expect(template.match('/foo/123/456/baz'),
                new UrlMatch('/foo/123/456/baz', '', {'bar*': '123/456'}));
        });
    });
}
