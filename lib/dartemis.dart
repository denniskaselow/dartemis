library dartemis;

import 'dart:collection';
import 'dart:core';
import 'dart:math' as Math;

part 'src/utils/bag.dart';
part 'src/utils/fast_math.dart';
part 'src/utils/read_only_bag.dart';
part 'src/utils/trigometry_lookup_table.dart';
part 'src/utils/utils.dart';

part 'src/component.dart';
part 'src/component_mapper.dart';
part 'src/component_manager.dart';
part 'src/component_type.dart';
part 'src/component_type_manager.dart';
part 'src/free_components.dart';

part 'src/aspect.dart';

part 'src/entity.dart';
part 'src/entity_manager.dart';
part 'src/entity_observer.dart';

part 'src/entity_system.dart';
part 'src/systems/entity_processing_system.dart';
part 'src/systems/delayed_entity_processing_system.dart';
part 'src/systems/interval_entity_system.dart';
part 'src/systems/interval_entity_processing_system.dart';
part 'src/systems/void_entity_system.dart';

part 'src/manager.dart';

part 'src/system_bit_manager.dart';

part 'src/managers/group_manager.dart';
part 'src/managers/player_manager.dart';
part 'src/managers/tag_manager.dart';
part 'src/managers/team_manager.dart';
part 'src/ext/entity_state_machine.dart';

part 'src/world.dart';
