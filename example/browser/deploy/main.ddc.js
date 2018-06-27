define(['dart_sdk', 'packages/logging/logging', 'packages/m4d_router/browser', 'packages/console_log_handler/console_log_handler', 'packages/m4d_router/url_pattern', 'packages/m4d_router/route'], function(dart_sdk, logging, browser, console_log_handler, url_pattern, route) {
  'use strict';
  const core = dart_sdk.core;
  const html = dart_sdk.html;
  const dart = dart_sdk.dart;
  const dartx = dart_sdk.dartx;
  const logging$ = logging.logging;
  const browser$ = browser.browser;
  const console_log_handler$ = console_log_handler.console_log_handler;
  const url_pattern$ = url_pattern.url_pattern;
  const route$ = route.route;
  const _root = Object.create(null);
  const main = Object.create(_root);
  const $text = dartx.text;
  const $join = dartx.join;
  const $toLowerCase = dartx.toLowerCase;
  const $first = dartx.first;
  const $append = dartx.append;
  let RouteEnterEventToNull = () => (RouteEnterEventToNull = dart.constFn(dart.fnType(core.Null, [route$.RouteEnterEvent])))();
  let RouteErrorEventToNull = () => (RouteErrorEventToNull = dart.constFn(dart.fnType(core.Null, [route$.RouteErrorEvent])))();
  dart.defineLazy(main, {
    /*main._logger*/get _logger() {
      return logging$.Logger.new("router.example.browser");
    }
  });
  main.main = function() {
    let router = new browser$.Router.new();
    console_log_handler$.configLogging({show: logging$.Level.INFO});
    main._configRouter(router);
    html.querySelector("#output")[$text] = "Your Dart app is running.";
  };
  main._configRouter = function(router) {
    router.addRoute({name: "Test I", path: new url_pattern$.UrlPattern.new("/#/test"), enter: dart.fn(event => {
        main._log(event.route.title);
        main._logger.info("Path: " + dart.str(event.path) + " Params: " + dart.str(event.params[$join](",")));
        main._showImage("https://dummyimage.com/400x300/ff0000/000000.png&text=Test");
      }, RouteEnterEventToNull())});
    router.addRoute({name: "Kitten", path: new url_pattern$.ReactPattern.new("/kitten"), enter: dart.fn(event => {
        main._log(event.route.title);
        main._logger.info("Path: " + dart.str(event.path) + " Params: " + dart.str(event.params[$join](",")));
        main._showImage("https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/cats/IMG-20150820-WA0000.jpg");
      }, RouteEnterEventToNull())});
    router.addRoute({name: "Specific cat", path: new url_pattern$.ReactPattern.new("/cats/([\\w%]+)"), enter: dart.fn(event => {
        main._log(dart.str(event.route.title) + ": " + dart.str(event.params[$join](",")));
        main._logger.info("Path: " + dart.str(event.path) + " Params: " + dart.str(event.params[$join](",")));
        if (event.params[$first][$toLowerCase]() === "grumpy cat") {
          main._showImage("https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/cats/IMG_20140811_032111.jpg");
        } else {
          main._showImage("https://raw.githubusercontent.com/MikeMitterer/m4d_router/master/doc/images/cats/IMG_20151224_182316.jpg");
        }
      }, RouteEnterEventToNull())});
    router.addRoute({name: "Google for cats", path: new url_pattern$.ReactPattern.new("/google"), enter: dart.fn(event => {
        main._log(event.route.title);
        main._logger.info("Path: " + dart.str(event.path) + " Params: " + dart.str(event.params[$join](",")));
        main._showImage("https://upload.wikimedia.org/wikipedia/commons/a/a5/Google_Chrome_icon_%28September_2014%29.svg");
      }, RouteEnterEventToNull())});
    router.onEnter.listen(dart.fn(event => {
      main._logger.info("RoutEvent " + dart.str(event.route.title) + " -> " + dart.str(event.route.urlPattern.pattern));
    }, RouteEnterEventToNull()));
    router.onError.listen(dart.fn(event => {
      main._logger.info("RouteErrorEvent " + dart.str(event.exception));
    }, RouteErrorEventToNull()));
    router.listen();
  };
  main._log = function(logMessage) {
    let logElement = html.UListElement.as(html.querySelector("#log"));
    logElement[$append]((() => {
      let _ = html.LIElement.new();
      _[$text] = logMessage;
      return _;
    })());
  };
  main._showImage = function(url) {
    let img = html.ImageElement.as(html.querySelector("img"));
    img.src = url;
  };
  dart.trackLibraries("web/main.ddc", {
    "main.dart": main
  }, '{"version":3,"sourceRoot":"","sources":["main.dart"],"names":[],"mappings":";;;;;;;;;;;;;;;;;;;;;MAIa,YAAO;YAAG,AAAI,oBAAM,CAAC;;;;AAG9B,QAAM,SAAS,IAAI,mBAAM;AAEzB,sCAAa,QAAO,cAAK,KAAK;AAC9B,sBAAa,CAAC,MAAM;AAEpB,IAAI,kBAAa,CAAC,iBAAe,GAAG;EACxC;gCAEmB,MAAmB;AAElC,IACI,AAAE,eAAQ,QAAO,gBAAgB,IAAI,2BAAU,CAAC,mBACrC,QAAC,KAA2B;AAC/B,iBAAI,CAAC,KAAK,MAAM,MAAM;AACtB,oBAAO,KAAK,CAAC,oBAAS,KAAK,KAAK,2BAAY,KAAK,OAAO,OAAK,CAAC;AAC9D,uBAAU,CAAC;;IAGnB,AAAE,eAAQ,QAAO,gBAAgB,IAAI,6BAAY,CAAC,mBACvC,QAAC,KAA2B;AAC/B,iBAAI,CAAC,KAAK,MAAM,MAAM;AACtB,oBAAO,KAAK,CAAC,oBAAS,KAAK,KAAK,2BAAY,KAAK,OAAO,OAAK,CAAC;AAC9D,uBAAU,CAAC;;IAGnB,AAAE,eAAQ,QAAO,sBAAsB,IAAI,6BAAY,CAAC,2BAC7C,QAAC,KAA2B;AAC/B,iBAAI,CAAC,SAAG,KAAK,MAAM,MAAM,oBAAK,KAAK,OAAO,OAAK,CAAC;AAChD,oBAAO,KAAK,CAAC,oBAAS,KAAK,KAAK,2BAAY,KAAK,OAAO,OAAK,CAAC;AAC9D,YAAG,KAAK,OAAO,QAAM,cAAY,OAAM,cAAc;AACjD,yBAAU,CAAC;eACR;AACH,yBAAU,CAAC;;;IAIvB,AAAE,eAAQ,QAAO,yBAAyB,IAAI,6BAAY,CAAC,mBAChD,QAAC,KAA2B;AAC/B,iBAAI,CAAC,KAAK,MAAM,MAAM;AACtB,oBAAO,KAAK,CAAC,oBAAS,KAAK,KAAK,2BAAY,KAAK,OAAO,OAAK,CAAC;AAC9D,uBAAU,CAAC;;AAKvB,UAAM,QAAQ,OAAO,CAAC,QAAC,KAA2B;AAC9C,kBAAO,KAAK,CAAC,wBAAa,KAAK,MAAM,MAAM,sBAAO,KAAK,MAAM,WAAW,QAAQ;;AAIpF,UAAM,QAAQ,OAAO,CAAC,QAAC,KAA2B;AAC9C,kBAAO,KAAK,CAAC,8BAAmB,KAAK,UAAU;;AAGnD,UAAM,OAAO;EACjB;uBAEU,UAAuB;AAC7B,QAAM,kCAAa,AAAI,kBAAa,CAAC;AACrC,cAAU,SAAO;cAAC,AAAI,kBAAa;iBAAW,UAAU;;;EAC5D;6BAEgB,GAAgB;AAC5B,QAAM,2BAAM,AAAI,kBAAa,CAAC;AAC9B,OAAG,IAAI,GAAG,GAAG;EACjB","file":"main.ddc.js"}');
  // Exports:
  return {
    main: main
  };
});

//# sourceMappingURL=main.ddc.js.map
