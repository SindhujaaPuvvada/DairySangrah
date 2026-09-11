import 'package:farm_expense_mangement_app/services/database/breedDatabase.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import '../../models/cattle.dart';

class DbServicesForCattle {
  Future<void> infoToServerSingleCattle(Cattle cattle) async {
    Map<String, dynamic> breedData;
    if (cattle.breed != null) {
      breedData = await DbServicesForBreed().getBreedDataFromName(
        cattle.breed!,
      );
      cattle.breedId = breedData['breedId'];
    }

    return await SupabaseService.client.from('Cattle').insert(cattle.toDB());
  }

  Future<Map<String, dynamic>> infoFromServer(String cattleId) async {
    Map<String, dynamic> data = await SupabaseService.client
        .from('Cattle')
        .select('*,Breeds(breedName)')
        .eq('cattleId', cattleId)
        .single();

    return data;
  }

  Future<List<Map<String, dynamic>>> infoFromServerAllCattle(
    String farmId,
  ) async {
    List<Map<String, dynamic>> dataList = await SupabaseService.client
        .from('Cattle')
        .select('*, Breeds(breedName)')
        .eq('farmId', farmId)
         .order('createdAt', ascending: true);
    return dataList;
  }

  Future<void> deleteCattle(String cattleId) async {
    // Close all open notifications of the cattle
    await SupabaseService.client
        .from('Notifications')
        .update({
          'ntClosedDate': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('ntLevel', 'Cattle')
        .eq('ntRelatedTo', cattleId)
        .isFilter('ntClosedDate', null);

    // Delete all events in the 'CattleEvents' table for the cattleId
    await SupabaseService.client
        .from('CattleEvents')
        .delete()
        .eq('cattleId', cattleId);

    // Now delete the cattle data
    await SupabaseService.client
        .from('Cattle')
        .delete()
        .eq('cattleId', cattleId);

    return;
  }

  Future<void> updateCattleState(String cattleId, String state) async {
    String now = DateTime.now().toIso8601String().split('.')[0];
    await SupabaseService.client
        .from('Cattle')
        .update({'state': state, 'updatedAt': now})
        .eq('cattleId', cattleId);
    return;
  }

  Future<void> updateCattleRepStatus(String cattleId, String repStatus) async {
    String now = DateTime.now().toIso8601String().split('.')[0];
    await SupabaseService.client
        .from('Cattle')
        .update({'reproductiveStatus': repStatus, 'updatedAt': now})
        .eq('cattleId', cattleId);
    return;
  }

  Future<void> updateCattleStateRepStatus(
    String cattleId,
    String state,
    String repStatus,
  ) async {
    String now = DateTime.now().toIso8601String().split('.')[0];
    await SupabaseService.client
        .from('Cattle')
        .update({
          'state': state,
          'reproductiveStatus': repStatus,
          'updatedAt': now,
        })
        .eq('cattleId', cattleId);
    return;
  }

  Future<void> updateToServerSingleCattle(Cattle cattle) async {
    String now = DateTime.now().toIso8601String().split('.')[0];
    Map<String, dynamic> breedData;
    if (cattle.breed != null) {
      breedData = await DbServicesForBreed().getBreedDataFromName(
        cattle.breed!,
      );
      cattle.breedId = breedData['breedId'];
    }
    await SupabaseService.client
        .from('Cattle')
        .update({
          'nickName': cattle.nickName,
          'breedId': cattle.breedId,
          'sex': cattle.sex,
          'weight': cattle.weight,
          'source': cattle.source,
          'dateOfBirth': cattle.dateOfBirth != null
              ? cattle.dateOfBirth.toString().split('.')[0]
              : null,
          'motherInfo': cattle.motherInfo,
          'fatherInfo': cattle.fatherInfo,
          'updatedAt': now,
        })
        .eq('cattleId', cattle.cattleId);
    return;
  }
}
