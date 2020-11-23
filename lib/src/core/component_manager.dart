part of dartemis;

/// Manages als components of all entities.
class ComponentManager extends Manager {
  final Bag<_ComponentInfo> _componentInfoByType;

  ComponentManager._internal() : _componentInfoByType = Bag<_ComponentInfo>();

  @override
  void initialize() {}

  /// Reigster a system to know if it needs to be updated when an entity
  /// changed.
  void _registerSystem(EntitySystem system) {
    final systemBitIndex = system._systemBitIndex;
    for (final index in system._interestingComponentsIndices) {
      var componentInfo = _componentInfoByType[index];
      if (componentInfo == null) {
        componentInfo = _ComponentInfo();
        _componentInfoByType[index] = componentInfo;
      }

      componentInfo.addInterestedSystem(systemBitIndex);
    }
  }

  void _unregisterSystem(EntitySystem system) {
    final systemBitIndex = system._systemBitIndex;
    for (final index in system._interestingComponentsIndices) {
      _componentInfoByType[index]!.removeInterestedSystem(systemBitIndex);
    }
  }

  void _removeComponentsOfEntity(int entity) {
    _forComponentsOfEntity(entity, (components, typeId) {
      components.remove(entity);
    });
  }

  void _addComponent<T extends Component>(
      int entity, ComponentType type, T component) {
    final index = type._bitIndex;
    _componentInfoByType._ensureCapacity(index);
    var componentInfo = _componentInfoByType[index];
    if (componentInfo == null) {
      componentInfo = _ComponentInfo<T>();
      _componentInfoByType[index] = componentInfo;
    }
    componentInfo[entity] = component;
  }

  void _removeComponent(int entity, ComponentType type) {
    final typeId = type._bitIndex;
    _componentInfoByType[typeId]!.remove(entity);
  }

  /// Returns all components of [ComponentType type] accessible by their entity
  /// id.
  List<T?> _getComponentsByType<T extends Component>(ComponentType type) {
    final index = type._bitIndex;
    _componentInfoByType._ensureCapacity(index);

    var components = _componentInfoByType[index];
    if (components == null) {
      components = _ComponentInfo<T>();
      _componentInfoByType[index] = components;
    } else if (components.components is! List<T?>) {
      // when components get added to an entity as part of a list containing
      // multiple different components, the type is infered as Component
      // instead of the actual type of the component. So if _addComponent was
      // called first a Bag<Component> would have been created and this fixes
      // the type
      _componentInfoByType[index]!.components =
          components.components.cast<T?>();
      components = _componentInfoByType[index];
    }

    return components!.components.cast<T?>();
  }

  /// Returns all components of [ComponentType type].
  List<T> getComponentsByType<T extends Component>(ComponentType type) =>
      _getComponentsByType(type).whereType<T>().toList();

  /// Returns all components of [entity].
  Bag<Component> getComponentsFor(int entity) {
    final result = Bag<Component>();
    _forComponentsOfEntity(
        entity, (components, _) => result.add(components[entity]));

    return result;
  }

  void _forComponentsOfEntity(
      int entity, void Function(_ComponentInfo components, int index) f) {
    for (var index = 0; index < ComponentType._nextBitIndex; index++) {
      final componentInfo = _componentInfoByType[index];
      if (componentInfo != null &&
          componentInfo.entities.length > entity &&
          componentInfo.entities[entity]) {
        f(componentInfo, entity);
      }
    }
  }

  /// Returns true if the list of entities of [system] need to be updated.
  bool isUpdateNeededForSystem(EntitySystem system) {
    final systemBitIndex = system._systemBitIndex;
    for (final interestingComponent in system._interestingComponentsIndices) {
      if ((_componentInfoByType[interestingComponent])!
          .systemRequiresUpdate(systemBitIndex)) {
        return true;
      }
    }
    return false;
  }

  /// Returns every entity that is of interest for [system].
  List<int> _getEntitiesForSystem(
      EntitySystem system, int entitiesBitSetLength) {
    final baseAll = BitSet(entitiesBitSetLength)..setAll();
    for (final interestingComponent in system._componentIndicesAll) {
      baseAll.and((_componentInfoByType[interestingComponent])!.entities);
    }
    final baseOne = BitSet(entitiesBitSetLength);
    if (system._componentIndicesOne.isEmpty) {
      baseOne.setAll();
    } else {
      for (final interestingComponent in system._componentIndicesOne) {
        baseOne.or((_componentInfoByType[interestingComponent])!.entities);
      }
    }
    final baseExclude = BitSet(entitiesBitSetLength);
    for (final interestingComponent in system._componentIndicesExcluded) {
      baseExclude.or((_componentInfoByType[interestingComponent])!.entities);
    }
    baseAll
      ..and(baseOne)
      ..andNot(baseExclude);
    return baseAll.toIntValues();
  }
}

class _ComponentInfo<T extends Component> {
  BitSet entities = BitSet(32);
  List<T?> components = List.filled(32, null);
  BitSet interestedSystems = BitSet(32);
  BitSet requiresUpdate = BitSet(32);
  bool dirty = false;

  _ComponentInfo();

  void operator []=(int entity, T component) {
    if (entity >= entities.length) {
      entities = BitSet.fromBitSet(entities, length: entity + 1);
      final newCapacity = (entities.length * 3) ~/ 2 + 1;
      components = List<T?>.filled(newCapacity, null)
        ..setRange(0, components.length, components);
    }
    entities[entity] = true;
    components[entity] = component;
    if (!dirty) {
      requiresUpdate.or(interestedSystems);
      dirty = true;
    }
  }

  T operator [](int entity) => (components[entity])!;

  void remove(int entity) {
    if (entities.length > entity && entities[entity]) {
      entities[entity] = false;
      (components[entity])!._removed();
      components[entity] = null;
      if (!dirty) {
        requiresUpdate.or(interestedSystems);
        dirty = true;
      }
    }
  }

  void addInterestedSystem(int systemBitIndex) {
    if (systemBitIndex >= interestedSystems.length) {
      interestedSystems =
          BitSet.fromBitSet(interestedSystems, length: systemBitIndex + 1);
      requiresUpdate =
          BitSet.fromBitSet(requiresUpdate, length: systemBitIndex + 1);
    }
    interestedSystems[systemBitIndex] = true;
    requiresUpdate[systemBitIndex] = true;
  }

  void removeInterestedSystem(int systemBitIndex) {
    interestedSystems[systemBitIndex] = false;
    requiresUpdate[systemBitIndex] = false;
  }

  bool systemRequiresUpdate(int systemBitIndex) =>
      requiresUpdate[systemBitIndex];

  void systemUpdated(int systemBitIndex) =>
      requiresUpdate[systemBitIndex] = false;

  _ComponentInfo<S> cast<S extends Component>() => this as _ComponentInfo<S>;
}
