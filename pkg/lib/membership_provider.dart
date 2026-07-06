import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MembershipTier {
  bireyselFree,
  kobiPremium,
}

class MembershipState {
  final MembershipTier tier;

  MembershipState({required this.tier});

  String get displayName {
    switch (tier) {
      case MembershipTier.bireyselFree:
        return 'Bireysel Free';
      case MembershipTier.kobiPremium:
        return 'KOBİ Premium';
    }
  }

  bool get isKobiPremium => tier == MembershipTier.kobiPremium;
}

class MembershipNotifier extends StateNotifier<MembershipState> {
  MembershipNotifier() : super(MembershipState(tier: MembershipTier.bireyselFree));

  void updateTier(MembershipTier newTier) {
    state = MembershipState(tier: newTier);
  }
}

final membershipProvider = StateNotifierProvider<MembershipNotifier, MembershipState>((ref) {
  return MembershipNotifier();
});
