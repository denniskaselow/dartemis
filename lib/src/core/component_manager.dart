part of '../../dartemis.dart';

/// Manages als components of all entities.
class ComponentManager extends Manager {
  final Bag<_ComponentInfo> _componentInfoByType;

  ComponentManager._internal() : _componentInfoByType = Bag<_ComponentInfo>();

  @override
  void initialize() {}

  /// Register a system to know if it needs to be updated when an entity
  /// changed.
  void _registerSystem(EntitySystem system) {
    final systemBitIndex = system._systemBitIndex;
    for (final index in system._interestingComponentsIndices) {
      _componentInfoByType._ensureCapacity(index);
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

  void _removeComponentsOfEntity(Entity entity) {
    _forComponentsOfEntity(entity, (components) {
      components.remove(entity);
    });
  }

  void _addComponent<T extends Component>(
    Entity entity,
    ComponentType type,
    T component,
  ) {
    final index = type._bitIndex;
    _componentInfoByType._ensureCapacity(index);
    var componentInfo = _componentInfoByType[index];
    if (componentInfo == null) {
      componentInfo = _ComponentInfo<T>();
      _componentInfoByType[index] = componentInfo;
    }
    componentInfo[entity] = component;
  }

  void _removeComponent(Entity entity, ComponentType type) {
    final typeId = type._bitIndex;
    _componentInfoByType[typeId]!.remove(entity);
  }

  void _moveComponent(Entity entitySrc, Entity entityDst, ComponentType type) {
    final typeId = type._bitIndex;
    _componentInfoByType[typeId]?.move(entitySrc, entityDst);
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
  List<Component> getComponentsFor(Entity entity) {
    final result = <Component>[];
    _forComponentsOfEntity(
      entity,
      (components) => result.add(components[entity]),
    );

    return result;
  }

  void _forComponentsOfEntity(
    Entity entity,
    void Function(_ComponentInfo components) f,
  ) {
    for (var index = 0; index < ComponentType._nextBitIndex; index++) {
      final componentInfo = _componentInfoByType[index];
      if (componentInfo != null &&
          componentInfo.entities.length > entity._id &&
          componentInfo.entities[entity._id]) {
        f(componentInfo);
      }
    }
  }

  /// Returns true if the list of entities of [system] need to be updated.
  bool isUpdateNeededForSystem(EntitySystem system) {
    final systemBitIndex = system._systemBitIndex;
    for (final interestingComponent in system._interestingComponentsIndices) {
      if (_componentInfoByType[interestingComponent]!
          .systemRequiresUpdate(systemBitIndex)) {
        return true;
      }
    }
    return false;
  }

  /// Marks the [system] as updated for the necessary component types.
  void _systemUpdated(EntitySystem system) {
    final systemBitIndex = system._systemBitIndex;
    for (final interestingComponent in system._interestingComponentsIndices) {
      _componentInfoByType[interestingComponent]!.systemUpdated(systemBitIndex);
    }
  }

  /// Returns every entity that is of interest for [system].
  List<Entity> _getEntitiesForSystem(
    EntitySystem system,
    int entitiesBitSetLength,
  ) {
    final baseAll = BitSet(entitiesBitSetLength)..setAll();
    for (final interestingComponent in system._componentIndicesAll) {
      baseAll.and(_componentInfoByType[interestingComponent]!.entities);
    }
    final baseOne = BitSet(entitiesBitSetLength);
    if (system._componentIndicesOne.isEmpty) {
      baseOne.setAll();
    } else {
      for (final interestingComponent in system._componentIndicesOne) {
        baseOne.or(_componentInfoByType[interestingComponent]!.entities);
      }
    }
    final baseExclude = BitSet(entitiesBitSetLength);
    for (final interestingComponent in system._componentIndicesExcluded) {
      baseExclude.or(_componentInfoByType[interestingComponent]!.entities);
    }
    baseAll
      ..and(baseOne)
      ..andNot(baseExclude);
    return baseAll.toIntValues().map(Entity._).toList(growable: false);
  }

  /// Returns the component of type [T] for the given [entity].
  T? getComponent<T extends Component>(
    Entity entity,
    ComponentType componentType,
  ) {
    final index = componentType._bitIndex;
    final components = _componentInfoByType[index];
    if (components != null && entity._id < components.components.length) {
      return components.components[entity._id] as T?;
    }
    return null;
  }
}

class _ComponentInfo<T extends Component> {
  BitSet entities = BitSet(32);
  List<T?> components = List.filled(32, null, growable: true);
  BitSet interestedSystems = BitSet(32);
  BitSet requiresUpdate = BitSet(32);
  bool dirty = false;

  _ComponentInfo();

  void operator []=(Entity entity, T component) {
    if (entity._id >= entities.length) {
      entities = BitSet.fromBitSet(entities, length: entity._id + 1);
      final newCapacity = (entities.length * 3) ~/ 2 + 1;
      final filler = List.filled(newCapacity - components.length, null);
      components.addAll(filler);
    }
    entities[entity._id] = true;
    components[entity._id] = component;
    dirty = true;
  }

  T operator [](Entity entity) => components[entity._id]!;

  void remove(Entity entity) {
    if (entities.length > entity._id && entities[entity._id]) {
      entities[entity._id] = false;
      components[entity._id]!._removed();
      components[entity._id] = null;
      dirty = true;
    }
  }

  void move(Entity srcEntity, Entity dstEntity) {
    if (entities.length > srcEntity._id && entities[srcEntity._id]) {
      remove(dstEntity);
      this[dstEntity] = components[srcEntity._id]!;
      entities[srcEntity._id] = false;
      components[srcEntity._id] = null;
      dirty = true;
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

  bool systemRequiresUpdate(int systemBitIndex) {
    if (dirty) {
      requiresUpdate.or(interestedSystems);
      dirty = false;
    }
    return requiresUpdate[systemBitIndex];
  }

  void systemUpdated(int systemBitIndex) =>
      requiresUpdate[systemBitIndex] = false;

  _ComponentInfo<S> cast<S extends Component>() => this as _ComponentInfo<S>;
}

/// For Testing.
@visibleForTesting
mixin MockComponentManagerMixin implements ComponentManager {
  @override
  late World _world;
  @override
  void _registerSystem(EntitySystem system) {}
  @override
  void _removeComponentsOfEntity(Entity entity) {}
}
