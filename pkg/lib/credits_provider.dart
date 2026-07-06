import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditTransaction {
  final String id;
  final String title;
  final int amount; // positive for buy, negative for spend
  final DateTime date;
  final String type; // 'purchase' or 'spend'

  CreditTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class CreditsState {
  final int balance;
  final List<CreditTransaction> history;

  CreditsState({
    required this.balance,
    required this.history,
  });

  CreditsState copyWith({
    int? balance,
    List<CreditTransaction>? history,
  }) {
    return CreditsState(
      balance: balance ?? this.balance,
      history: history ?? this.history,
    );
  }
}

class CreditsNotifier extends StateNotifier<CreditsState> {
  CreditsNotifier()
      : super(
          CreditsState(
            balance: 150, // Default mock initial balance
            history: [
              CreditTransaction(
                id: '1',
                title: 'Gümüş Paket Yüklemesi',
                amount: 150,
                date: DateTime.now().subtract(const Duration(days: 2)),
                type: 'purchase',
              ),
              CreditTransaction(
                id: '2',
                title: 'Yüzük Tasarımı Üretimi',
                amount: -1,
                date: DateTime.now().subtract(const Duration(days: 1)),
                type: 'spend',
              ),
              CreditTransaction(
                id: '3',
                title: 'Bilezik Tasarımı Üretimi',
                amount: -1,
                date: DateTime.now().subtract(const Duration(hours: 4)),
                type: 'spend',
              ),
            ],
          ),
        );

  void addCredits(int amount, String packageName) {
    final transaction = CreditTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$packageName Satın Alımı',
      amount: amount,
      date: DateTime.now(),
      type: 'purchase',
    );
    state = state.copyWith(
      balance: state.balance + amount,
      history: [transaction, ...state.history],
    );
  }

  bool spendCredits(int amount, String description) {
    if (state.balance < amount) {
      return false; // Insufficient credits
    }
    final transaction = CreditTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: description,
      amount: -amount,
      date: DateTime.now(),
      type: 'spend',
    );
    state = state.copyWith(
      balance: state.balance - amount,
      history: [transaction, ...state.history],
    );
    return true;
  }
}

final creditsProvider = StateNotifierProvider<CreditsNotifier, CreditsState>((ref) {
  return CreditsNotifier();
});
