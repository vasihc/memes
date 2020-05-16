class User {
  final String login;
  final String token;

  User({this.login, this.token});

  Map<String, dynamic> toMap() {
    return {
      'login': login,
      'token': token,
    };
  }

    
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      token: json['token'],
    );
  }
}
