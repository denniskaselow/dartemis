#library('dartemis');

#import('dart:coreimpl');

#source('dartemis/utils/bag.dart');
#source('dartemis/utils/fast_math.dart');
#source('dartemis/utils/immutable_bag.dart');
#source('dartemis/utils/timer.dart');
#source('dartemis/utils/trigometry_lookup_table.dart');
#source('dartemis/utils/utils.dart');

#source('dartemis/component.dart');
#source('dartemis/component_type.dart');
#source('dartemis/component_type_manager.dart');

#source('dartemis/entity.dart');
#source('dartemis/entity_manager.dart');
#source('dartemis/entity_system.dart');

#source('dartemis/manager.dart');

#source('dartemis/system_manager.dart');
#source('dartemis/tag_manager.dart');
#source('dartemis/group_manager.dart');

#source('dartemis/world.dart');



main() {
  print(new ComponentType());


  print(new Bag<Entity>());
  print(new World());
}