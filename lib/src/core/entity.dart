part of '../../dartemis.dart';

/// The Entity type. Cannot be instantiated outside of dartemis. You must
/// create new entities using [World.createEntity].
extension type Entity(int _id) {
  Entity._(this._id);
}
