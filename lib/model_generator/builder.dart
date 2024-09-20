import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:stibu/model_generator/collections.dart';
import 'package:stibu/model_generator/common.dart';
import 'package:stibu/model_generator/model.dart';

class ModelBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        'appwrite.json': ['lib/appwrite.models.dart', 'appwrite.example.json']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.endsWith('appwrite.json')) {
      return;
    }

    final contents = await buildStep.readAsString(buildStep.inputId);

    String generatedCode = '${generateCommon()}\n\n';

    final jsonMap = json.decode(contents) as Map<String, dynamic>;
    final collectionsMap = jsonMap['collections'] as List<dynamic>;

    final Map<String, String> collectionIdToName =
        collectionsMap.fold<Map<String, String>>({}, (map, e) {
      map[e['\$id']] = e['name'];
      return map;
    });

    final List<CollectionInfo> collections = collectionsMap
        .map(
          (e) => CollectionInfo.fromMap(e, collectionIdToName),
        )
        .toList();

    generatedCode += collections.map(generateClass).join('\n\n');

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/appwrite.models.dart'),
      generatedCode,
    );

    // Generate example json
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
