import 'dart:mirrors';

import "package:dartemis/dartemis.dart";
import "package:unittest/unittest.dart";


main() {
  test('type arguments implemented for ClassMirror', () {
    reflectClass(ClassWithComponentMapper).variables.forEach((k, v) {
      (v.type as ClassMirror).typeArguments;
    });
  });
}

class ComponentA extends Component {}
class ClassWithComponentMapper {
  ComponentMapper<ComponentA> mapperForA;
}