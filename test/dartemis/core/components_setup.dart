library components_setup;

import 'package:dartemis/dartemis.dart';

final int componentABit = ComponentTypeManager.getBitIndex(ComponentA);
final int componentBBit = ComponentTypeManager.getBitIndex(ComponentB);
final int componentCBit = ComponentTypeManager.getBitIndex(PooledComponentC);

class ComponentA extends Component {}

class ComponentB extends Component {}

class PooledComponentC extends PooledComponent {
  factory PooledComponentC() =>
      Pooled.of<PooledComponentC>(() => PooledComponentC._());
  PooledComponentC._();
}
