import 'dart:typed_data';

/// [BitSet] to store bits.
class BitSet {
  Uint32List _data;
  int _length;

  /// Creates a [BitSet] with maximum [length] items.
  ///
  /// [length] will be rounded up to match the 32-bit boundary.
  factory BitSet(int length) => BitSet._(Uint32List(_bufferLength32(length)));

  /// Creates a [BitSet] using an existing [BitSet].
  factory BitSet.fromBitSet(BitSet set, {int length}) {
    length ??= set.length;
    final data = Uint32List(_bufferLength32(length))
      ..setRange(0, set._data.length, set._data);
    return BitSet._(data);
  }

  BitSet._(this._data) : _length = _data.length << 5;

  /// The value of the bit with the specified [index].
  bool operator [](int index) =>
      (_data[index >> 5] & _bitMask[index & 0x1f]) != 0;

  /// Sets the bit specified by the [index] to the [value].
  void operator []=(int index, bool value) {
    if (value) {
      _data[index >> 5] |= _bitMask[index & 0x1f];
    } else {
      _data[index >> 5] &= _clearMask[index & 0x1f];
    }
  }

  /// The number of bit in this [BitSet].
  ///
  /// [length] will be rounded up to match the 32-bit boundary.
  ///
  /// The valid index values for the array are `0` through `length - 1`.
  int get length => _length;

  /// The number of bits set to true.
  int get cardinality => _data.buffer
      .asUint8List()
      .fold(0, (sum, value) => sum + _cardinalityBitCounts[value]);

  /// Whether the [BitSet] is empty == has only zero values.
  bool get isEmpty => _data.every((i) => i == 0);

  /// Whether the [BitSet] is not empty == has set values.
  bool get isNotEmpty => _data.any((i) => i != 0);

  /// Sets all of the bits in the current [BitSet] to true.
  void setAll() {
    for (var i = 0; i < _data.length; i++) {
      _data[i] = 0xffffffff;
    }
  }

  /// Sets all of the bits in the current [BitSet] to false.
  void clearAll() {
    for (var i = 0; i < _data.length; i++) {
      _data[i] = 0;
    }
  }

  /// Update the current [BitSet] using a logical AND operation with the
  /// corresponding elements in the specified [other].
  void and(BitSet other) {
    var i = 0;
    for (; i < _data.length && i < other._data.length; i++) {
      _data[i] &= other._data[i];
    }
    for (; i < _data.length; i++) {
      _data[i] = 0;
    }
  }

  /// Update the current [BitSet] using a logical OR operation with the
  /// corresponding elements in the specified [other].
  void or(BitSet other) {
    if (other._data.length > _data.length) {
      _data = Uint32List(other.length)..setRange(0, _data.length, _data);
      _length = other.length;
    }
    var i = 0;
    for (; i < _data.length && i < other._data.length; i++) {
      _data[i] |= other._data[i];
    }
    for (; i < other._data.length; i++) {
      _data[i] = other._data[i];
    }
  }

  /// Update the current [BitSet] using a logical AND NOT operation with the
  /// corresponding elements in the specified [other].
  void andNot(BitSet other) {
    var i = 0;
    for (; i < _data.length && i < other._data.length; i++) {
      // ignore: unnecessary_parenthesis
      _data[i] &= ~(other._data[i]);
    }
  }

  /// Creates a copy of the current [BitSet].
  BitSet _clone() =>
      BitSet._(Uint32List(_data.length)..setRange(0, _data.length, _data));

  /// Creates a [BitSet] using a logical AND operation with the
  /// corresponding elements in the specified [other].
  /// Length of [other] has to be the same.
  BitSet operator &(BitSet other) => _clone()..and(other);

  /// Not implemented
  BitSet operator %(BitSet set) =>
      throw UnimplementedError('andNot not implemented');

  /// Creates a [BitSet] using a logical OR operation with the
  /// corresponding elements in the specified [other].
  /// Length of [other] has to be the same.
  BitSet operator |(BitSet other) => _clone()..or(other);

  /// Not implemented
  BitSet operator ^(BitSet other) =>
      throw UnimplementedError('xor not implemented');

  @override
  String toString() {
    final sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(this[i] ? '1' : '0');
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is BitSet && runtimeType == other.runtimeType) {
      return equals(other);
    }
    return false;
  }

  /// Compares two bitsets.
  bool equals(BitSet other) {
    if (length == other.length) {
      for (var i = 0; i < _data.length; i++) {
        if (_data[i] != other._data[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => _data.hashCode ^ _length.hashCode;

  static int _bufferLength32(int length) => 1 + (length - 1) ~/ 32;

  /// Returns the set indices.
  List<int> toIntValues() {
    final result = <int>[];
    var index = 0;
    for (var value in _data) {
      for (var i = 0; i < 4; i++) {
        result.addAll(_indices[value & 0xff]
            .map((internalValue) => internalValue + index));
        index += 8;
        value = value >> 8;
      }
    }
    return result;
  }
}

final _bitMask = List<int>.generate(32, (i) => 1 << i);
final _clearMask = List<int>.generate(32, (i) => ~(1 << i));
final _cardinalityBitCounts = List<int>.generate(256, _cardinalityOfByte);
int _cardinalityOfByte(int index) {
  var result = 0;
  var value = index;
  while (value > 0) {
    if (value & 0x01 != 0) {
      result++;
    }
    value = value >> 1;
  }
  return result;
}

final _indices = List<List<int>>.generate(256, _indicesOfByte);
List<int> _indicesOfByte(int index) {
  final result = <int>[];
  var value = index;
  var count = 0;
  while (value > 0) {
    if (value & 0x01 != 0) {
      result.add(count);
    }
    count++;
    value = value >> 1;
  }
  return result;
}
