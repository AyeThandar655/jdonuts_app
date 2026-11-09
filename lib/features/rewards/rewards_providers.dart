import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import 'data/drift_rewards_repository.dart';
import 'domain/rewards.dart';

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => DriftRewardsRepository(ref.watch(appDatabaseProvider)),
);

final challengesProvider = StreamProvider<List<Challenge>>(
  (ref) => ref.watch(rewardsRepositoryProvider).watchChallenges(),
);

final giftsProvider = StreamProvider<List<Gift>>(
  (ref) => ref.watch(rewardsRepositoryProvider).watchGifts(),
);
