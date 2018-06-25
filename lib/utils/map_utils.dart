library route.map_utils;

bool isMapEqual(final Map a, final Map b) => a.length == b.length &&
    a.keys.every((key) => b.containsKey(key) && a[key] == b[key]);

/// Checks if Lists are equal
///
/// Functions (closures) will be ignored
bool isListEqual(final List a, final List b) => a.length == b.length &&
    a.where((value) => value is! Function).every((value) => b.contains(value));
