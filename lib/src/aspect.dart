part of dartemis;

class Aspect {

  int _all = 0;
  int _excluded = 0;
  int _one = 0;

  Aspect allOf(String requiredComponentName, [List<String> componentNames]) {
    _all = _updateBitMask(_all, requiredComponentName, componentNames);
    return this;
  }

  Aspect exclude(String requiredComponentName, [List<String> componentNames]) {
    _excluded = _updateBitMask(_excluded, requiredComponentName, componentNames);
    return this;
  }

  Aspect oneOf(String requiredComponentName, [List<String> componentNames]) {
    _one = _updateBitMask(_one, requiredComponentName, componentNames);
    return this;
  }

  static Aspect getAspectForAllOf(String requiredComponentName, [List<String> componentNames]) {
    Aspect aspect = new Aspect();
    aspect.allOf(requiredComponentName, componentNames);
    return aspect;
  }

  static getAspectForOneOf(String requiredComponentName, [List<String> componentNames]) {
    Aspect aspect = new Aspect();
    aspect.oneOf(requiredComponentName, componentNames);
    return aspect;
  }

  static Aspect getEmpty() {
    return new Aspect();
  }

  int get all => _all;
  int get excluded => _excluded;
  int get one => _one;

  int _updateBitMask(int mask, String requiredComponentName, [List<String> componentNames]) {
    mask = mask | ComponentTypeManager.getBit(requiredComponentName);
    if (null != componentNames) {
      for (String componentName in componentNames) {
        mask = mask | ComponentTypeManager.getBit(componentName);
      }
    }
    return mask;
  }

}