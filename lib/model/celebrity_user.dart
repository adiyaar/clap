class CelebrityUser {
  String? name;
  String? mobile;
  String? image;
  String? id;
  String? age;
  String? address;

  CelebrityUser({this.name, this.mobile, this.image, this.id});

  CelebrityUser.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobile = json['mobile'];
    image = json['image'];
    id = json['id'];
    age = json['age'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['image'] = this.image;
    data['id'] = this.id;
    data['age'] = this.age;
    data['address'] = this.address;
    return data;
  }
}
