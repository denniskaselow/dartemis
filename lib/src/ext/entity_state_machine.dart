part of dartemis;

// based on http://www.richardlord.net/blog/finite-state-machines-with-ash

class EntityStateComponent extends Component {
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

  EntityStateMachine(this._entity, startState, this._repo) {
    currentState = startState;
  }

  get entity => _entity;
  get currentState => _currentState;
  set currentState(String nextState) {
    _repo._changeStateOf(_entity, _currentState, nextState);
    _currentState = nextState;
  }

}

class EntityStateRepository {
  var _states = new Map<String, EntityState>();

  registerState(String name, EntityState state) => _states[name] = state;

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
 * and a component for the new state is added.</p>
 * 
 * @return An object
 */
typedef dynamic ComponentProviderId();

class ComponentProvider {
  /// Type of the provided Component
  final ComponentType type;

  final ComponentProviderF f;

  final ComponentProviderId id;

  ComponentProvider(Type ctype, this.f, this.id) : type = ComponentTypeManager.getTypeFor(ctype);

  factory ComponentProvider.singleton(Component c) {
    return new ComponentProvider(c.runtimeType, (e) => c, () => c);
  }
}

class EntityState {
  var _componentProviderByType = new Bag<ComponentProvider>();

  // 
  EntityState add(ComponentProvider provider) {
    int index = provider.type.id;
    _componentProviderByType._ensureCapacity(index);
    _componentProviderByType[index] = provider;
  }

  void forEach(void f(ComponentProvider)) {
    _componentProviderByType.forEach((x){ if (x != null) f(x);});
  }

  ComponentProvider getByType(ComponentType type) => _componentProviderByType[type.id];
}
