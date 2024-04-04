import 'package:realm/realm.dart';
part 'newmodel.g.dart';

@RealmModel()
class _del {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String name;

  late int age;
}