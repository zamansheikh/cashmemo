import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/cash_memo_repository.dart';
import 'cash_memo_event.dart';
import 'cash_memo_state.dart';

class CashMemoBloc extends Bloc<CashMemoEvent, CashMemoState> {
  final CashMemoRepository cashMemoRepository;

  CashMemoBloc(this.cashMemoRepository) : super(CashMemoInitial()) {
    on<LoadCashMemos>(_onLoadCashMemos);
    on<AddCashMemo>(_onAddCashMemo);
    on<DeleteCashMemo>(_onDeleteCashMemo);
    on<GenerateMemoNumber>(_onGenerateMemoNumber);
    on<FilterCashMemosByDateRange>(_onFilterCashMemosByDateRange);
  }

  Future<void> _onLoadCashMemos(
    LoadCashMemos event,
    Emitter<CashMemoState> emit,
  ) async {
    emit(CashMemoLoading());
    try {
      final cashMemos = await cashMemoRepository.getAllCashMemos();
      emit(CashMemoLoaded(cashMemos));
    } catch (e) {
      emit(CashMemoError(e.toString()));
    }
  }

  Future<void> _onAddCashMemo(
    AddCashMemo event,
    Emitter<CashMemoState> emit,
  ) async {
    try {
      await cashMemoRepository.addCashMemo(event.cashMemo);
      emit(const CashMemoOperationSuccess('Cash Memo created successfully'));
      add(LoadCashMemos());
    } catch (e) {
      emit(CashMemoError(e.toString()));
    }
  }

  Future<void> _onDeleteCashMemo(
    DeleteCashMemo event,
    Emitter<CashMemoState> emit,
  ) async {
    try {
      await cashMemoRepository.deleteCashMemo(event.id);
      emit(const CashMemoOperationSuccess('Cash Memo deleted successfully'));
      add(LoadCashMemos());
    } catch (e) {
      emit(CashMemoError(e.toString()));
    }
  }

  Future<void> _onGenerateMemoNumber(
    GenerateMemoNumber event,
    Emitter<CashMemoState> emit,
  ) async {
    try {
      final memoNumber = await cashMemoRepository.generateMemoNumber();
      emit(MemoNumberGenerated(memoNumber));
      // Reload cash memos to prevent infinite loading on dashboard
      add(LoadCashMemos());
    } catch (e) {
      emit(CashMemoError(e.toString()));
    }
  }

  Future<void> _onFilterCashMemosByDateRange(
    FilterCashMemosByDateRange event,
    Emitter<CashMemoState> emit,
  ) async {
    emit(CashMemoLoading());
    try {
      final cashMemos = await cashMemoRepository.getCashMemosByDateRange(
        event.startDate,
        event.endDate,
      );
      emit(CashMemoLoaded(cashMemos));
    } catch (e) {
      emit(CashMemoError(e.toString()));
    }
  }
}
