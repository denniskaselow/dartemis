library dartemis;

import 'dart:core';
import 'dart:collection';
import 'dart:math' as Math;

part 'src/core/utils/bag.dart';
part 'src/core/utils/fast_math.dart';
part 'src/core/utils/trigometry_lookup_table.dart';
part 'src/core/utils/utils.dart';
part 'src/core/utils/object_pool.dart';

part 'src/core/component.dart';
part 'src/core/component_mapper.dart';
part 'src/core/component_manager.dart';
part 'src/core/component_type.dart';
part 'src/core/component_type_manager.dart';

part 'src/core/aspect.dart';

part 'src/core/entity.dart';
part 'src/core/entity_manager.dart';
part 'src/core/entity_observer.dart';

part 'src/core/entity_system.dart';
part 'src/core/systems/entity_processing_system.dart';
part 'src/core/systems/delayed_entity_processing_system.dart';
part 'src/core/systems/interval_entity_system.dart';
part 'src/core/systems/interval_entity_processing_system.dart';
part 'src/core/systems/void_entity_system.dart';

part 'src/core/manager.dart';

part 'src/core/system_bit_manager.dart';

part 'src/core/managers/group_manager.dart';
part 'src/core/managers/player_manager.dart';
part 'src/core/managers/tag_manager.dart';
part 'src/core/managers/team_manager.dart';

part 'src/core/world.dart';
