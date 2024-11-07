import 'dart:convert';

import 'package:appwrite_model_generator/src/appwrite_base_model.dart'
    as appwrite_base_model;
import 'package:appwrite_model_generator/src/appwrite_client.dart'
    as appwrite_client;
import 'package:appwrite_model_generator/src/appwrite_models.dart'
    as appwrite_models;
import 'package:appwrite_model_generator/src/collection_info.dart'
    as collection_info;
import 'package:appwrite_model_generator/src/collection_parser.dart';
import 'package:appwrite_model_generator/src/relation.dart' as relation;
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final _dartfmt = DartFormatter(
  fixes: StyleFix.all,
);

class ModelBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        'appwrite.json': ['lib/appwrite.models.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.endsWith('appwrite.json')) {
      return;
    }

    final contents = await buildStep.readAsString(buildStep.inputId);

    final jsonMap = json.decode(contents);
    final collections = jsonMap['collections'] as List<dynamic>;
    final Map<String, String> collectionIdToName = collections.fold(
      <String, String>{},
      (
        map,
        collection,
      ) =>
          map..[collection['\$id'] as String] = collection['name'] as String,
    );

    final library = Library((lib) {
      lib.directives.addAll([
        Directive.import('package:flutter/foundation.dart'),
        Directive.import('package:dart_helper_utils/dart_helper_utils.dart'),
        Directive.import('package:collection/collection.dart'),
        Directive.import('package:result_type/result_type.dart'),
        Directive.import('package:appwrite/models.dart'),
        Directive.import('package:appwrite/appwrite.dart'),
        Directive.import('package:get_it/get_it.dart'),
      ]);

      lib.comments.add('ignore_for_file: require_trailing_commas');

      lib.body.addAll([
        Code('final _eq = const ListEquality().equals;'),
        Code('final _hash = const ListEquality().hash;'),
        Code('final _client = GetIt.I<AppwriteClient>();'),
        Class((b) => b
          ..name = 'RLevel'
          ..fields.addAll([
            Field((b) => b
              ..name = 'includeId'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$),
            Field((b) => b
              ..name = 'includeData'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$),
            Field((b) => b
              ..name = 'includePermissions'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$),
            Field((b) => b
              ..name = 'permissions'
              ..type = refer('List<String>')
              ..modifier = FieldModifier.final$),
          ])
          ..constructors.add(Constructor((b) => b
            ..optionalParameters.addAll([
              Parameter((b) => b
                ..name = 'includeId'
                ..defaultTo = Code('true')
                ..named = true
                ..toThis = true),
              Parameter((b) => b
                ..name = 'includeData'
                ..defaultTo = Code('true')
                ..named = true
                ..toThis = true),
              Parameter((b) => b
                ..name = 'includePermissions'
                ..defaultTo = Code('false')
                ..named = true
                ..toThis = true),
              Parameter((b) => b
                ..name = 'permissions'
                ..defaultTo = Code('const []')
                ..named = true
                ..toThis = true),
            ])))),
        appwrite_base_model.getClass(),
        collection_info.getClass(),
        relation.getClass(),
        relation.getRelationType(),
        relation.getRelationOnDelete(),
        relation.getRelationSide(),
        appwrite_client.getClass(),
      ]);

      for (final collection in collections) {
        final collectionInfo =
            CollectionInfo.fromMap(collection, collectionIdToName);
        final factory = appwrite_models.ClassFactory(collectionInfo);

        lib.body.addAll(factory.build());
      }
    });

    final emitter = DartEmitter(allocator: Allocator(), orderDirectives: true);
    final output = _dartfmt.format('${library.accept(emitter)}');

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/appwrite.models.dart'),
      output,
    );
  }
}

class ExampleJsonBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        'appwrite.json': [
          'appwrite.example.json',
        ],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.endsWith('appwrite.json')) {
      return;
    }

    final contents = await buildStep.readAsString(buildStep.inputId);
    final jsonMap = json.decode(contents) as Map<String, dynamic>;

    final exampleJson = <String, dynamic>{
      'collections': jsonMap['collections'],
      'databases': jsonMap['databases'],
    };

    final jsonEncoder = JsonEncoder.withIndent(' ' * 4);
    final exampleOutput = jsonEncoder.convert(exampleJson);

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'appwrite.example.json'),
      exampleOutput,
    );
  }
}
