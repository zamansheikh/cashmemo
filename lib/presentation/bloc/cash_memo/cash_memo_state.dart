import 'package:equatable/equatable.dart';
import '../../../domain/entities/cash_memo.dart';

abstract class CashMemoState extends Equatable {
  const CashMemoState();

  @override
  List<Object?> get props => [];
}

class CashMemoInitial extends CashMemoState {}

class CashMemoLoading extends CashMemoState {}

class CashMemoLoaded extends CashMemoState {
  final List<CashMemo> cashMemos;

  const CashMemoLoaded(this.cashMemos);

  @override
  List<Object?> get props => [cashMemos];
}

class CashMemoError extends CashMemoState {
  final String message;

  const CashMemoError(this.message);

  @override
  List<Object?> get props => [message];
}

class CashMemoOperationSuccess extends CashMemoState {
  final String message;

  const CashMemoOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MemoNumberGenerated extends CashMemoState {
  final String memoNumber;

  const MemoNumberGenerated(this.memoNumber);

  @override
  List<Object?> get props => [memoNumber];
}
