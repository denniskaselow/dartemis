library dartemis_mirrors;

import 'package:dartemis/dartemis.dart' hide World;
export 'package:dartemis/dartemis.dart' hide World;
import 'package:dartemis/dartemis.dart' as core show World;

@MirrorsUsed(targets: const [ComponentMapper, Manager, EntitySystem])
import 'dart:mirrors';

part 'src/mirrors/world.dart';