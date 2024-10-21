class UploadFileResponse {
  String? fileName;
  bool? error;
  String? message;

  UploadFileResponse(
      {this.fileName, this.error, this.message, required bool success});

  UploadFileResponse.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    error = json['error'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileName'] = fileName;
    data['error'] = error;
    data['message'] = message;
    return data;
  }
}
