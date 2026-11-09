import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/domain/failure.dart';
import 'package:jdonuts/features/member/domain/build_member_status.dart';

import '../helpers/fakes.dart';

void main() {
  group('buildMemberStatus', () {
    test('Silver with 1,500 tier points is 500 points from Gold (75 %)', () {
      final status = buildMemberStatus(testMember(), testTiers).valueOrNull!;
      expect(status.currentTier.name, 'Silver');
      expect(status.nextTier?.name, 'Gold');
      expect(status.pointsToNextTier, 500);
      expect(status.progressToNextTier, closeTo(0.75, 1e-9));
      expect(status.currentTierIndex, 0);
    });

    test('sorts tiers by threshold whatever order storage returns', () {
      final status = buildMemberStatus(testMember(), testTiers.reversed.toList()).valueOrNull!;
      expect(status.tiers.map((t) => t.id), ['silver', 'gold', 'platinum']);
    });

    test('the top tier has no next tier and full progress', () {
      final status = buildMemberStatus(
        testMember(tierId: 'platinum', tierPoints: 9000),
        testTiers,
      ).valueOrNull!;
      expect(status.nextTier, isNull);
      expect(status.pointsToNextTier, 0);
      expect(status.progressToNextTier, 1);
    });

    test('never reports negative points remaining', () {
      final status = buildMemberStatus(testMember(tierPoints: 2500), testTiers).valueOrNull!;
      expect(status.pointsToNextTier, 0);
      expect(status.progressToNextTier, 1);
    });

    test('fails with NotFound when the member points at an unknown tier', () {
      final result = buildMemberStatus(testMember(tierId: 'diamond'), testTiers);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });
  });
}
