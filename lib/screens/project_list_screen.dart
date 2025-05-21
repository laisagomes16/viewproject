import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import 'login_screen.dart';
import 'weather_screen.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final token = await ref.read(authProvider.notifier).getToken();
    if (token != null) {
      await ref.read(projectProvider.notifier).fetchProjects(token);
    }
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Projeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _titleController.clear();
              _descriptionController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await ref.read(authProvider.notifier).getToken();
              if (token != null) {
                await ref.read(projectProvider.notifier).addProject(
                      token,
                      _titleController.text,
                      _descriptionController.text,
                    );
                if (!mounted) return;
                Navigator.of(context).pop();
                _titleController.clear();
                _descriptionController.clear();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(int id, String currentTitle, String? currentDescription) {
    _titleController.text = currentTitle;
    _descriptionController.text = currentDescription ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Projeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _titleController.clear();
              _descriptionController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await ref.read(authProvider.notifier).getToken();
              if (token != null) {
                await ref.read(projectProvider.notifier).updateProject(
                      token,
                      id,
                      _titleController.text,
                      _descriptionController.text,
                    );
                if (!mounted) return;
                Navigator.of(context).pop();
                _titleController.clear();
                _descriptionController.clear();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        title: const Text('Projetos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeatherScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: projectState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projectState.error != null
              ? Center(child: Text(projectState.error!))
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: projectState.projects.length,
                    itemBuilder: (context, index) {
                      final project = projectState.projects[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(project.nome),
                          subtitle: project.descricao != null
                              ? Text(project.descricao!)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditProjectDialog(
                                  project.id!,
                                  project.nome,
                                  project.descricao,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final token = await ref
                                      .read(authProvider.notifier)
                                      .getToken();
                                  if (token != null) {
                                    await ref
                                        .read(projectProvider.notifier)
                                        .deleteProject(token, project.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
