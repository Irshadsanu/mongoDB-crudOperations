import 'package:flutter/material.dart';
import 'package:mongocrudtest/newmodel.dart';
import 'package:mongocrudtest/schema.dart';
import 'package:realm/realm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

enum MenuOption { edit, delete }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Realm realm;
  User? user;
  late App app;

  void handleMenuClick(BuildContext context, MenuOption menuItem, Dog item,) {
    switch (menuItem) {
      case MenuOption.edit:



        break;
      case MenuOption.delete:

        realm.write(() => realm.delete(item));
        break;
    }
  }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  Future<void> appSing() async {
    setState(() async {
      app = App(AppConfiguration('devicesync-cwlmu'));
      user = await app.logIn(Credentials.anonymous());
      realm = Realm(Configuration.flexibleSync(user!, [Dog.schema]));
      realm.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm.all<Dog>(), name: "getAllItemsSubscription");
        // mutableSubscriptions.add(realm.all<del>(), name : "getAllItemsSubscription");
        // mutableSubscriptions
        //     .add(realm.query<Dog>(r'name == $0 AND age > $1', ));
      });
      await realm.subscriptions.waitForSynchronization();
    });


  }

  void createItem() {
    final newItem =
    Dog(ObjectId(), "summaryirshad", 25,);
    realm.write<Dog>(() => realm.add<Dog>(newItem));

  }


  void delete(){
    // realm.write(() => realm.delete(item));
    // realm.deleteMany(realm.all('Dog',));

    realm.write(() {
      realm.deleteMany(realm.all<Dog>());
    });

  }

  void addData(){
    // if(realm.isClosed){
    //   realm.config;

    setState(() {
      print("start");
      // }
        realm.write(() {
          realm.add(Dog(ObjectId(), 'irshad', 25));
        });
        final dogs = realm.all<Dog>();




      print("finish ");
    });
user?.customData('mongodb-atlas').database('Dog');


  }


  void createMultipleItems(int count) {
    realm.write(() {
      for (int i = 0; i < count; i++) {
        final newItem = Dog(
          ObjectId(),
          'asif data',
          i
        );
        realm.add(newItem);
      }
      print("finish loop");
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    appSing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:  Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: StreamBuilder<RealmResultsChanges<Dog>>(
            stream: realm
                .query<Dog>("TRUEPREDICATE SORT(_id DESC)")
                .changes,
            builder: (context, snapshot) {
              final data = snapshot.data;

              if (data == null) return const CircularProgressIndicator();

              final results = data.results;
              print(results.toString()+"2561");
              return ListView.builder(
                shrinkWrap: true,
                itemCount: results.realm.isClosed ? 0 : results.length,
                itemBuilder: (context, index) => results[index].isValid
                    ?  ListTile(
                  leading: SizedBox(
                    width: 25,
                    child: PopupMenuButton<MenuOption>(
                      onSelected: (menuItem) =>
                          handleMenuClick(context, menuItem, results[index]),
                      itemBuilder: (context) => [
                        const PopupMenuItem<MenuOption>(
                          value: MenuOption.edit,
                          child: ListTile(
                              leading: Icon(Icons.edit), title: Text("Edit item")),
                        ),
                        const PopupMenuItem<MenuOption>(
                          value: MenuOption.delete,
                          child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text("Delete item")),
                        ),
                      ],
                    ),
                  ),
                  title: Text(results[index].name,style: TextStyle(color: Colors.white)),
                  trailing: Text(results[index].age.toString(),style: TextStyle(color: Colors.white)),
                  shape: const Border(bottom: BorderSide()),
                )
                    : Container(),
              );
            },
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: createItem,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: delete,
            tooltip: 'zscd',
            child: const Icon(Icons.details),
          ),
          FloatingActionButton(
            onPressed: () {
              createMultipleItems(100);
            },
            tooltip: 'sdac',
            child: const Icon(Icons.access_time_filled_outlined),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
