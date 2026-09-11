import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import '../../models/inventory.dart';

class DbServicesForFeed {
  DbServicesForFeed();

  Future<void> infoToServerFeed(Inventory invData) async {
    return await SupabaseService.client
        .from('Inventory')
        .insert(invData.toDB());
  }

  // Function to get a particular feed category from DB
  Future<List<Map<String, dynamic>>> infoFromServerForCategory(
    String category,
    String farmId,
  ) async {
    return await SupabaseService.client
        .from('Inventory')
        .select()
        .eq('farmId', farmId)
        .eq('feedCategory', category)
        .gt('currentStockLevel',0)
        .order('invDate', ascending: false);
  }

  // Function to delete a feed type from DB
  Future<String> deleteFeedFromServer(String invId) async {
    bool alreadyInUse  = (await SupabaseService.client
    .from('FeedExpense')
    .select()
    .eq('invId', invId)).isNotEmpty? true : false;

    if(!alreadyInUse){
    await SupabaseService.client
        .from('Inventory')
        .delete()
        .eq('invId', invId);
    return "Success";
    }
    else{
      return "AlreadyInUse";
    }
  }

  Future<void> updateToServerStockLevel(String invId, double updQty) async {
    return await SupabaseService.client
        .from('Inventory')
        .update({
          'currentStockLevel': updQty,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('invId', invId);
  }

  Future<List<Map<String, dynamic>>> getFeedCostByCategory(String farmId,
      DateTime startDate,
      DateTime endDate,) async {
    return await SupabaseService.client.rpc(
      'get_feed_cost_by_category',
      params: {
        'farm_id': farmId,
        'start_date': startDate.toIso8601String().split('.')[0],
        'end_date': endDate.toIso8601String().split('.')[0],
      },
    );
  }

}
