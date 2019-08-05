import 'package:dartemis/src/core/utils/bit_set.dart';
import 'package:test/test.dart';

void main() {
  group('BitSet', () {
    test('toIntValues() works in general', () {
      final sut = BitSet(32)..setAll();

      expect(sut.toIntValues(), equals(List.generate(32, (index) => index)));
    });
    test('toIntValues() works for edge cases', () {
      final sut = BitSet(128);
      sut[0] = true;
      sut[31] = true;
      sut[32] = true;
      sut[63] = true;
      sut[64] = true;
      sut[127] = true;

      expect(sut.toIntValues(), equals([0, 31, 32, 63, 64, 127]));
    });
  });
}
