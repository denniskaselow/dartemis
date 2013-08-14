part of dartemis;

class ComponentTypeManager {

  static var _componentTypes = new Map<Type, ComponentType>();
  static var _componentTypesByMirror = new Map<ClassMirror, ComponentType>();

  static ComponentType getTypeFor(Type typeOfComponent){
    ComponentType componentType = _componentTypes[typeOfComponent];

    if (componentType == null) {
      ClassMirror cm = reflectClass(typeOfComponent);
      componentType = _getTypeFor(cm);
      _componentTypes[typeOfComponent] = componentType;
    }
    return componentType;
  }

  static ComponentType _getTypeFor(ClassMirror cm) {
    ComponentType componentType = _componentTypesByMirror[cm];
    if (componentType == null) {
      componentType = new ComponentType();
      _componentTypesByMirror[cm] = componentType;
    }
    return componentType;
  }

  static int getBit(Type componentType) => getTypeFor(componentType).bit;
  static int getId(Type componentType) => getTypeFor(componentType).id;
}
