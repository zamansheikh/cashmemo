import '../entities/cash_memo.dart';

abstract class CashMemoRepository {
  Future<List<CashMemo>> getAllCashMemos();
  Future<CashMemo?> getCashMemoById(String id);
  Future<void> addCashMemo(CashMemo cashMemo);
  Future<void> deleteCashMemo(String id);
  Future<String> generateMemoNumber();
  Future<List<CashMemo>> getCashMemosByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
