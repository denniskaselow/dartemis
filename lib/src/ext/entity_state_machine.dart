part of dartemis;

/**
 * A component containing an [EntityStateMachine]. Setting [fsm.currentState]
 * will add and remove [Component]s as defined in the [EntityStateMachine].
 *
 * Based on <http://www.richardlord.net/blog/finite-state-machines-with-ash>
 */
class EntityStateComponent implements Component {
  EntityStateMachine fsm;

  EntityStateComponent._();
  static _ctor() => new EntityStateComponent._();
  factory EntityStateComponent(EntityStateMachine fsm) {
    var c = new Component(EntityStateComponent, _ctor);
    c.fsm = fsm;
    return c;
  }
}

class EntityStateMachine {
  Entity _entity;
  String _currentState;
  EntityStateRepository _repo;

  /**
   * The [EntityStateMachine] should only be used in an [EntityStateComponent].
   *
   * Using it on it's own will lead to undeterministic behaviour when the
   * [Entity] is deleted from the world.
   */
  EntityStateMachine(this._entity, String startState, this._repo) {
    currentState = startState;
  }

  Entity get entity => _entity;
  String get currentState => _currentState;
  void set currentState(String nextState) {
    _repo._changeStateOf(_entity, _currentState, nextState);
    _currentState = nextState;
  }
}

class EntityStateRepository {
  var _states = new Map<String, EntityState>();

  void registerState(String name, EntityState state) {
    _states[name] = state;
  }

  _changeStateOf(Entity e, String currentState, String nextState) {
    var current = _states[currentState];
    var next = _states[nextState];
    assert(next != null);//, "state '${next}' is not defined");
    if (current == next) {
      // nothing to do
    } else {
      if (current != null) {
        //TODO optimize the computation of component diff
        current.forEach((provider) {
          var np = next.getByType(provider.type);
          if (np == null || np.id() != provider.id()) {
            e.removeComponentByType(provider.type);
          }
        });
      }
      // keep existing Component of the same type
      // (not previously removed because same provider.id or managed outside of the state machine)
      next.forEach((provider){
        if (e.getComponent(provider.type) == null) {
          e.addComponent(provider.f(e));
        }
      });
      e.changedInWorld();
    }
  }
}

/**
 * return a component that can be added to the entity [e]
 * (but it should not add component to entity [e]).
 */
typedef Component ComponentProviderF(Entity e);

/**
 * Returns an identifier that is used to determine whether two component providers will
 * return the equivalent components.
 *
 * If an entity is changing state and the state it is leaving and the state is is
 * entering have components of the same type, then the identifiers of the component
 * provders are compared. If the two identifiers are the same then the component
 * is not removed. If they are different, the component from the old state is removed
 * and a component for the new state is added.
 */
typedef dynamic ComponentProviderId();

class ComponentProvider {
  static nullId() => null;

  /// Type of the provided Component
  final ComponentType type;

  final ComponentProviderF f;

  final ComponentProviderId id;

  ComponentProvider(Type ctype, this.f, [this.id = nullId]) : type = ComponentTypeManager.getTypeFor(ctype);

  factory ComponentProvider.singleton(Component c) {
    return new ComponentProvider(c.runtimeType, (e) => c, () => c);
  }
}

class EntityState {
  var _componentProviderByType = new Bag<ComponentProvider>();
  var _indices = new Set<int>();

  EntityState add(ComponentProvider provider) {
    int index = provider.type.id;
    _componentProviderByType[index] = provider;
    _indices.add(index);
  }

  void forEach(void f(ComponentProvider)) {
    _indices.forEach((index) => f(_componentProviderByType[index]));
  }

  ComponentProvider getByType(ComponentType type) => _componentProviderByType[type.id];
}
