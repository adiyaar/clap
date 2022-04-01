class ServiceList {
  String? serviceId;
  String? userId;
  String? title;
  String? descriptio;
  String? price;
  

  ServiceList({this.serviceId, this.descriptio, this.price, this.title,this.userId});

  ServiceList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    descriptio = json['description'];
    price = json['price'];
    userId = json['userid'];
    serviceId = json['id'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.descriptio;
    data['price'] = this.price;
    data['id'] = this.serviceId;
    data['userid'] = this.userId;
    
    return data;
  }
}
