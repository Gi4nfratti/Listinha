import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:listinha/models/item.dart';
import 'package:listinha/models/list.dart';
import 'package:listinha/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DAO {
  Future<Database> openDB() async {
    return await openDatabase('listinha.db');
  }

  Future<int> saveUser(String email, String pwd) async {
    var db = await openDB();
    int status = 999;
    await db
        .execute(
            'CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY, email TEXT, pwd TEXT)')
        .whenComplete(() async => await db.execute(
            'CREATE TABLE IF NOT EXISTS lists(id INTEGER, fid TEXT NOT NULL, name TEXT, imageurl TEXT, PRIMARY KEY (id, fid))'))
        .whenComplete(() async => await db.execute(
            'CREATE TABLE IF NOT EXISTS sublists(id INTEGER PRIMARY KEY, fid TEXT, name TEXT, imageurl TEXT, subid TEXT REFERENCES lists(fid))'))
        .whenComplete(() async => await db.execute(
            'CREATE TABLE IF NOT EXISTS items(id INTEGER, fid TEXT PRIMARY KEY, desc TEXT, isConcluded BOOLEAN, subid TEXT REFERENCES sublists(fid))'))
        .whenComplete(() async => status = await db.insert("user", {
              'email': email,
              'pwd': pwd,
            }));

    return status;
  }

  Future<void> signOut() async {
    var db = await openDB();
    await db
        .execute('DROP TABLE IF EXISTS user')
        .whenComplete(() => db.execute('DROP TABLE IF EXISTS lists'))
        .whenComplete(() => db.execute('DROP TABLE IF EXISTS sublists'))
        .whenComplete(() => db.execute('DROP TABLE IF EXISTS items'));
  }

  Future<void> getTime(String cloudTime) async {
    try {
      String url = 'https://worldtimeapi.org/api/timezone/America/Sao_Paulo/';
      final prefs = await SharedPreferences.getInstance();

      var res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        String dateServer = jsonDecode(res.body)['week_number'].toString();
        if (cloudTime.isEmpty || dateServer == "1" || cloudTime != dateServer) {
          await processFirebaseRoutine();
          prefs.setString('cloudTime', dateServer);
        }
      }
    } on Exception {}
  }

  Future<bool> saveMenuItem(ListM item) async {
    try {
      Map<String, Object?> d = {
        'fid': item.fId,
        'name': item.name,
        'imageurl': item.image,
      };
      var db = await openDB();
      await db.insert('lists', d, conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveSubItem(ListM item) async {
    try {
      Map<String, Object?> d = {
        'fid': item.fId,
        'name': item.name,
        'imageurl': item.image,
        'subid': item.subFId
      };
      print("${d['fid']} || ${d['name']} || ${d['imageurl']} || ${d['subid']}");
      var db = await openDB();
      await db.insert('sublists', d,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveItem(Item item) async {
    try {
      var d = {
        'fid': item.fId,
        'desc': item.desc,
        'isConcluded': item.isConcluded,
        'subid': item.subFid
      };
      var db = await openDB();
      await db.insert('items', d, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List> getLists() async {
    var db = await openDB();
    return await db.query(
      'lists',
      columns: ['fid, name, imageurl'],
    );
  }

  Future<List> getSubLists(String mainId) async {
    var db = await openDB();
    return await db.query('sublists',
        columns: ['fid, subid, name, imageurl'],
        where: 'subid = ?',
        whereArgs: [mainId]);
  }

  Future<List> getItems(String mainId) async {
    var db = await openDB();
    return await db.query('items', where: 'subid = ?', whereArgs: [mainId]);
  }

  Future<bool> updateItemStatus(Item item) async {
    try {
      var obj = {
        'fid': item.fId,
        'desc': item.desc,
        'isConcluded': item.isConcluded,
        'subid': item.subFid
      };
      var db = await openDB();
      await db.insert('items', obj,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItemDesc(Item item) async {
    try {
      var obj = {
        'fid': item.fId,
        'desc': item.desc,
        'isConcluded': item.isConcluded,
        'subid': item.subFid
      };
      var db = await openDB();
      await db.insert('items', obj,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isItemExists(String id) async {
    try {
      var db = await openDB();
      await db.query('lists',
          columns: ['fid'], where: 'fid = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      return false;
    }
  }

  deleteItem(String fId) async {
    var db = await openDB();
    await db.delete('items', where: 'fid = ?', whereArgs: [fId]);
  }

  Future<void> processFirebaseRoutine() async {
    FirebaseDAO fDao = FirebaseDAO();
    List lists = await getLists();

    lists.forEach((list) async {
      ListM listItem = ListM(
        fId: list['fid'],
        image: list['imageurl'],
        name: list['name'],
      );
      await fDao.uploadListToFirebase(listItem).whenComplete(() async {
        List sublists = await getSubLists(listItem.fId);
        sublists.forEach((sublist) async {
          ListM sublistItem = ListM(
            fId: sublist['fid'],
            image: sublist['imageurl'],
            name: sublist['name'],
            subFId: sublist['subid'],
          );
          await fDao.uploadSubListsToCloud(sublistItem).whenComplete(() async {
            List items = await getItems(sublistItem.fId);
            items.forEach((item) async {
              Item auxItem = Item(
                fId: item['fid'],
                subFid: item['subid'],
                desc: item['desc'],
                isConcluded: item['isConcluded'] == 0 ? false : true,
              );
              await fDao.uploadItemsToCloud(auxItem, sublistItem.subFId);
            });
          });
        });
      });
    });
  }

  Future<List> getToCloudLists() async {
    var db = await openDB();
    return await db.query(
      'lists',
      columns: ['fid, name, imageurl'],
      where: 'toCloud = ?',
      whereArgs: [1],
    );
  }

  Future<List> getToCloudSubLists() async {
    var db = await openDB();
    return await db.query(
      'sublists',
      columns: ['fid, subid, name, imageurl'],
      where: 'toCloud = ?',
      whereArgs: [1],
    );
  }

  Future<List> getToCloudItems() async {
    var db = await openDB();
    return await db.query(
      'items',
      where: 'toCloud = ?',
      whereArgs: [1],
    );
  }
}

class FirebaseDAO {
  Future<List<ListM>> getLists() async {
    try {
      List<ListM> listsResult = [];
      Map<String, dynamic> result = {};
      User user = new User();
      var email = await user.getEmail();
      await FirebaseFirestore.instance
          .collection('task')
          .doc(email)
          .get(GetOptions(source: Source.cache))
          .then(
        (value) {
          result = Map.of(value.data()!['base']['lists']);

          result.forEach((key, value) => listsResult.add(
              ListM(fId: key, image: value['imageURL'], name: value['name'])));
        },
      );
      return listsResult;
    } on Exception {
      return [];
    }
  }

  Future<bool> uploadListToFirebase(ListM item) async {
    try {
      User user = new User();
      var email = await user.getEmail();
      var doc = await FirebaseFirestore.instance.collection('task').doc(email);
      doc.set({
        'base': {
          'lists': {
            '${item.fId}': {
              'name': item.name,
              'imageURL': item.image,
            }
          }
        }
      }, SetOptions(merge: true));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> uploadSubListsToCloud(ListM item) async {
    try {
      User user = new User();
      var email = await user.getEmail();
      var doc = await FirebaseFirestore.instance.collection('task').doc(email);
      doc.set({
        'base': {
          'lists': {
            '${item.subFId}': {
              'subLists': {
                '${item.fId}': {
                  'imageURL': item.image,
                  'name': item.name,
                }
              }
            }
          }
        }
      }, SetOptions(merge: true));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> uploadItemsToCloud(Item item, String mainListId) async {
    try {
      User user = new User();
      var email = await user.getEmail();
      var doc = await FirebaseFirestore.instance.collection('task').doc(email);
      doc.set({
        'base': {
          'lists': {
            '${mainListId}': {
              'subLists': {
                '${item.subFid}': {
                  'items': {
                    '${item.fId}': {
                      'desc': item.desc,
                      'isConcluded': item.isConcluded
                    }
                  }
                }
              }
            }
          }
        }
      }, SetOptions(merge: true));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<String> getImageURL(String fileName) async => FirebaseStorage.instance
      .ref('/images')
      .child(fileName)
      .getDownloadURL()
      .then((value) => value.toString());

  Future<bool> getInitialValues() async {
    try {
      User user = new User();
      var email = await user.getEmail();
      await FirebaseFirestore.instance
          .collection('task')
          .doc(email)
          .get()
          .then((value) => _processLists(value));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _processLists(
      DocumentSnapshot<Map<String, dynamic>> value) async {
    DAO dao = new DAO();
    Map<String, dynamic> menuList = {};

    try {
      if (value.data() != null) {
        menuList = Map.of(value.data()!['base']['lists']);
        if (menuList.isNotEmpty) {
          menuList.forEach((key, value) async {
            dao.saveMenuItem(ListM(
              fId: key,
              image: value['imageURL'],
              name: value['name'],
            ));

            var sublists = value['subLists'];
            if (sublists != null && sublists.isNotEmpty)
              await _processSubLists(sublists as Map<String, dynamic>, key);
          });
        }
      }
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _processSubLists(
      Map<String, dynamic> sublists, String mainKey) async {
    DAO dao = new DAO();
    try {
      sublists.forEach((key, value) async {
        dao.saveSubItem(ListM(
            fId: key,
            image: value['imageURL'],
            name: value['name'],
            subFId: mainKey));

        var itemlist = value['items'];
        if (itemlist != null && itemlist.isNotEmpty)
          await _processItems(itemlist as Map<String, dynamic>, key);
      });
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _processItems(
      Map<String, dynamic> itemlist, String mainSubKey) async {
    DAO dao = new DAO();
    try {
      itemlist.forEach((key, value) {
        if ((value['desc'] as String).isNotEmpty) {
          dao.saveItem(Item(
            fId: key,
            subFid: mainSubKey,
            desc: value['desc'],
            isConcluded: value['isConcluded'],
          ));
        }
      });
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> testingFBatchs() async {
    User user = new User();
    var email = await user.getEmail();
    var doc = await FirebaseFirestore.instance.collection('task').doc(email);

    var listsNode = doc;

    var batch = FirebaseFirestore.instance.batch();
    List<Map<String, Object>> mapList = [
      {
        "987654": {
          "testeNum": "987",
          "testeDesc": "desc1",
        },
        "123456": {
          "testeNum": "123",
          "testeDesc": "desc2",
        },
      }
    ];

    var combinedMap = {
      "lists": {
        for (var map in mapList) ...map,
      }
    };

    batch.set(listsNode, {
      "base": {combinedMap}
    });
    batch.commit();

    /*
    try {
      User user = new User();
      var email = await user.getEmail();
      var doc = await FirebaseFirestore.instance.collection('task').doc(email);
      doc.set({
        'base': {
          'lists': {
            '${item.fId}': {
              'name': item.name,
              'imageURL': item.image,
            }
          }
        }
      }, SetOptions(merge: true));
      return true;
    } on Exception {
      return false;
    }
     */
  }
}
