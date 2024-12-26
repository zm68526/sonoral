import 'package:flutter/material.dart';

import '../data_structures/composition_data_structures.dart';
import '../local_storage/local_storage_handler.dart';

class StudioSplash extends StatefulWidget {
  const StudioSplash({super.key});

  @override
  State<StudioSplash> createState() => _StudioSplashState();
}

class _StudioSplashState extends State<StudioSplash> {
  final _notifier = ProjectsNotifier();
  var hasCompositions = getCompositions().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasCompositions
          ? ProjectsList()
          : NoCompositionsFoundWidget(
              notifier: _notifier,
            ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await saveComposition(
          Composition.fromString(
            'Untitled⦀Tempuser⦀⦀${DateTime.now().millisecondsSinceEpoch}⦀',
            null,
          ),
        );
        _notifier.notifyProjectsListChanged();
        if (!hasCompositions) {
          setState(() {
            hasCompositions = true;
          });
        }
      }),
    );
  }
}

class NoCompositionsFoundWidget extends StatelessWidget {
  final ProjectsNotifier notifier;
  const NoCompositionsFoundWidget({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No compositions found'),
    );
  }
}

class ProjectsNotifier extends ChangeNotifier {
  void notifyProjectsListChanged() {
    notifyListeners();
  }
}

class ProjectsList extends StatefulWidget {
  const ProjectsList({super.key});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  @override
  Widget build(BuildContext context) {
    var compositions = getCompositions();
    return ListView.builder(
      itemCount: compositions.length,
      itemBuilder: (context, index) {
        final composition = compositions[index];
        return ListTile(
          title: Text(composition.name),
          subtitle: Text(
            'Last modified: ${composition.lastModified.toString().split(' ')[0]}',
          ),
        );
      },
    );
  }
}
