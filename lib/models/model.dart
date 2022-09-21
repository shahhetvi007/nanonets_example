// To parse this JSON data, do
//
//     final model = modelFromJson(jsonString);

import 'dart:convert';

Model modelFromJson(String str) => Model.fromJson(json.decode(str));

String modelToJson(Model data) => json.encode(data.toJson());

class Model {
  Model({
    required this.modelId,
    required this.modelType,
    required this.state,
    required this.status,
    required this.accuracy,
    required this.categories,
  });

  String modelId;
  String modelType;
  int state;
  String status;
  int accuracy;
  List<Category> categories;

  factory Model.fromJson(Map<String, dynamic> json) => Model(
        modelId: json["model_id"],
        modelType: json["model_type"],
        state: json["state"],
        status: json["status"],
        accuracy: json["accuracy"],
        categories: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "model_id": modelId,
        "model_type": modelType,
        "state": state,
        "status": status,
        "accuracy": accuracy,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class Category {
  Category({
    required this.name,
    required this.count,
    required this.id,
  });

  String name;
  int count;
  String id;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        count: json["count"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "count": count,
        "id": id,
      };
}
