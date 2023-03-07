import 'package:hive/hive.dart';

part 'taskTile.g.dart';

@HiveType(typeId: 0)
class taskTile {

  @HiveField(0)
  String? title = '';
  @HiveField(1)
  String? description = '';
  @HiveField(2)
  String? status = '';
  @HiveField(3)
  String? datetime = '';
  @HiveField(4)
  String? id;

  @HiveField(5)
  bool? personal;

  @HiveField(6)
  String? imagePath;

  //ValueNotifier isVisible = ValueNotifier(true);
  @HiveField(7)
  bool isVisible = true;

  @HiveField(8)
  List<taskTile> blockedBy;
  @HiveField(9)
  List<taskTile> parentTasks;
  @HiveField(10)
  List<taskTile> minorTasks;
  @HiveField(11)
  List<taskTile> urgentTasks;
  @HiveField(12)
  List<taskTile> miscTasks;


  taskTile({
    required this.title,
    required this.description,
    required this.status,
    required this.datetime,
    required this.id,
    required this.personal,

    //need ?? []
    this.imagePath,

    List<taskTile>? blockedBy,
    List<taskTile>? parentTasks,
    List<taskTile>? minorTasks,
    List<taskTile>? urgentTasks,
    List<taskTile>? miscTasks,

  }): blockedBy = blockedBy ?? [],
        parentTasks = parentTasks ?? [],
        minorTasks = minorTasks ?? [],
        urgentTasks = parentTasks ?? [],
        miscTasks = miscTasks ?? [];


  void updateTask(String title, String description,
      String status, String datetime,
      String id)
  {
    this.title = title;
    this.description = description;
    this.status = status;
    this.datetime = datetime;
    this.id = id;
  }

}