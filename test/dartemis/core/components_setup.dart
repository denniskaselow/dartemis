library components_setup;

import "package:dartemis/dartemis.dart";

const int componentABit = 0x0001;
const int componentBBit = 0x0002;
const int componentCBit = 0x0004;

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
