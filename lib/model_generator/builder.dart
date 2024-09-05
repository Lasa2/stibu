import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:stibu/model_generator/common.dart';
import 'package:stibu/model_generator/model.dart';

class ModelBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        'appwrite.json': ['lib/appwrite.models.dart']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.endsWith('appwrite.json')) {
      return;
    }

    final contents = await buildStep.readAsString(buildStep.inputId);

    String generatedCode = '${generateCommon()}\n\n';

    final jsonMap = json.decode(contents) as Map<String, dynamic>;
    final collections = (jsonMap['collections'] as List<dynamic>)
        .map((collection) => collection as Map<String, dynamic>)
        .toList();

    generatedCode += collections.map(generateClass).join('\n\n');

    const outputPath = 'lib/appwrite.models.dart';
    await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, outputPath), generatedCode);
  }
}
