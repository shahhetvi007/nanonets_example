import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:nanonets_example/models/model.dart';
import 'package:nanonets_example/models/model_response.dart';

class ApiHelper {
  final httpClient = http.Client();
  String username = "SDisLzvf6l14JknFTLOp59bH7NvzD0Lm";
  String password = "";

  void createModel() async {
    final url = Uri.parse("https://app.nanonets.com/api/v2/OCR/Model/");
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    final headers = {
      "Content-type": "application/json",
      "authorization": basicAuth
    };
    final body = jsonEncode({
      "categories": ["Date", "Merchant_Address"],
      "model_type": "ocr"
    });
    try {
      http.Response res =
          await httpClient.post(url, headers: headers, body: body);
      Model model = modelFromJson(res.body);
      print(model.modelId);
      // uploadTrainingImage(model.modelId);
    } catch (e) {
      print(e);
    }
  }

  void uploadTrainingImage() async {
    final url = Uri.parse(
        "https://app.nanonets.com/api/v2/OCR/Model/826172be-458a-42bc-a772-7dccdcc9a47a/UploadFile/");
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    final headers = {
      "Content-type": "multipart/form-data",
      "authorization": basicAuth,
      "category": ""
    };
    var bytes =
        (await rootBundle.load('assets/receipt1.jpeg')).buffer.asUint8List();
    FormData formData = FormData.fromMap({
      'data':
          http.MultipartFile.fromBytes('img', bytes, filename: 'receipt1.jpeg'),
    });
    var dio = Dio();
    await dio.postUri(url, data: formData, options: Options(headers: headers));
  }

  void checkImage() async {
    var imageUrl =
        'https://fee.org/media/20251/best-ever-receipt.jpg?width=417&height=551';
    final url = Uri.parse(
        "https://app.nanonets.com/api/v2/OCR/Model/826172be-458a-42bc-a772-7dccdcc9a47a/LabelUrls/?async=false");
    final body = {
      "urls": imageUrl,
    };
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    final headers = {
      "Content-type": "application/x-www-form-urlencoded",
      "authorization": basicAuth
    };
    try {
      http.Response res =
          await httpClient.post(url, headers: headers, body: body);
      print(res.body);
      ModelResponse model = modelResponseFromJson(res.body);
      print(model.result[0].prediction[0].ocrText);
      print(model.result[0].prediction[1].ocrText);
    } catch (e) {
      print(e);
    }
  }

  Future<ModelResponse> checkImageFromFile(File image) async {
    print('in method');
    const url =
        "https://app.nanonets.com/api/v2/OCR/Model/826172be-458a-42bc-a772-7dccdcc9a47a/LabelFile/";
    // var bytes =
    //     (await rootBundle.load('assets/receipt1.jpeg')).buffer.asUint8List();
    String fileName = image.path.split('/').last;
    print(fileName);
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        image.path,
        filename: fileName,
        contentType: MediaType("image", "jpeg"),
      ),
    });
    String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    final headers = {
      "Content-type": "multipart/form-data",
      "Authorization": basicAuth,
    };
    try {
      var dio = Dio();
      Response response = await dio.post(url,
          data: formData, options: Options(headers: headers));
      print(response.data);
      ModelResponse modelResponse = ModelResponse.fromJson(response.data);
      print(modelResponse.result[0].prediction[0].ocrText);
      print(modelResponse.result[0].prediction[1].ocrText);
      return modelResponse;
    } catch (e) {
      print(e);
      throw Future.error(e);
    }
  }
}
