import '../../../core/domain/image_ref.dart';
import '../../../core/domain/result.dart';

/// Which artwork shows a challenge's progress.
enum ChallengeArtwork {
  /// The donut colours in by quarters.
  donut,

  /// An arc fills around the coffee cup.
  coffee;

  static ChallengeArtwork fromName(String name) => ChallengeArtwork.values
      .firstWhere((a) => a.name == name, orElse: () => ChallengeArtwork.donut);
}

/// An "Eat more earn more" challenge.
final class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.progress,
    required this.goal,
    required this.rewardPoints,
    required this.artwork,
    required this.image,
  });

  final String id;
  final String title;
  final int progress;
  final int goal;
  final int rewardPoints;
  final ChallengeArtwork artwork;
  final ImageRef image;

  bool get isComplete => goal > 0 && progress >= goal;

  /// 0..1 completion, used to drive the artwork.
  double get fraction => goal <= 0 ? 0 : (progress / goal).clamp(0.0, 1.0);
}

/// A reward in the Gift tab.
final class Gift {
  const Gift({
    required this.id,
    required this.title,
    required this.pointsCost,
    required this.image,
  });

  final String id;
  final String title;
  final int pointsCost;
  final ImageRef image;
}

abstract interface class RewardsRepository {
  Stream<List<Challenge>> watchChallenges();
  Stream<List<Gift>> watchGifts();

  /// Visual-only in this build; kept behind the interface for a real API.
  Future<Result<void>> claimChallenge(String challengeId);
}
