import '../../domain/entities/cash_memo.dart';
import '../../domain/repositories/cash_memo_repository.dart';
import '../datasources/cash_memo_local_data_source.dart';
import '../models/cash_memo_model.dart';

class CashMemoRepositoryImpl implements CashMemoRepository {
  final CashMemoLocalDataSource localDataSource;

  CashMemoRepositoryImpl(this.localDataSource);

  @override
  Future<List<CashMemo>> getAllCashMemos() async {
    return await localDataSource.getAllCashMemos();
  }

  @override
  Future<CashMemo?> getCashMemoById(String id) async {
    return await localDataSource.getCashMemoById(id);
  }

  @override
  Future<void> addCashMemo(CashMemo cashMemo) async {
    final cashMemoModel = CashMemoModel.fromEntity(cashMemo);
    await localDataSource.insertCashMemo(cashMemoModel);
  }

  @override
  Future<void> deleteCashMemo(String id) async {
    await localDataSource.deleteCashMemo(id);
  }

  @override
  Future<String> generateMemoNumber() async {
    return await localDataSource.generateMemoNumber();
  }

  @override
  Future<List<CashMemo>> getCashMemosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await localDataSource.getCashMemosByDateRange(startDate, endDate);
  }
}
