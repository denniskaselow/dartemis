import 'dart:typed_data';

/// [BitSet] to store bits.
class BitSet {
  final Uint32List _data;
  final int _length;

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

  /// Sets all of the bits in the current [BitSet] to false.
  void clearAll() {
    for (var i = 0; i < _data.length; i++) {
      _data[i] = 0;
    }
  }

  /// Update the current [BitSet] using a logical AND operation with the
  /// corresponding elements in the specified [other].
  /// Length of [other] has to be the same.
  void and(BitSet other) {
    if (other.length != length) {
      throw ArgumentError(
          '''length of given BitSet (${other.length} not equal to length of this BitSet ($length)''');
    }
    for (var i = 0; i < _data.length; i++) {
      _data[i] &= other._data[i];
    }
  }

  /// Update the current [BitSet] using a logical OR operation with the
  /// corresponding elements in the specified [other].
  /// Length of [other] has to be the same.
  void or(BitSet other) {
    if (other.length != length) {
      throw ArgumentError(
          '''length of given BitSet (${other.length} not equal to length of this BitSet ($length)''');
    }
    for (var i = 0; i < _data.length; i++) {
      _data[i] |= other._data[i];
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
    if (other is BitSet &&
        runtimeType == other.runtimeType &&
        length == other.length) {
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
