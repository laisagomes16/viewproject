import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/project_model.dart';

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});

class ProjectState {
  final bool isLoading;
  final List<ProjectModel> projects;
  final String? error;

  ProjectState({
    this.isLoading = false,
    this.projects = const [],
    this.error,
  });

  ProjectState copyWith({
    bool? isLoading,
    List<ProjectModel>? projects,
    String? error,
  }) {
    return ProjectState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      error: error,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  final _dio = Dio();
  static const _baseUrl = 'http://10.0.2.2:8080/api/v1/projects';

  ProjectNotifier() : super(ProjectState());

  Future<void> fetchProjects(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        ),
      );
      
      final projects = (response.data as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
      
      state = state.copyWith(
        isLoading: false,
        projects: projects,
      );
    } on DioException catch (e) {
      print(e.toString());
      String backendMessage = '';

      if (e.response != null && e.response?.data != null) {
        backendMessage += '\n' + (e.response?.data['error'] ?? e.response.toString());
      } else {
        backendMessage += '\n' + e.message!;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: backendMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado ao carregar projetos: ${e.toString()}',
      );
    }
  }

  Future<void> addProject(String token, String title, String? description) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'nome': title,
          'descricao': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        ),
      );
      
      final newProject = ProjectModel.fromJson(response.data);
      state = state.copyWith(
        isLoading: false,
        projects: [...state.projects, newProject],
      );
    } catch (e) {
      print(e.toString());

      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao adicionar projeto.',
      );
    }
  }

  Future<void> updateProject(String token, int id, String title, String? description) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: {
          'nome': title,
          'descricao': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        ),
      );
      
      final updatedProject = ProjectModel.fromJson(response.data);
      final updatedProjects = state.projects.map((project) {
        return project.id == id ? updatedProject : project;
      }).toList();
      
      state = state.copyWith(
        isLoading: false,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao atualizar projeto.',
      );
    }
  }

  Future<void> deleteProject(String token, int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.delete(
        '$_baseUrl/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        ),
      );
      
      final updatedProjects = state.projects.where((project) => project.id != id).toList();
      state = state.copyWith(
        isLoading: false,
        projects: updatedProjects,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao excluir projeto.',
      );
    }
  }
} 