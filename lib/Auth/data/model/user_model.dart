import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.uid, required super.email});

  factory UserModel.fromJson(User user) {
    return UserModel(uid: user.uid, email: user.email ?? '');
  }

  Map<String, String> toJson() {
    return {'uid': uid, 'email': email};
  }

  UserEntity toEntity() {
    return UserEntity(uid: uid, email: email);
  }
}
