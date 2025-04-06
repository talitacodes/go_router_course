class AuthRepository {
  User? loggedUser;
  bool get isLoggedIn => loggedUser != null;
}

class User {
  final bool premium;

  User(this.premium);
}
