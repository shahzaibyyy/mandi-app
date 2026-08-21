import 'package:hive/hive.dart';

part 'fee_type.g.dart';

@HiveType(typeId: 1)
class FeeType extends HiveObject {
  FeeType({
    required this.id,
    this.marketId,
    required this.name,
    required this.unitLabel,
    required this.defaultRate,
    this.isActive = true,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String? marketId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String unitLabel;

  @HiveField(4)
  double defaultRate;

  @HiveField(5)
  bool isActive;
}