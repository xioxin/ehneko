List<int> getRange(String rangeText, {int? length}) {
  final rangeTextList = rangeText
      .split(',')
      .map((e) => e.trim())
      .where((element) => element != '')
      .toList();
  final Set<int> list = {};
  for (var e in rangeTextList) {
    final split = e.split(':').map((v) {
      if (v.trim() == '') return null;
      return int.parse(v.trim());
    }).toList();
    if (split.length > 2 || split.isEmpty) {
      throw "Unrecognized range $e";
    }
    if (length == null && split.any((element) => element! < 0)) {
      throw "Negative range is not supported $e";
    }
    if (split.length == 1) {
      list.add(split.first!);
    } else {
      int v1 = split[0] ?? 0;
      int? v2 = split[1] ?? (length == null ? null : length - 1);
      if (v2 == null) throw "Unrecognized range $e";
      if (v1 < 0) {
        if (length == null) throw "Unrecognized range $e";
        v1 = length + v1 - 1;
      }
      if (v2 < 0) {
        if (length == null) throw "Unrecognized range $e";
        v2 = length + v2 - 1;
      }
      if (v2 < v1) throw "Unrecognized range $e";
      if (v2 == v1) {
        list.add(v1);
      } else {
        final l = v2 - v1 + 1;
        list.addAll(List.generate(l, (index) => v1 + index));
      }
    }
  }
  return list.where((v) => v>= 0 && (length == null || v < length)).toList()..sort();
}
