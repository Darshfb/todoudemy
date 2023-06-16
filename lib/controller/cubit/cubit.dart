import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/controller/cubit/states.dart';
import 'package:todo/controller/notification_services.dart';
import 'package:todo/model/model.dart';

class TodoCubit extends Cubit<TodoStates> {
  TodoCubit() : super(InitialTodoState());

  static TodoCubit get(context) => BlocProvider.of(context);

// SQl Lite
// Create our database
// create database file
// create database table
// open database file
  Database? database;

// if we have a path file name so we just open it
  // if we don't have a path file name we created it
  void createDatabase() {
    // path here is the file name
    // db DataBase
    openDatabase('File.db', version: 1, onCreate: (database, version) {
      // here our database is create (only for the first time)
      // if we don't the path file name
      debugPrint('The database is created');
      database
          .execute('CREATE TABLE tasks'
              '(id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, description TEXT)')
          .then((value) {
        // here the table is created
        debugPrint('our table is created');
      }).catchError((error) {
        // here is an error when creating our table
        debugPrint('an error when creating the table');
      });
    }, onOpen: (database) {
      debugPrint('database file is opened');
      getDataFromDatabase(database);
    }).then((value) {
      // the database file is succeed to open
      database = value;
      emit(CreateTodoDatabaseState());
    }).catchError((error) {
      debugPrint('error when opening the file');
    });
  }

  // insert to database
  void insertToDatabase({
    required String title,
    required String date,
    required String time,
    required String description,
  }) {
    database!.transaction((txn) async {
      // insert into tableName
      txn
          .rawInsert('INSERT INTO tasks'
              '(title, date, time, description) VALUES '
              '("$title", "$date", "$time", "$description")')
          .then((value) {
       id = value;
       notificationTitle = title;
       notificationDescription = description;
        debugPrint('$value is inserted successfully');
        getDataFromDatabase(database);
        emit(SuccessInsertToDatabaseState());
        scheduleNotification();
      }).catchError((error) {
        debugPrint('an error when inserting into database');
      });
    });
  }

  late NotifyHelper notifyHelper;
  int? year;
  int? month;
  int? day;
  int? hour;
  int? minutes;
  int? id;
  String? notificationTitle;
  String? notificationDescription;

  void scheduleNotification() {
    notifyHelper = NotifyHelper();
    print(
        "Year $year : Month $month : day $day : hour :$hour minutes $minutes");
    try {
      notifyHelper.scheduledNotification(
        year: year!,
        month: month!,
        day: day!,
        hour: hour!,
        minutes: minutes!,
        title: notificationTitle!,
        id: id!,
        des: notificationDescription!,
      );
      debugPrint("success scheduledNotification");
      emit(AppNotificationState());
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  List tasks = [];
  List<TodoModel> task = [];

  void getDataFromDatabase(database) {
    emit(LoadingGetDataFromDatabaseState());
    tasks = [];
    // select everything from your table
    // select * from tasks
    database!.rawQuery('SELECT * FROM tasks').then((value) {
      for (var i in value) {
        tasks.add(i);
        task.add(TodoModel.fromJson(i));
      }
      emit(SuccessGettingDataFromDatabaseState());
      debugPrint('$value');
    }).catchError((error) {
      debugPrint('error when getting data from database');
    });
  }

  // how to update data into database
  void updateDataIntoDatabase({
    required String title,
    required String date,
    required String time,
    required String description,
    required int id,
  }) {
    // what we need to update
    // to reach for a task from a table is by ID
    database!
        .update(
            'tasks',
            {
              "title": title,
              "date": date,
              "time": time,
              "description": description
            },
            where: 'id =?',
            whereArgs: [id])
        .then((value) {
      debugPrint('$value updating data has successfully happened');
      // DateTime dateTime1 = DateFormat.yMMMd().parse(date);
      // TimeOfDay times = TimeOfDay.fromDateTime(time);
      // year = dateTime1.year;
      // month = dateTime1.month;
      // day = dateTime1.day;
      // hour = int.parse(time.split(":")[0]);
      // minutes = int.parse(time.split(":")[1].split(" ")[0]);
      // var _startTime = TimeOfDay(hour:int.parse(time.split(":")[0]),minute: int.parse(time.split(":")[1]));
      // print("Year $year : month $month : day $day : hour $hour : minutes $minutes");
      emit(SuccessUpdatingDataFromDatabaseState());
      getDataFromDatabase(database);
      // scheduleNotification();
    }).catchError((error) {
      debugPrint('error when updating data');
    });
  }

// how to delete data from database

  void deleteDataFromDatabase({required int id}) {
    database!.rawDelete('DELETE FROM tasks WHERE id = ? ', [id]).then((value) {
      debugPrint('$value deleted successfully');
      emit(DeletingDataFromDatabaseState());
      getDataFromDatabase(database);
    }).catchError((error) {
      debugPrint('an error when deleting data');
    });
  }

  void changeLanguageToArabic(BuildContext context) {
    if (EasyLocalization.of(context)!.locale == const Locale('en', 'US')) {
      context.locale = const Locale('ar', 'EG');
    }
    emit(ChangeLanguageToArabicState());
  }

  void changeLanguageToEnglish(BuildContext context) {
    if (EasyLocalization.of(context)!.locale == const Locale('ar', 'EG')) {
      context.locale = const Locale('en', 'US');
    }
    emit(ChangeLanguageToEnglishState());
  }

  bool isDark = false;

  void changeThemeMode({bool? darkMode}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (darkMode != null) {
      isDark = darkMode;
    } else {
      isDark = !isDark;
      sharedPreferences.setBool("isDark", isDark);
    }
    emit(ChangeAppModeState());
  }
}
