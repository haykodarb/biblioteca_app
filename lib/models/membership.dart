import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class Membership {
  final String id;
  final DateTime created_at;
  final DateTime? joined_at;
  final Profile member;
  final Community community;
  final bool? member_accepted;
  final bool? admin_accepted;
  final bool is_admin;

  final RxBool loading = false.obs;

  Membership({
    required this.id,
    required this.created_at,
    required this.joined_at,
    required this.member,
    required this.community,
    required this.member_accepted,
    required this.admin_accepted,
    required this.is_admin,
  });

  Membership.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        joined_at = DateTime.tryParse(map['joined_at'] ?? '')?.toLocal(),
        community = Community.fromMap(map['communities']),
        member = Profile.fromMap(map['profiles']),
        member_accepted = map['member_accepted'],
        admin_accepted = map['admin_accepted'],
        is_admin = map['is_admin'];
}
