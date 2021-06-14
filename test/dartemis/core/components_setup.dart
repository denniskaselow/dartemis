library components_setup;

import 'package:dartemis/dartemis.dart';

final int componentBit0 = ComponentType.getBitIndex(Component0);
final int componentBit1 = ComponentType.getBitIndex(Component1);
final int componentBit2 = ComponentType.getBitIndex(PooledComponent2);

class Component0 extends Component {}

class Component1 extends Component {}

class PooledComponent2 extends PooledComponent<PooledComponent2> {
  factory PooledComponent2() =>
      Pooled.of<PooledComponent2>(() => PooledComponent2._());
  PooledComponent2._();
}

class Component3 extends Component {}

class Component4 extends Component {}

class Component5 extends Component {}

class Component6 extends Component {}

class Component7 extends Component {}

class Component8 extends Component {}

class Component9 extends Component {}

class Component10 extends Component {}

class Component11 extends Component {}

class Component12 extends Component {}

class Component13 extends Component {}

class Component14 extends Component {}

class Component15 extends Component {}

class Component16 extends Component {}

class Component17 extends Component {}

class Component18 extends Component {}

class Component19 extends Component {}

class Component20 extends Component {}

class Component21 extends Component {}

class Component22 extends Component {}

class Component23 extends Component {}

class Component24 extends Component {}

class Component25 extends Component {}

class Component26 extends Component {}

class Component27 extends Component {}

class Component28 extends Component {}

class Component29 extends Component {}

class Component30 extends Component {}

class Component31 extends Component {}

class Component32 extends Component {}
