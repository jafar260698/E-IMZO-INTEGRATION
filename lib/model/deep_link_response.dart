


class DeepLinkResponse {
  int status;
  String message;
  String siteId;
  String documentId;
  String challange;

  DeepLinkResponse(
      {this.status,
        this.message,
        this.siteId,
        this.documentId,
        this.challange});

  DeepLinkResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    siteId = json['siteId'];
    documentId = json['documentId'];
    challange = json['challange'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['siteId'] = this.siteId;
    data['documentId'] = this.documentId;
    data['challange'] = this.challange;
    return data;
  }

}