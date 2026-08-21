import 'package:hive/hive.dart';

part 'market.g.dart';

@HiveType(typeId: 0)
class Market extends HiveObject {
  Market({
    required this.id,
    required this.name,
    required this.cityDistrict,
    required this.companyHeaderName,
    this.address,
    required this.createdAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String cityDistrict;

  @HiveField(3)
  String companyHeaderName;

  @HiveField(4)
  String? address;

  @HiveField(5)
  DateTime createdAt;
}