library components_setup;

import "package:dartemis/dartemis.dart";

final BigInt componentABit = BigInt.from(0x0001);
final BigInt componentBBit = BigInt.from(0x0002);
final BigInt componentCBit = BigInt.from(0x0004);

void setUpComponents() {
  ComponentTypeManager.getBit(ComponentA);
  ComponentTypeManager.getBit(ComponentB);
  ComponentTypeManager.getBit(PooledComponentC);
}

class ComponentA extends Component {}

class ComponentB extends Component {}

class PooledComponentC extends PooledComponent {
  factory PooledComponentC() =>
      Pooled.of<PooledComponentC>(() => PooledComponentC._());
  PooledComponentC._();
}
