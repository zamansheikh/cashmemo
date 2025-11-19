import 'package:equatable/equatable.dart';
import '../../../domain/entities/cash_memo.dart';

abstract class CashMemoEvent extends Equatable {
  const CashMemoEvent();

  @override
  List<Object?> get props => [];
}

class LoadCashMemos extends CashMemoEvent {}

class AddCashMemo extends CashMemoEvent {
  final CashMemo cashMemo;

  const AddCashMemo(this.cashMemo);

  @override
  List<Object?> get props => [cashMemo];
}

class DeleteCashMemo extends CashMemoEvent {
  final String id;

  const DeleteCashMemo(this.id);

  @override
  List<Object?> get props => [id];
}

class GenerateMemoNumber extends CashMemoEvent {}

class FilterCashMemosByDateRange extends CashMemoEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterCashMemosByDateRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}
