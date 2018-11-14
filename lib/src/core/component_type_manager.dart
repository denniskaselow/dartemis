part of dartemis;

class ComponentTypeManager {
  static final _componentTypes = <Type, ComponentType>{};

  static ComponentType getTypeFor(Type typeOfComponent) {
    ComponentType componentType = _componentTypes[typeOfComponent];

    if (componentType == null) {
      componentType = ComponentType();
      _componentTypes[typeOfComponent] = componentType;
    }
    return componentType;
  }

  static BigInt getBit(Type componentType) => getTypeFor(componentType).bit;
  static int getId(Type componentType) => getTypeFor(componentType).id;
}
