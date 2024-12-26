import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          ? ProjectsList(
              notifier: _notifier,
            )
          : NoCompositionsFoundWidget(),
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
  const NoCompositionsFoundWidget({super.key});

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
  final ProjectsNotifier notifier;
  const ProjectsList({super.key, required this.notifier});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onProjectsChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onProjectsChanged);
    super.dispose();
  }

  void _onProjectsChanged() {
    setState(() {});
  }

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
            'Last modified: ${composition.lastModified.toString().split('.')[0]}',
          ),
          onTap: () => context.go('/studio/project/${composition.index}'),
        );
      },
    );
  }
}
