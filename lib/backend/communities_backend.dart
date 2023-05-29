import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesBackend {
  static Future<bool> isUserAdmin(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic> membershipResponse = await client.from('memberships').select().match(
      {
        'member': userId,
        'community': community.id,
      },
    ).maybeSingle();

    return membershipResponse.isNotEmpty && (membershipResponse['is_admin'] as bool);
  }

  static Future<BackendResponse> getCommunitiesForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('memberships')
        .select('id, created_at, joined_at, member, is_admin, accepted, communities(id, name, description)')
        .match({
      'member': userId,
      'accepted': true,
    }).order(
      'joined_at',
      ascending: true,
    );

    print(response);

    if (response.isEmpty) {
      return BackendResponse(success: false, payload: null);
    }

    final List<Community> listOfCommunities = response
        .map(
          (dynamic element) => Community(
            name: element['communities']['name'],
            description: element['communities']['description'],
            id: element['communities']['id'],
            isCurrentUserAdmin: element['is_admin'],
          ),
        )
        .toList();

    return BackendResponse(success: true, payload: listOfCommunities);
  }

  static Future<BackendResponse> createCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic> createCommunityResponse = await client
        .from('communities')
        .insert(
          {
            'name': community.name,
            'description': community.description,
            'created_by': userId,
          },
        )
        .select()
        .single();

    if (createCommunityResponse.isEmpty) {
      return BackendResponse(
        success: false,
        payload: '',
      );
    }

    final Map<String, dynamic> createMembershipResponse = await client
        .from('memberships')
        .insert(
          {
            'member': userId,
            'community': createCommunityResponse['id'],
            'is_admin': true,
            'joined_at': DateTime.now().toIso8601String(),
          },
        )
        .select()
        .single();

    return BackendResponse(
      success: createMembershipResponse.isNotEmpty,
      payload: createMembershipResponse,
    );
  }
}
