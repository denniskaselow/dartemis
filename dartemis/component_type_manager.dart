class ComponentTypeManager {

  static var _componentTypes;

  static ComponentType getTypeFor(String componentName){
    if (null == _componentTypes) {
      _componentTypes = new Map<String, ComponentType>();
    }
    ComponentType type = _componentTypes[componentName];

    if (type == null) {
      type = new ComponentType();
      _componentTypes[componentName] = type;
    }

    return type;
  }

  static int getBit(String componentName) {
    return getTypeFor(componentName).bit;
  }

  static int getId(String componentName) {
    return getTypeFor(componentName).id;
  }


}
