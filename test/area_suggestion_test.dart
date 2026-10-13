import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:miriago/plan/area_suggestion.dart';
import 'package:miriago/plan/pilgrimage_models.dart';

const _work = PilgrimageWork(
  id: 'w',
  title: 'w',
  subtitle: '',
  city: '',
  source: WorkSource.manual,
);

PilgrimagePoint _spot(String id, double lat, double lng, {String? groupId}) =>
    PilgrimagePoint(
      id: id,
      work: _work,
      name: id,
      subtitle: '',
      position: LatLng(lat, lng),
      episodeLabel: '',
      referenceLabel: '',
      groupId: groupId,
    );

PilgrimagePlanGroup _area(String id, String name) => PilgrimagePlanGroup(
  id: id,
  name: name,
  orderIndex: 0,
  createdAt: DateTime(2026),
);

void main() {
  // Uji has spots by Uji station; Kyoto has spots 15 km north.
  final plan = PilgrimagePlan(
    id: 'p',
    name: 'p',
    area: '',
    works: const [_work],
    points: [
      _spot('uji-1', 34.8893, 135.8076, groupId: 'uji'),
      _spot('kyoto-1', 35.0116, 135.7681, groupId: 'kyoto'),
    ],
    groups: [_area('uji', '宇治'), _area('kyoto', 'Kyoto')],
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  final nearUji = [_spot('new', 34.8880, 135.8000)];

  test('an area named after the spot city wins over a nearer one', () {
    expect(matchAreaForSpots(plan, nearUji, ['Kyoto City'])?.id, 'kyoto');
    expect(matchAreaForSpots(plan, nearUji, ['宇治市'])?.id, 'uji');
  });

  test('without a name match the nearest area within 5 km is suggested', () {
    expect(matchAreaForSpots(plan, nearUji, ['Joyo'])?.id, 'uji');
    expect(matchAreaForSpots(plan, [_spot('far', 34.6, 135.5)], []), isNull);
  });
}
