import 'package:farm_expense_mangement_app/models/dairyfarm.dart';
import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';

class DbServicesForDairyFarm {
  Future<String> infoToServer(String uid, DairyFarm farm) async {
    final data = await SupabaseService.client
        .from('DairyFarms')
        .insert(farm.toDB())
        .select('farmId')
        .single();
    return data['farmId'].toString();
  }

  Future<DairyFarm> infoFromServer(String farmId) async {
    final data = await SupabaseService.client
        .from('DairyFarms')
        .select()
        .eq('farmId', farmId)
        .single();
    data['ownerName'] = await DbServicesForUser().getUserNameFromId(
      data['ownerId'],
    );
    return DairyFarm.fromDB(data);
  }

  Future<List<DairyFarm>> infoFromServerAllFarms(uid) async {
    final data = await SupabaseService.client
        .from('DairyFarms')
        .select('*,DairyFarmUsers!inner(userId)')
        .eq('DairyFarmUsers.userId', uid)
        .order('createdAt', ascending: true);

    final List<DairyFarm> data2 = data.map((r) => DairyFarm.fromDB(r)).toList();
    return data2;
  }

  Future<bool> getIsFirstLaunch(String farmId) async {
    final data = await SupabaseService.client
        .from('DairyFarms')
        .select('isFirstLaunch')
        .eq('farmId', farmId)
        .single();
    return data['isFirstLaunch'] ?? true;
  }

  Future<void> updateIsFirstLaunch(String farmId, bool firstLaunch) async {
    await SupabaseService.client
        .from('DairyFarms')
        .update({
          'isFirstLaunch': firstLaunch,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('farmId', farmId);
    return;
  }

  Future<String> getFarmMode(String farmId) async {
    final data = await SupabaseService.client
        .from('DairyFarms')
        .select('farmMode')
        .eq('farmId', farmId)
        .single();
    return data['farmMode'];
  }

  Future<void> updateFarmMode(String farmId, String modePref) async {
    await SupabaseService.client
        .from('DairyFarms')
        .update({
          'farmMode': modePref,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('farmId', farmId);
    return;
  }

  Future<void> updateToServerFarm(
    String farmId,
    String name,
    String addr,
  ) async {
    await SupabaseService.client
        .from('DairyFarms')
        .update({
          'farmName': name,
          'address': addr,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('farmId', farmId);
    return;
  }

  Future<List<Map<String, dynamic>>> getDashboardValues(String farmId) async {
    return await SupabaseService.client.rpc(
      'get_dashboard_values',
      params: {
        'farm_id': farmId,
      },
    );
  }
}
