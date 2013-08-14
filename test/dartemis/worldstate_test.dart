import "package:dartemis/dartemis.dart";
import "package:unittest/unittest.dart";

const DATA_COMPONENT_A = '{"_data":[{"value":"first"},null,{"value":"third"},null,null,null,null,null,null,null,null,null,null,null,null,null]}';
const DATA_COMPONENT_B = '{"_data":[null,{"value":"second"},{"value":"third"},null,null,null,null,null,null,null,null,null,null,null,null,null]}';
const DATA_OF_ALL_COMPONENTS = '{"_data":[${DATA_COMPONENT_A},${DATA_COMPONENT_B},null,null,null,null,null,null,null,null,null,null,null,null,null,null]}';

main() {
  group('worldstate tests', () {
    test('getState returns correct JSON', () {
      World world = new World();
      var e = world.createEntity();
      e.addComponent(new ComponentA('first'));
      e.addToWorld();
      e = world.createEntity();
      e.addComponent(new ComponentB('second'));
      e.addToWorld();
      e = world.createEntity();
      e.addComponent(new ComponentA('third'));
      e.addComponent(new ComponentB('third'));
      e.addToWorld();
      world.initialize();
      world.process();
      
      String state = world.getState();
      expect(state, equals(DATA_OF_ALL_COMPONENTS));
    });
  });
}

class ComponentA extends Component {
  String value;
  ComponentA(this.value);
  toJson() => {'value': value};
}
class ComponentB extends Component {
  String value;
  ComponentB(this.value);
  toJson() => {'value': value};
}