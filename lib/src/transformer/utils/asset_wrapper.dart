part of transformer;

class AssetWrapper {
  Asset asset;
  CompilationUnit unit;
  String content;
  SplayTreeMap<int, int> insertionsOffsets = new SplayTreeMap<int, int>();
  AssetWrapper(this.asset, this.unit, this.content);

  /// Inserts [toInset] at the [pos] relative to the original [content].
  /// If the same [pos] is used more than once, the later insertions are
  /// added after the previous insertions.
  ///
  /// For multiple insertions with different values of [pos] the order of
  /// invocations does no matter. The result will be the same.
  void insert(int pos, String toInsert) {
    int offset = _calculateOffset(pos);
    content = content.substring(0, pos + offset) + toInsert + content.substring(pos + offset);
    _updateOffset(pos, toInsert.length);
  }

  void insertAtCursor(String toInsert) {
    var index = content.indexOf(_cursor);
    var offset = 0;
    var pos = insertionsOffsets.keys.firstWhere((key) {
      offset += insertionsOffsets[key];
      return key + offset > index;
    }, orElse: () => 0);

    replace(_cursor, toInsert, pos-1);
  }

  void replace(String from, String to, int pos) {
    int offset = _calculateOffset(pos);
    content = content.replaceFirst(from, to, pos + offset);
    _updateOffset(pos, to.length - from.length);
  }

  int _calculateOffset(int pos) {
    return insertionsOffsets.keys.takeWhile((key) => key <= pos)
        .fold(0, (result, key) => result + insertionsOffsets[key]);
  }

  void _updateOffset(int pos, int change) {
    if (insertionsOffsets[pos] == null) {
      insertionsOffsets[pos] = change;
    } else {
      insertionsOffsets[pos] += change;
    }
  }
}
