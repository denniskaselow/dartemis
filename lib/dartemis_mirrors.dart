library dartemis;

import 'package:dartemis/dartemis.dart' hide World;
export 'package:dartemis/dartemis.dart' hide World;
import 'package:dartemis/dartemis.dart' as core show World;

@MirrorsUsed(targets: const [Component, ComponentMapper, EntitySystem, Manager])
import 'dart:mirrors';

part 'src/mirrors/world.dart';