import 'package:farm_expense_mangement_app/models/milk.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';

class DbServicesForMilk {
  Future<void> infoToServerMilk(Milk milk) async {
    return await SupabaseService.client.from('Milk').insert(milk.toDB());
  }

  Future<void> deleteAllMilkRecordsForDate(String farmId,
      DateTime dateOfMilk,) async {
    return await SupabaseService.client
        .from('Milk')
        .delete()
        .eq('farmId', farmId)
        .eq('milkingDate', dateOfMilk.toString().split('.')[0]);
  }

  Future<List<Map<String, dynamic>>> infoFromServerMilk(String farmId,
      DateTime date,) async {
    return await SupabaseService.client
        .from('Milk')
        .select()
        .eq('farmId', farmId)
        .eq('milkingDate', date.toString().split('.')[0])
        .order('createdAt', ascending: false);
  }

  Future<List<Map<String, dynamic>>> infoFromServerAllMilk(
      String farmId,) async {
    return await SupabaseService.client
        .from('Milk')
        .select()
        .eq('farmId', farmId)
        .order('createdAt', ascending: false);
  }

  Future<void> updateToServerMilkQuantity(String milkId, double newMorQty,
      double newEveQty) async {
    await SupabaseService.client
        .from('Milk')
        .update({
      'morningMilk': newMorQty,
      'eveningMilk': newEveQty,
      'updatedAt': DateTime.now().toIso8601String().split('.')[0],
    })
        .eq('milkId', milkId);
  }

  Future<List<Map<String, dynamic>>> getMilkLCSpots(String viewType,
      String viewId,
      String farmId,
      DateTime startDate,
      DateTime endDate,) async {
    return await SupabaseService.client.rpc(
      'get_milk_lc_data',
      params: {
        'view_type': viewType,
        'view_id': viewId,
        'farm_id': farmId,
        'start_date': startDate.toIso8601String().split('.')[0],
        'end_date': endDate.toIso8601String().split('.')[0],
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMilkSaleBCData(String farmId,
      DateTime startDate,
      DateTime endDate,) async {
    return await SupabaseService.client.rpc(
      'get_milk_sale_bc_data',
      params: {
        'farm_id': farmId,
        'start_date': startDate.toIso8601String().split('.')[0],
        'end_date': endDate.toIso8601String().split('.')[0],
      },
    );
  }

  Future<Map<String, dynamic>?> getMilkAggregates(String viewType,
      String viewId,
      String farmId,
      DateTime startDate,
      DateTime endDate,) async {
    return await SupabaseService.client.rpc(
      'get_aggregates_milk_produced',
      params: {
        'view_type': viewType,
        'view_id': viewId,
        'farm_id': farmId,
        'start_date': startDate.toIso8601String().split('.')[0],
        'end_date': endDate.toIso8601String().split('.')[0],
      },
    ).maybeSingle();
  }
}
