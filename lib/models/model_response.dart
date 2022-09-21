// To parse this JSON data, do
//
//     final modelResponse = modelResponseFromJson(jsonString);

import 'dart:convert';

ModelResponse modelResponseFromJson(String str) =>
    ModelResponse.fromJson(json.decode(str));

String modelResponseToJson(ModelResponse data) => json.encode(data.toJson());

class ModelResponse {
  ModelResponse({
    required this.message,
    required this.result,
  });

  String message;
  List<Result> result;

  factory ModelResponse.fromJson(Map<String, dynamic> json) => ModelResponse(
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    required this.message,
    required this.input,
    required this.prediction,
    required this.page,
    required this.requestFileId,
    required this.filepath,
    required this.id,
    required this.rotation,
    required this.fileUrl,
    required this.requestMetadata,
  });

  String message;
  String input;
  List<Prediction> prediction;
  int page;
  String requestFileId;
  String filepath;
  String id;
  int rotation;
  String fileUrl;
  String requestMetadata;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        message: json["message"],
        input: json["input"],
        prediction: List<Prediction>.from(
            json["prediction"].map((x) => Prediction.fromJson(x))),
        page: json["page"],
        requestFileId: json["request_file_id"],
        filepath: json["filepath"],
        id: json["id"],
        rotation: json["rotation"],
        fileUrl: json["file_url"],
        requestMetadata: json["request_metadata"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "input": input,
        "prediction": List<dynamic>.from(prediction.map((x) => x.toJson())),
        "page": page,
        "request_file_id": requestFileId,
        "filepath": filepath,
        "id": id,
        "rotation": rotation,
        "file_url": fileUrl,
        "request_metadata": requestMetadata,
      };
}

class Prediction {
  Prediction({
    required this.id,
    required this.label,
    required this.xmin,
    required this.ymin,
    required this.xmax,
    required this.ymax,
    required this.score,
    required this.ocrText,
    required this.type,
    required this.status,
    required this.pageNo,
    required this.labelId,
  });

  String id;
  String label;
  int xmin;
  int ymin;
  int xmax;
  int ymax;
  double score;
  String ocrText;
  String type;
  String status;
  int pageNo;
  String labelId;

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        id: json["id"],
        label: json["label"],
        xmin: json["xmin"],
        ymin: json["ymin"],
        xmax: json["xmax"],
        ymax: json["ymax"],
        score: json["score"].toDouble(),
        ocrText: json["ocr_text"],
        type: json["type"],
        status: json["status"],
        pageNo: json["page_no"],
        labelId: json["label_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "xmin": xmin,
        "ymin": ymin,
        "xmax": xmax,
        "ymax": ymax,
        "score": score,
        "ocr_text": ocrText,
        "type": type,
        "status": status,
        "page_no": pageNo,
        "label_id": labelId,
      };
}
