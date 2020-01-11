class User {
  int id;
  String username;
  String fullname;
  String password;
  String socketId;

  User ({this.id, this.fullname, this.password, this.username, this.socketId});

  static User fromMap(Map map) {
    return User(
      id: map.containsKey('id')?map['id']:0,
      username: map.containsKey('username')?map['username']:"",
      fullname: map.containsKey('fullname')?map['fullname']:"",
      password: map.containsKey('password')?map['password']:"",
      socketId: map.containsKey('socket_id')?map['socket_id']:""
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "username": this.username,
      "fullname": this.fullname,
      "password": this.password,
      "socket_id": this.socketId
    };
  }
}