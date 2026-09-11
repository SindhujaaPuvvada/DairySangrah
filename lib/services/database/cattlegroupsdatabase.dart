import 'package:farm_expense_mangement_app/services/database/breedDatabase.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import '../../models/cattlegroups.dart';

class DbServicesForCattleGroups {
  Future<void> infoToServerSingleCattleGrp(CattleGroup cattleGrp) async {
    if (cattleGrp.breed != null) {
      final breedData = await DbServicesForBreed().getBreedDataFromName(
        cattleGrp.breed!,
      );
      cattleGrp.breedId = breedData['breedId'];
    }
    await SupabaseService.client.from('CattleGroups').insert(cattleGrp.toDB());
  }

  Future<List<Map<String, dynamic>>> infoFromServerAllCattleGrps(
    String farmId,
  ) async {
    List<Map<String, dynamic>> dataList = await SupabaseService.client
        .from('CattleGroups')
        .select('*, Breeds(breedName)')
        .eq('farmId', farmId)
        .order('breedId', ascending: true)
        .order('state', ascending: true);

    return dataList;
  }

  Future<bool> grpCriteriaExists(
    String farmId,
    String cattleType,
    String? breed,
    String status,
  ) async {
    List<Map<String, dynamic>> data;
    if (breed != null) {
      final breedData = await DbServicesForBreed().getBreedDataFromName(breed);

      data = await SupabaseService.client
          .from('CattleGroups')
          .select()
          .eq('farmId', farmId)
          .eq('type', cattleType)
          .eq('state', status)
          .eq('breedId', breedData['breedId']);
    } else {
      data = await SupabaseService.client
          .from('CattleGroups')
          .select()
          .eq('farmId', farmId)
          .eq('type', cattleType)
          .eq('state', status);
    }

    if (data.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
