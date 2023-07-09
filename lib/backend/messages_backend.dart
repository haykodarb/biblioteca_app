import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesBackend {
  static Future<BackendResponse> submitMessage(Profile receiver, String content) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    try {
      final Map<String, dynamic> response = await client
          .from('messages')
          .insert(
            {
              'sender': userId,
              'receiver': receiver.id,
              'content': content,
            },
          )
          .select('*, receiver_profile:profiles!receiver(*),sender_profile:profiles!sender(*)')
          .single();

      return BackendResponse(
        success: true,
        payload: Message.fromMap(response),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static Future<BackendResponse> getDistinctChats() async {
    final SupabaseClient client = Supabase.instance.client;

    final List<Map<String, dynamic>> distinctChats = await client
        .from('distinct_chats')
        .select('*, receiver_profile:profiles!receiver(*),sender_profile:profiles!sender(*)');

    final List<Message> messages = <Message>[];

    for (Map<String, dynamic> chat in distinctChats) {
      final Message message = Message.fromMap(chat);

      final bool shouldAdd = !distinctChats.any(
        (Map<String, dynamic> element) {
          final bool chatExists = element['sender'] == message.receiver.id && element['receiver'] == message.sender.id;

          final bool chatIsMoreRecent = message.created_at.compareTo(DateTime.parse(element['created_at'])) < 0;

          return chatExists && chatIsMoreRecent;
        },
      );

      if (shouldAdd) {
        messages.add(message);
      }
    }

    return BackendResponse(
      success: messages.isNotEmpty,
      payload: messages,
    );
  }

  static Future<BackendResponse> getMessagesWithUser(Profile user, int currentIndex) async {
    final SupabaseClient client = Supabase.instance.client;
    final String currentUserId = client.auth.currentUser!.id;

    final String filter =
        'and(sender.eq.$currentUserId, receiver.eq.${user.id}), and(sender.eq.${user.id}, receiver.eq.$currentUserId)';

    final List<dynamic> response = await client
        .from('messages')
        .select('*, receiver_profile:profiles!receiver(*),sender_profile:profiles!sender(*)')
        .or(filter)
        .range(currentIndex * 100, currentIndex * 100 + 100 - 1)
        .order(
          'created_at',
          ascending: false,
        )
        .catchError(
      () {
        return BackendResponse(success: false, payload: 'Network error');
      },
    );

    final List<Message> listOfMessages = response.map(
      (element) {
        return Message.fromMap(element);
      },
    ).toList();

    return BackendResponse(
      success: true,
      payload: listOfMessages,
    );
  }

  static Future<void> markMessagesWithUserAsRead(Profile user) async {
    final SupabaseClient client = Supabase.instance.client;
    final String currentUserId = client.auth.currentUser!.id;

    final String filter =
        'and(sender.eq.$currentUserId, receiver.eq.${user.id}), and(sender.eq.${user.id}, receiver.eq.$currentUserId)';

    await client
        .from('messages')
        .update(
          {'is_read': true},
        )
        .or(filter)
        .eq('is_read', false)
        .select();
  }

  static Future<BackendResponse> getMessageWithId(String uuid) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? response = await client
        .from('messages')
        .select('*, receiver_profile:profiles!receiver(*),sender_profile:profiles!sender(*)')
        .eq('id', uuid)
        .maybeSingle();

    if (response == null) {
      return BackendResponse(success: false, payload: null);
    }

    return BackendResponse(
      success: response.isNotEmpty,
      payload: Message.fromMap(response),
    );
  }
}
