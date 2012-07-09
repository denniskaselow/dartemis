class ComponentTypeManager {

  static var _componentTypes;

  static ComponentType getTypeFor(Type typeOfClass){
    if (null == _componentTypes) {
      _componentTypes = new Map<String, ComponentType>();
    }
    ComponentType type = _componentTypes[typeOfClass.toString()];

    if (type == null) {
      type = new ComponentType();
      _componentTypes[typeOfClass.toString()] = type;
    }

    return type;
  }

  static int getBit(Type typeOfClass) {
    return getTypeFor(typeOfClass).bit;
  }

  static int getId(Type typeOfClass) {
    return getTypeFor(typeOfClass).id;
  }


}
