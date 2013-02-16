part of dartemis;

class ComponentTypeManager {

  static var _componentTypes = new Map<Type, ComponentType>();

  static ComponentType getTypeFor(Type componentType){
    ComponentType type = _componentTypes[componentType];

    if (type == null) {
      type = new ComponentType();
      _componentTypes[componentType] = type;
    }

    return type;
  }

  static int getBit(Type componentType) {
    return getTypeFor(componentType).bit;
  }

  static int getId(Type componentType) {
    return getTypeFor(componentType).id;
  }


}
