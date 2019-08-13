import 'package:flutter/material.dart';
import 'package:mydemoapp/database.dart';
import 'package:mydemoapp/userdata.dart';

class AddUserData extends StatefulWidget {
  final UserData userData;
  AddUserData({this.userData});
  @override
  _AddUserDataState createState() => _AddUserDataState();
}

class _AddUserDataState extends State<AddUserData> {
  bool _isEditiable = true;
  String title = 'Add User Data';
  List<Widget> icons;
  TextEditingController _emailControllor;
  TextEditingController _firstNameControllor;
  TextEditingController _lastNameControllor;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final DatabaseHelper helper = DatabaseHelper();

  @override
  void initState() {
    _emailControllor = TextEditingController();
    _firstNameControllor = TextEditingController();
    _lastNameControllor = TextEditingController();

    _setData();
    super.initState();
  }

  @override
  void dispose() {
    _emailControllor.dispose();
    _firstNameControllor.dispose();
    super.dispose();
  }

  _setData() {
    if (widget.userData != null) {
      _isEditiable = false;
      icons = [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEditiable = !_isEditiable;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _deleteUser();
          },
        ),
        
      ];
      title = 'View';
      _emailControllor = TextEditingController(
        text: widget.userData.email,
      );
      _firstNameControllor = TextEditingController(text: widget.userData.email);
    }
  }



  _deleteUser() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure, you want to Delete This?'),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  helper.deleteUser(widget.userData.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Yes'),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
            ],
          );
        });
  }

  _showSnakbar(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      backgroundColor: Colors.brown,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  bool _checkNotNull() {
    bool res;
    if (_emailControllor.text.isEmpty && _firstNameControllor.text.isEmpty && _lastNameControllor.text.isEmpty) {
      _showSnakbar('Email , First Name and Last Name cannot be empty');
      res = false;
    } else if (_emailControllor.text.isEmpty) {
      _showSnakbar('Email cannot be empty');
      res = false;
    } else if (_firstNameControllor.text.isEmpty) {
      _showSnakbar('First Name cannot be empty');
      res = false;
    }
    else if (_lastNameControllor.text.isEmpty) {
      _showSnakbar('Last Name cannot be empty');
      res = false;
    } 
    else {
      res = true;
    }
    return res;
  }

  _saveUser() {
    if (_checkNotNull() == true) {
      if (widget.userData != null) {
        widget.userData.email = _emailControllor.text;
        widget.userData.firstName = _firstNameControllor.text;
        widget.userData.lastName = _lastNameControllor.text;

        helper.updateUser(widget.userData);
      } else {
        UserData userData =
            UserData(email: _emailControllor.text, firstName: _firstNameControllor.text, lastName: _lastNameControllor.text);
        helper.insertUser(userData);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        actions: icons,
        title: Text(title),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            TextField(
              enabled: _isEditiable ? true : false,
              controller: _emailControllor,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Email'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              enabled: _isEditiable ? true : false,
              controller: _firstNameControllor,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'First Name',
                  hintText: 'First Name'),
            ),
            SizedBox(
              height: 20,
            ),

            TextField(
              enabled: _isEditiable ? true : false,
              controller: _lastNameControllor,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Last Name',
                  hintText: 'Last Name'),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: _isEditiable
                  ? RawMaterialButton(
                      fillColor: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      onPressed: () {
                        _saveUser();
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
