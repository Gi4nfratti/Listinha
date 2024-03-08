// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ListsStore on _ListsStore, Store {
  Computed<int>? _$taskListLengthComputed;

  @override
  int get taskListLength =>
      (_$taskListLengthComputed ??= Computed<int>(() => super.taskListLength,
              name: '_ListsStore.taskListLength'))
          .value;
  Computed<int>? _$tasksCheckedLengthComputed;

  @override
  int get tasksCheckedLength => (_$tasksCheckedLengthComputed ??= Computed<int>(
          () => super.tasksCheckedLength,
          name: '_ListsStore.tasksCheckedLength'))
      .value;

  late final _$menuListAtom =
      Atom(name: '_ListsStore.menuList', context: context);

  @override
  ObservableList<ListM> get menuList {
    _$menuListAtom.reportRead();
    return super.menuList;
  }

  @override
  set menuList(ObservableList<ListM> value) {
    _$menuListAtom.reportWrite(value, super.menuList, () {
      super.menuList = value;
    });
  }

  late final _$subMenuListAtom =
      Atom(name: '_ListsStore.subMenuList', context: context);

  @override
  ObservableList<ListM> get subMenuList {
    _$subMenuListAtom.reportRead();
    return super.subMenuList;
  }

  @override
  set subMenuList(ObservableList<ListM> value) {
    _$subMenuListAtom.reportWrite(value, super.subMenuList, () {
      super.subMenuList = value;
    });
  }

  late final _$taskListAtom =
      Atom(name: '_ListsStore.taskList', context: context);

  @override
  ObservableList<Item> get taskList {
    _$taskListAtom.reportRead();
    return super.taskList;
  }

  @override
  set taskList(ObservableList<Item> value) {
    _$taskListAtom.reportWrite(value, super.taskList, () {
      super.taskList = value;
    });
  }

  late final _$getListsAsyncAction =
      AsyncAction('_ListsStore.getLists', context: context);

  @override
  Future getLists() {
    return _$getListsAsyncAction.run(() => super.getLists());
  }

  late final _$getSubListsAsyncAction =
      AsyncAction('_ListsStore.getSubLists', context: context);

  @override
  Future getSubLists(String id) {
    return _$getSubListsAsyncAction.run(() => super.getSubLists(id));
  }

  late final _$getItemsAsyncAction =
      AsyncAction('_ListsStore.getItems', context: context);

  @override
  Future getItems(String id) {
    return _$getItemsAsyncAction.run(() => super.getItems(id));
  }

  late final _$saveItemAsyncAction =
      AsyncAction('_ListsStore.saveItem', context: context);

  @override
  Future<bool> saveItem(ListM item) {
    return _$saveItemAsyncAction.run(() => super.saveItem(item));
  }

  late final _$saveSubItemAsyncAction =
      AsyncAction('_ListsStore.saveSubItem', context: context);

  @override
  Future<bool> saveSubItem(ListM item) {
    return _$saveSubItemAsyncAction.run(() => super.saveSubItem(item));
  }

  late final _$saveTaskAsyncAction =
      AsyncAction('_ListsStore.saveTask', context: context);

  @override
  Future<bool> saveTask(Item item) {
    return _$saveTaskAsyncAction.run(() => super.saveTask(item));
  }

  late final _$updateItemStatusAsyncAction =
      AsyncAction('_ListsStore.updateItemStatus', context: context);

  @override
  Future<bool> updateItemStatus(Item item) {
    return _$updateItemStatusAsyncAction
        .run(() => super.updateItemStatus(item));
  }

  late final _$updateItemDescAsyncAction =
      AsyncAction('_ListsStore.updateItemDesc', context: context);

  @override
  Future<bool> updateItemDesc(Item item) {
    return _$updateItemDescAsyncAction.run(() => super.updateItemDesc(item));
  }

  late final _$deleteItemAsyncAction =
      AsyncAction('_ListsStore.deleteItem', context: context);

  @override
  Future<void> deleteItem(Item item) {
    return _$deleteItemAsyncAction.run(() => super.deleteItem(item));
  }

  @override
  String toString() {
    return '''
menuList: ${menuList},
subMenuList: ${subMenuList},
taskList: ${taskList},
taskListLength: ${taskListLength},
tasksCheckedLength: ${tasksCheckedLength}
    ''';
  }
}
