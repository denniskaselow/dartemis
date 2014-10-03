library components_setup;

import "package:dartemis/dartemis.dart";

final Type COMPONENT_A = new ComponentA().runtimeType;
final Type COMPONENT_B = new ComponentB().runtimeType;
final Type COMPONENT_C = new PooledComponentC().runtimeType;

const int COMPONENT_A_BIT = 0x0001;
const int COMPONENT_B_BIT = 0x0002;
const int COMPONENT_C_BIT = 0x0004;

void setUpComponents() {
  ComponentTypeManager.getBit(COMPONENT_A);
  ComponentTypeManager.getBit(COMPONENT_B);
  ComponentTypeManager.getBit(COMPONENT_C);
}

class ComponentA extends Component {}
class ComponentB extends Component {}
class PooledComponentC extends PooledComponent {
  PooledComponentC._();
  factory PooledComponentC() => new Pooled.of(PooledComponentC, () => new PooledComponentC._());
}