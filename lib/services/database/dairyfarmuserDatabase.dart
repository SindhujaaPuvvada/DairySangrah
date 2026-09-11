import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user.dart';
import '../supabaseService.dart';

class DbServicesForDairyFarmUser {
  Future<void> infoToServer(DairyFarmUser dfu) async {
    await SupabaseService.client.from('DairyFarmUsers').insert(dfu.toDB());
  }

  Future<PostgrestList> getFarmsForUser(String uid) async {
    final data = await SupabaseService.client
        .from('DairyFarmUsers')
        .select()
        .eq('userId', uid)
        .order('createdAt', ascending: true);
    return data;
  }
}
