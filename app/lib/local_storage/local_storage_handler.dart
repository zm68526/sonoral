import '../data_structures/composition_data_structures.dart';
import 'package:hive_ce/hive.dart';

List<Composition> getCompositions() {
  final savedCompositionsBox = Hive.box('savedCompositions');
  final List compositionScripts = savedCompositionsBox.get('scripts');
  compositionScripts.removeWhere(
    (element) => element.runtimeType != String,
  );
  compositionScripts.removeWhere(
    (element) => element == '', // placeholder for first element in box
  );

  List<Composition> compositions = [];
  for (int i = 0; i < compositionScripts.length; i++) {
    compositions.add(Composition.fromString(compositionScripts[i], i));
  }

  compositions.sort(
    (a, b) => b.lastModified.compareTo(a.lastModified),
  );

  return compositions;
}

Future<void> saveComposition(Composition composition) async {
  var compositions = getCompositions();
  if (composition.index == null) {
    compositions.add(composition);
  } else {
    compositions[composition.index!] = composition;
  }

  final savedCompositionsBox = Hive.box('savedCompositions');
  await savedCompositionsBox.put('scripts', compositions.map((e) => e.toString()).toList());
}
