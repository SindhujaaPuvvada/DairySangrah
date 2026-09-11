import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbServicesForBreed {
  DbServicesForBreed();

  Future<PostgrestList> infoFromServerAllBreeds() async {
    final data = await SupabaseService.client
        .from('Breeds')
        .select()
        .order('type');
    return data;
  }

  Future<Map<String, dynamic>> getBreedDataFromName(String breed) async {
    return await SupabaseService.client
        .from('Breeds')
        .select()
        .eq('breedName', breed)
        .single();
  }
}
