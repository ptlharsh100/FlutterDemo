class UserData {
  int id;
  String email;
  String firstName;
  String lastName;
  UserData({this.id, this.email, this.firstName, this.lastName});

  get length => null;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['email'] = email;
    map['first_name'] = firstName;
    map['last_name'] = lastName;

    return map;
  }

  void add(UserData user) {}
}
