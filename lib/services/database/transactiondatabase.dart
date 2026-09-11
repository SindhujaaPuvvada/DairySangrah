import 'package:farm_expense_mangement_app/models/sales.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import '../../models/expenses.dart';

class DbForSale {
  DbForSale();

  Future<List<Map<String, dynamic>>> infoFromServerAllTransactions(
    String farmId,
  ) async {
    return await SupabaseService.client
        .from('Sales')
        .select()
        .eq('farmId', farmId)
        .order('saleDate', ascending: false);
  }

  Future<String> infoToServerSale(Sale sale) async {
    final data = await SupabaseService.client
        .from('Sales')
        .insert(sale.toDB())
        .select()
        .single();
    return data['saleId'].toString();
  }

  Future<String> infoToServerCattleSale(CattleSale cSale) async {
    return await SupabaseService.client
        .from('CattleSales')
        .insert(cSale.toDB());
  }

  Future<String> infoToServerMilkSale(MilkSale mSale) async {
    return await SupabaseService.client.from('MilkSales').insert(mSale.toDB());
  }

  Future<void> deleteSaleFromServer(String saleId, String saleType) async {
    if (saleType.contains('Cattle')) {
      await SupabaseService.client
          .from('CattleSales')
          .delete()
          .eq('saleId', saleId);
    } else {
      if (saleType.contains('Milk')) {
        await SupabaseService.client
            .from('MilkSales')
            .delete()
            .eq('saleId', saleId);
      }
    }

    return await SupabaseService.client
        .from('Sales')
        .delete()
        .eq('saleId', saleId);
  }

  Future<Map<String, dynamic>?> infoFromServerSaleOnDate(
    String name,
    DateTime saleDate,
    String farmId,
  ) async {
    final sDate = saleDate.toString().split('.')[0];

    return await SupabaseService.client
        .from('Sales')
        .select()
        .eq('saleType', name)
        .eq('saleDate', sDate)
        .eq('farmId', farmId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> infoFromSaleByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    final sDate = startDate.toString().split('.')[0];
    final eDate = endDate.add(Duration(days: 1)).toString().split('.')[0];

    return await SupabaseService.client
        .from('Sales')
        .select()
        .eq('farmId', farmId)
        .gte('saleDate', sDate)
        .lt('saleDate', eDate)
        .order('saleDate', ascending: false);
  }

  Future<void> updateToServerSale(
    String saleId,
    String newSaleType,
    double newSaleAmount,
  ) async {
    return await SupabaseService.client
        .from('Sales')
        .update({
          'saleType': newSaleType,
          'amount': newSaleAmount,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('saleId', saleId);
  }

  Future<void> updateExistingSaleToServer(String saleId, double amount) async {
    return await SupabaseService.client
        .from('Sales')
        .update({
          'amount': amount,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('saleId', saleId);
  }
  Future<List<Map<String,dynamic>>> infoFromServerMilkSales(String saleId) async{
    return await SupabaseService.client
        .from('MilkSales')
        .select()
        .eq('saleId', saleId)
        .order('saleId', ascending: false);
  }
}

class DbForExpense {
  DbForExpense();

  Future<List<Map<String, dynamic>>> infoFromServerAllTransactions(
    String farmId,
  ) async {
    return await SupabaseService.client
        .from('Expenses')
        .select()
        .eq('farmId', farmId)
        .order('expenseDate', ascending: false);
  }

  Future<String> infoToServerExpense(Expense expense) async {
    final data = await SupabaseService.client
        .from('Expenses')
        .insert(expense.toDB())
        .select()
        .single();
    return data['expenseId'].toString();
  }

  Future<String> infoToServerFeedExpense(FeedExpense fExp) async {
    return await SupabaseService.client.from('FeedExpense').insert(fExp.toDB());
  }

  Future<void> deleteExpenseFromServer(String expId, String expType) async {
    if (expType.contains('Feed')) {
      await SupabaseService.client
          .from('FeedExpense')
          .delete()
          .eq('expenseId', expId);
    }

    return await SupabaseService.client
        .from('Expenses')
        .delete()
        .eq('expenseId', expId);
  }

  Future<Map<String, dynamic>?> infoFromServerExpenseOnDate(
    String name,
    DateTime expDate,
    String farmId,
  ) async {
    final sDate = expDate.toString().split('.')[0];

    return await SupabaseService.client
        .from('Expenses')
        .select()
        .eq('expenseType', name)
        .eq('expenseDate', sDate)
        .eq('farmId', farmId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> infoFromExpenseByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    final sDate = startDate.toString().split('.')[0];
    final eDate = endDate.add(Duration(days: 1)).toString().split('.')[0];

    return await SupabaseService.client
        .from('Expenses')
        .select()
        .eq('farmId', farmId)
        .gte('expenseDate', sDate)
        .lt('expenseDate', eDate)
        .order('expenseDate', ascending: false);
  }

  Future<void> updateToServerExpense(
    String expenseId,
    String newExpType,
    double newExpAmount,
  ) async {
    return await SupabaseService.client
        .from('Expenses')
        .update({
          'expenseType': newExpType,
          'amount': newExpAmount,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('expenseId', expenseId);
  }

  Future<void> updateExistingExpenseToServer(
    String expType,
    DateTime expDate,
    double amount,
  ) async {
    return await SupabaseService.client
        .from('Expenses')
        .update({
          'amount': amount,
          'updatedAt': DateTime.now().toIso8601String().split('.')[0],
        })
        .eq('expenseType', expType)
        .eq('expenseDate', expDate.toString().split('.')[0]);
  }
}

class DbForTransactions{
  Future<List<Map<String, dynamic>>> getTransactionData(String farmId,
      DateTime startDate,
      DateTime endDate,) async {
    return await SupabaseService.client.rpc(
      'get_transaction_data',
      params: {
        'farm_id': farmId,
        'start_date': startDate.toIso8601String().split('.')[0],
        'end_date': endDate.toIso8601String().split('.')[0],
      },
    );
  }
}