import '../../models/query.dart';
import '../supabaseService.dart';

class DbServicesForQueries{
  Future<void> infoToServer(Query queryInfo) async {
    final queryDetails = queryInfo.toDB();
    return await SupabaseService.client.from('Queries').insert(queryDetails);
  }
}