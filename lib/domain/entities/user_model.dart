class UserModel {
  final int userId; 
  final String name;
  final String email;
  final String password;
  final String userIdAuth; 

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.userIdAuth
  });

  // Método para convertir un objeto User a un Map (por ejemplo, para insertar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      
      'name': name,
      'email': email,
      'password': password,
      'userIdAuth': userIdAuth,
    };
  }

  // Método para crear un objeto User desde un Map (por ejemplo, al leer de la base de datos)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userid'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      userIdAuth: map['userIdAuth'] as String,
    );
  }
}
