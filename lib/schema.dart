import 'package:realm/realm.dart';
part 'schema.g.dart';

@RealmModel()
class _Dog {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String name;

  late int age;
}