import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mydemoapp/addData_view.dart';
import 'package:mydemoapp/userdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mydemoapp/database.dart';

final duration = const Duration(milliseconds: 300);
final routeObserver = RouteObserver<PageRoute>();


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My App Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  
Map data;
List userFromJson;
GlobalKey _fabKey = GlobalKey();
final DatabaseHelper databaseHelper = DatabaseHelper();
List<UserData> userList = List<UserData>();

Future<List<UserData>> getJsonData() async
{
  
  http.Response response = await http.get("https://reqres.in/api/users?page=1");
  data = json.decode(response.body);

  setState(() {
  userFromJson = data["data"];
  int count = userFromJson.length;

    for (int i = 0; i < count; i++) {
        UserData userData = UserData();
        userData.id = userFromJson[i]['id'];
        userData.email = userFromJson[i]['email'];
        userData.firstName = userFromJson[i]['first_name'];
        userData.lastName = userFromJson[i]['last_name'];
        userList.add(userData);
        databaseHelper.insertUser(userData);
    }
  });
  return userList;
}

@override
  void initState() {
    super.initState();
    userList = getJsonData() as List<UserData>;
  }


@override
Widget build(BuildContext context){

return Scaffold(
  appBar: AppBar(
    title: Text("My Demo App"),
    backgroundColor: Colors.blue,
  ),

body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.882,
              child: FutureBuilder(
                future: databaseHelper.getUserList(),
                builder: (BuildContext context, AsyncSnapshot<List<UserData>> snapshot) {
                  if (snapshot == null) {
                    return Text('Loading');
                  } else {
                    if (snapshot.data.length < 1) {
                      return Center(
                        child: Text('No User List, Create new list'),
                      );
                    }
                    return ListView.builder(
                      itemCount: userList == null ? 0 : userList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              title: Text("${userList[index].firstName} ${userList[index].lastName}" ),
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => AddUserData(
                                          userData: snapshot.data[index],
                                        ));
                                Navigator.push(context, route);
                              },
                            ),
                            Divider(color: Theme.of(context).accentColor)
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),

      floatingActionButton: _buildFAB(context, key: _fabKey),

); 

}
Widget _buildFAB(context, {key}) => FloatingActionButton(
        elevation: 0,
        key: key,
        onPressed: () => _onFabTap(context),
        child: Icon(Icons.add),
      );

_onFabTap(BuildContext context) {
    final RenderBox fabRenderBox = _fabKey.currentContext.findRenderObject();
    final fabSize = fabRenderBox.size;
    final fabOffset = fabRenderBox.localToGlobal(Offset.zero);

    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          AddUserData(),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) =>
          _buildTransition(child, animation, fabSize, fabOffset),
    ));
  }

  Widget _buildTransition(
    Widget page,
    Animation<double> animation,
    Size fabSize,
    Offset fabOffset,
  ) {
    if (animation.value == 1) return page;

    final borderTween = BorderRadiusTween(
      begin: BorderRadius.circular(fabSize.width / 2),
      end: BorderRadius.circular(0.0),
    );
    final sizeTween = SizeTween(
      begin: fabSize,
      end: MediaQuery.of(context).size,
    );
    final offsetTween = Tween<Offset>(
      begin: fabOffset,
      end: Offset.zero,
    );

    final easeInAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );
    final easeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    final radius = borderTween.evaluate(easeInAnimation);
    final offset = offsetTween.evaluate(animation);
    final size = sizeTween.evaluate(easeInAnimation);

    final transitionFab = Opacity(
      opacity: 1 - easeAnimation.value,
      child: _buildFAB(context),
    );


Widget positionedClippedChild(Widget child) => Positioned(
        width: size.width,
        height: size.height,
        left: offset.dx,
        top: offset.dy,
        child: ClipRRect(
          borderRadius: radius,
          child: child,
        ));

      }

}
