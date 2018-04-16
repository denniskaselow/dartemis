part of dartemis;

/// Metadata to annotate [Manager]s and [EntitySystem]s to generate code
/// required for [Mapper]s, other [Manager]s and other [EntitySystem]s using
/// dartemis_builder.
class Generate {
  /// The [EntitySystem] or [Manager] that is the base class.
  final Type base;

  /// Additional mappers to declare and initialize.
  final List<Type> mapper;

  /// Other [EntitySystem]s to declare and initialize.
  final List<Type> systems;

  /// Other [Manager]s to declare and initialize.
  final List<Type> manager;

  /// All [Aspect]s that an [Entity] needs to be processed by the [EntitySystem].
  /// Required [Mapper]s will also be created.
  ///
  /// Has no effect if used in a [Manager].
  final List<Type> allOf;

  /// One of the [Aspect]s that an [Entity] needs to be processed by the
  /// [EntitySystem]. Required [Mapper]s will also be created.
  ///
  /// Has no effect if used in a [Manager].
  final List<Type> oneOf;

  /// Excludes [Entity]s that have these [Aspect]s from being processed by the
  /// [EntitySystem].
  ///
  /// Has no effect if used in a [Manager].
  final List<Type> exclude;

  const Generate(this.base,
      {this.allOf: const [],
      this.oneOf: const [],
      this.exclude: const [],
      this.mapper: const [],
      this.systems: const [],
      this.manager: const []});
}
