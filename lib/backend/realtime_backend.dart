import 'dart:async';

import 'package:communal/models/realtime_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeBackend {
  static final StreamController<RealtimeMessage> streamController = StreamController<RealtimeMessage>.broadcast();

  static Future<void> subscribeToDatabaseChanges() async {
    final SupabaseClient client = Supabase.instance.client;

    final RealtimeChannel channel = client
        .channel(
          'postgres_changes',
          opts: const RealtimeChannelConfig(
            self: true,
          ),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord.isNotEmpty || payload.oldRecord.isNotEmpty) {
              final RealtimeMessage realtimeMessage = RealtimeMessage(
                table: payload.table,
                new_row: payload.newRecord,
                eventType: payload.eventType,
              );

              streamController.add(realtimeMessage);
            }
          },
        );

    channel.subscribe();
  }
}
