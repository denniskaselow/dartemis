library components_setup;

import "package:dartemis/dartemis.dart";

final Type componentA = new ComponentA().runtimeType;
final Type componentB = new ComponentB().runtimeType;
final Type componentC = new PooledComponentC().runtimeType;

const int componentABit = 0x0001;
const int componentBBit = 0x0002;
const int componentCBit = 0x0004;

void setUpComponents() {
  ComponentTypeManager.getBit(componentA);
  ComponentTypeManager.getBit(componentB);
  ComponentTypeManager.getBit(componentC);
}

class ComponentA extends Component {}

class ComponentB extends Component {}

class PooledComponentC extends PooledComponent {
  factory PooledComponentC() =>
      new Pooled.of(PooledComponentC, () => new PooledComponentC._());
  PooledComponentC._();
}
