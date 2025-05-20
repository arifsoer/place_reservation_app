String indexToLetter(int index) {
  if (index < 0) {
    throw ArgumentError('Index must be non-negative');
  }

  String result = '';
  while (index >= 0) {
    result = String.fromCharCode((index % 26) + 65) + result;
    index = (index ~/ 26) - 1;
  }
  return result;
}

String generaQueryParams(Map<String, String> params) {
  return params.entries.map((e) => '${e.key}=${e.value}').join('&');
}
