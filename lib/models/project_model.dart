class ProjectModel {
  final int? id;
  final String nome;           
  final String? descricao;     
  final String? createdAt;
  final String? updatedAt;

  ProjectModel({
    this.id,
    required this.nome,
    this.descricao,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      nome: json['nome'] ?? '',               
      descricao: json['descricao'],           
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,              
      'descricao': descricao,    
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
