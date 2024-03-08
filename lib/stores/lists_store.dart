import 'package:listinha/models/item.dart';
import 'package:listinha/models/list.dart';
import 'package:listinha/utils/dao.dart';
import 'package:mobx/mobx.dart';

part 'lists_store.g.dart';

class ListsStore = _ListsStore with _$ListsStore;

abstract class _ListsStore with Store {
  @observable
  ObservableList<ListM> menuList = ObservableList();

  @observable
  ObservableList<ListM> subMenuList = ObservableList();

  @observable
  ObservableList<Item> taskList = ObservableList();

  @computed
  int get taskListLength => taskList.length;

  @computed
  int get tasksCheckedLength =>
      taskList.where((item) => item.isConcluded).length;

  @action
  getLists() async {
    DAO dao = new DAO();
    var list = await dao.getLists();
    menuList.clear();
    list.forEach((element) {
      menuList.add(ListM(
        fId: element['fid'],
        image: element['imageurl'],
        name: element['name'],
      ));
    });
  }

  @action
  getSubLists(String id) async {
    DAO dao = new DAO();
    var list = await dao.getSubLists(id);
    subMenuList.clear();
    list.forEach((element) {
      subMenuList.add(ListM(
          fId: element['fid'],
          image: element['imageurl'],
          name: element['name'],
          subFId: element['subid']));
    });
  }

  @action
  getItems(String id) async {
    DAO dao = new DAO();
    var list = await dao.getItems(id);
    taskList.clear();
    list.forEach((element) {
      taskList.add(Item(
        fId: element['fid'],
        subFid: element['subid'],
        desc: element['desc'],
        isConcluded: element['isConcluded'] == 0 ? false : true,
      ));
    });
  }

  @action
  Future<bool> saveItem(ListM item) async {
    try {
      DAO dao = new DAO();
      if (await dao.saveMenuItem(item) == true) {
        await getLists();
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  @action
  Future<bool> saveSubItem(ListM item) async {
    try {
      DAO dao = new DAO();
      if (await dao.saveSubItem(item) == true) {
        await getSubLists(item.subFId);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  @action
  Future<bool> saveTask(Item item) async {
    try {
      DAO dao = new DAO();
      if (await dao.saveItem(item) == true) {
        await getItems(item.subFid);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  @action
  Future<bool> updateItemStatus(Item item) async {
    try {
      DAO dao = new DAO();
      if (await dao.updateItemStatus(item) == true) {
        await getItems(item.subFid);
      }
      return true;
    } on Exception {
      return false;
    }
  }

  @action
  Future<bool> updateItemDesc(Item item) async {
    try {
      DAO dao = new DAO();
      if (await dao.updateItemDesc(item) == true) {
        await getItems(item.subFid);
      }
      return true;
    } on Exception {
      return false;
    }
  }

  @action
  Future<void> deleteItem(Item item) async {
    DAO dao = new DAO();
    await dao.deleteItem(item.fId);
    await getItems(item.subFid);
  }
}
