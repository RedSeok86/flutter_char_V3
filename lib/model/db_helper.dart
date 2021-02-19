import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:papucon/model/model.dart';

final String profileTable = 'Profiles';
final String chatRoomTable = 'ChatRooms';

class DBHelper {
  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String profilepath = join(documentsDirectory.path, 'Profile.db');

    return await openDatabase(profilepath, version: 1,
        onCreate: (db, version) async {
      //type - 1: my,  2: firend, 3 : block
      //db.execute needs to run twice because only executes a single query.
      await db.execute('''
          CREATE TABLE $profileTable(
            pid TEXT PRIMARY KEY,
            type TEXT,
            uid TEXT,
            name TEXT,
            id TEXT,
            nickname TEXT,
            groupname TEXT,
            aboutme TEXT,
            photoUrl TEXT,
            backgroundUrl TEXT,
            chatOn TEXT  
          );
      ''');
      /* await db.execute('''
          CREATE TABLE $chatRoomTable(
            rid  TEXT PRIMARY KEY,
            user TEXT,
            alert BOOL,
            translate BOOL,
            status TEXT,
            owner TEXT,
            lastMessage TEXT
          );
        '''); */
      print('----------Tables Creating----------');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  dropProfileTable() async {
    final db = await database;
    var res = db.rawDelete("DELETE from ${profileTable}");
    return res;
  }

  //CREATE
  //Create Profile
  insertTableProfile(
    String type,
    Profile profile,
  ) async {
    final db = await database;
    var addType = profile.toMap();
    print('--------------InsertINGGGGGGGGGGGGGGGGGG------');
    addType['type'] = type;
    addType['groupname'] = addType['group'];
    addType.remove('group');
    var res = await db.insert(
      profileTable,
      addType,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return res;
  }

  //Create Chat Room
  insertTableChatRoom(ChatInfo chatInfo) async {
    final db = await database;
    final chatRoom = chatInfo.toMap();
    print('----------Insert----------');
    final res = await db.insert(
      chatRoomTable,
      chatRoom,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  //READ
  //Read Profile
  getProfile(String pid) async {
    final db = await database;
    var res =
        await db.rawQuery('SELECT * FROM ${profileTable} WHERE pid = ?', [pid]);
    return res.isNotEmpty
        ? Profile(
            res.first['uid'],
            res.first['pid'],
            res.first['id'],
            res.first['nickname'],
            res.first['aboutme'],
            res.first['photoUrl'],
            res.first['backgroundUrl'])
        : Null;
  }

  Future<List<Profile>> getProfileList(List<String> pidList) async {
    final db = await database;
    var select = 'SELECT * FROM ${profileTable} Where pid IN (\'' +
        (pidList.join('\',\'')).toString() +
        '\')';
    print('select $select');
    var res = await db.rawQuery(select);
    List<Profile> list = res.isNotEmpty
        ? res
            .map((res) => Profile(
                res['uid'],
                res['pid'],
                res['id'],
                res['nickname'],
                res['aboutme'],
                res['photoUrl'],
                res['backgroundUrl']))
            .toList()
        : [];
    return list;
  }

  //Read All Friend
  Future<List<Profile>> getFirend(String myPid) async {
    final db = await database;
    var res =
        await db.rawQuery('SELECT * FROM $profileTable WHERE type = "$myPid"');
    print(res);
    if (res.isNotEmpty) print(res.length);
    List<Profile> list = res.isNotEmpty
        ? res
            .map((res) => Profile(
                res['uid'],
                res['pid'],
                res['id'],
                res['nickname'],
                res['aboutme'],
                res['photoUrl'],
                res['backgroundUrl']))
            .toList()
        : [];
    return list;
  }

  //Read All Chat
  Future<List<ChatInfo>> getChatInfo() async {
    final db = await database;
    final res = await db.rawQuery('SELECT * FROM $chatRoomTable');
    final List<ChatInfo> list = res.isNotEmpty
        ? res
            .map((res) => ChatInfo(
                  rid: res['rid'],
                  user: res['user'],
                  alert: res['alert'],
                  translate: res['translate'],
                  status: res['status'],
                  owner: res['owner'],
                  lastMessage: res['lastMessage'],
                ))
            .toList()
        : [];
    return list;
  }

//  blockFirend(String pid){
//    final db = database;
////    var res = db.update(
////        ${profileTable},
////    );
//    return res;
//  }
  //Delete
  deleteProfile(String pid) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $profileTable WHERE pid = ?', [pid]);
    return res;
  }

  //Delete All
  deleteAllProfile() async {
    final db = await database;
    db.rawDelete('DELETE FROM ${profileTable}');
  }
}
