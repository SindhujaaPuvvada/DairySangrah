import '../../models/user.dart';
import '../supabaseService.dart';

class DbServicesForUser {
  Future<void> infoToServer(User userInfo) async {
    final userData = userInfo.toDB();
    return await SupabaseService.client.from('Users').insert(userData);
  }

  Future<Map<String, dynamic>?> infoFromServer(String uid) async {
    return await SupabaseService.client
        .from('Users')
        .select()
        .eq('userId', uid)
        .maybeSingle();
  }

  Future<String> getChosenLanguage(String uid) async {
    final Map<String, dynamic> data = await SupabaseService.client
        .from('Users')
        .select()
        .eq('userId', uid)
        .single();
    return data['chosenLanguage'] ?? 'en';
  }

  Future<void> updateFCMToken(String uid, String? fcmToken) async {
    await SupabaseService.client
        .from('Users')
        .update({
          'fcmToken': fcmToken,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('userId', uid);
    return;
  }

  Future<void> updateToServerUserInfo(
    String uid,
    String userName,
    String chosenLang,
  ) async {
    await SupabaseService.client
        .from('Users')
        .update({
          'userName': userName,
          'chosenLanguage': chosenLang,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('userId', uid);
    return;
  }

  Future<String> getUserNameFromId(String uid) async {
    final data = await SupabaseService.client
        .from('Users')
        .select('userName')
        .eq('userId', uid)
        .single();
    return data['userName'];
  }
}
