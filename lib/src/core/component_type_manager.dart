part of dartemis;

class ComponentTypeManager {

  static var _componentTypes = new Map<Type, ComponentType>();

  static ComponentType getTypeFor(Type typeOfComponent) {
    ComponentType componentType = _componentTypes[typeOfComponent];

    if (componentType == null) {
      componentType = new ComponentType();
      _componentTypes[typeOfComponent] = componentType;
    }
    return componentType;
  }

  static int getBit(Type componentType) => getTypeFor(componentType).bit;
  static int getId(Type componentType) => getTypeFor(componentType).id;
}
