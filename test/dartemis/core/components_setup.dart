library components_setup;

import 'package:dartemis/dartemis.dart';

final int componentABit = ComponentType.getBitIndex(ComponentA);
final int componentBBit = ComponentType.getBitIndex(ComponentB);
final int componentCBit = ComponentType.getBitIndex(PooledComponentC);

class ComponentA extends Component {}

class ComponentB extends Component {}

class PooledComponentC extends PooledComponent<PooledComponentC> {
  factory PooledComponentC() =>
      Pooled.of<PooledComponentC>(() => PooledComponentC._());
  PooledComponentC._();
}
