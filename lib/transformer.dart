library transformer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/scanner.dart';
import 'package:analyzer/src/generated/testing/ast_factory.dart';
import 'package:analyzer/src/generated/testing/token_factory.dart';
import 'package:dart_style/dart_style.dart';

part 'src/transformer/component_to_pooled_component_converter.dart';
part 'src/transformer/initialize_method_converter.dart';
part 'src/transformer/dartemis_transformer.dart';
part 'src/transformer/utils/asset_wrapper.dart';

