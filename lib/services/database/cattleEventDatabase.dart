import 'package:farm_expense_mangement_app/models/event.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';

class DbServiceForCattleEvents {
  DbServiceForCattleEvents();

  Future<void> eventToServerSingleCattle(CattleEvent cattleEvent) async {
    return await SupabaseService.client
        .from('CattleEvents')
        .insert(cattleEvent.toDB());
  }

  Future<List<Map<String, dynamic>>> eventsFromServer(String cattleId) async {
    return await SupabaseService.client
        .from('CattleEvents')
        .select()
        .eq('cattleId', cattleId)
        .order('createdAt', ascending: false);
  }

  Future<String> getLastAISireDetails(String cattleId) async {
    final List<Map<String, dynamic>> eventsData = await SupabaseService.client
        .from('CattleEvents')
        .select()
        .eq('cattleId', cattleId)
        .eq('eventName', 'Insemination');

    if (eventsData.isNotEmpty) {
      var allAIEvents = eventsData.map((r) => CattleEvent.fromDB(r)).toList();
      allAIEvents.sort((a, b) {
        // Custom sorting logic here
        // Example: sort by a field called 'name'
        DateTime dateA = a.eventDate;
        DateTime dateB = b.eventDate;
        return dateB.compareTo(dateA); // descending order
      });
      return allAIEvents[0].notes ?? '';
    } else {
      return '';
    }
  }
}
