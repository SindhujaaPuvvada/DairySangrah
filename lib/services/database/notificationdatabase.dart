import 'package:farm_expense_mangement_app/services/supabaseService.dart';

import '../../models/notification.dart';

class DbServicesForNotification {
  DbServicesForNotification();

  Future<void> infoToServerSingleNotification(CattleNotification ntf) async {
    return await SupabaseService.client
        .from('Notifications')
        .insert(ntf.toDB());
  }

  Future<List<Map<String, dynamic>>> infoFromServer(String ntId) async {
    return await SupabaseService.client
        .from('Notifications')
        .select()
        .eq('ntId', ntId)
        .order('ntShowDate', ascending: false);
  }

  Future<List<Map<String, dynamic>>> infoFromServerAllNotifications(
    String farmId,
  ) async {
    return await SupabaseService.client
        .from('Notifications')
        .select()
        .eq('farmId', farmId)
        .order('ntShowDate', ascending: false);
  }

  Future<void> closeNotificationByTitle(String cattleId, String title) async {
    await SupabaseService.client
        .from('Notifications')
        .update({
          'ntClosedDate': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('ntLevel', 'Cattle')
        .eq('ntRelatedTo', cattleId)
        .eq('ntTitle', title);
    return;
  }

  Future<void> closeNotification(String ntId) async {
    String now = DateTime.now().toIso8601String().split('.')[0];
    return await SupabaseService.client
        .from('Notifications')
        .update({'ntClosedDate': now})
        .eq('ntId', ntId);
  }
}
