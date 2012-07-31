#library('dartemis');

#import('dart:coreimpl');

#source('dartemis/utils/bag.dart');
#source('dartemis/utils/fast_math.dart');
#source('dartemis/utils/immutable_bag.dart');
#source('dartemis/utils/timer.dart');
#source('dartemis/utils/trigometry_lookup_table.dart');
#source('dartemis/utils/utils.dart');

#source('dartemis/component.dart');
#source('dartemis/component_mapper.dart');
#source('dartemis/component_type.dart');
#source('dartemis/component_type_manager.dart');

#source('dartemis/entity.dart');
#source('dartemis/entity_manager.dart');

#source('dartemis/entity_system.dart');
#source('dartemis/entity_processing_system.dart');
#source('dartemis/delayed_entity_system.dart');
#source('dartemis/delayed_entity_processing_system.dart');
#source('dartemis/interval_entity_system.dart');
#source('dartemis/interval_entity_processing_system.dart');

#source('dartemis/manager.dart');

#source('dartemis/system_manager.dart');
#source('dartemis/system_bit_manager.dart');
#source('dartemis/tag_manager.dart');
#source('dartemis/group_manager.dart');

#source('dartemis/world.dart');

// TODO remove when this is implemented http://news.dartlang.org/2012/06/proposal-for-first-class-types-in-dart.html
class Type implements Hashable {
  final String classname;
  const Type(this.classname);
  int hashCode() => classname.hashCode();
  bool operator==(other) => other is Type && classname == other.classname;
}