import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:listinha/components/misc.dart';
import 'package:listinha/models/item.dart';
import 'package:listinha/stores/lists_store.dart';
import 'package:mobx/mobx.dart';

class List_TaskView extends StatefulWidget {
  final ListsStore taskStore;
  final String id;

  List_TaskView({super.key, required this.taskStore, required this.id});

  @override
  State<List_TaskView> createState() => _List_TaskViewState();
}

class _List_TaskViewState extends State<List_TaskView> {
  List<TextEditingController> taskController =
      List.generate(100, (index) => TextEditingController());
  ObservableList<Item> list = ObservableList();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await widget.taskStore.getItems(widget.id);
  }

  /*
  @override
  void dispose() {
    super.dispose();
    taskController.clear();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Observer(builder: (context) {
              if (list.isEmpty) {
                list = widget.taskStore.taskList;
              }
              return ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async =>
                        await widget.taskStore.deleteItem(list[i]),
                    background: Container(
                        color: Colors.red,
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text('EXCLUIR',
                                  style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
                        )),
                    child: ListTile(
                      leading: SizedBox(
                        width: 30,
                        child: CheckboxListTile(
                            value: list[i].isConcluded,
                            activeColor: Colors.green.shade500,
                            onChanged: (newValue) async {
                              Item item = Item(
                                fId: list[i].fId,
                                subFid: list[i].subFid,
                                desc: list[i].desc,
                                isConcluded: newValue!,
                              );
                              await widget.taskStore.updateItemStatus(item);
                            }),
                      ),
                      title: InkWell(
                          onTap: () => _showAddEditTask(
                                  item: Item(
                                fId: list[i].fId,
                                subFid: list[i].subFid,
                                desc: list[i].desc,
                                isConcluded: list[i].isConcluded,
                              )),
                          child: Misc()
                              .getTaskTitle(list[i].desc, list[i].isConcluded)),
                    ),
                  );
                },
              );
            }),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  textStyle: MaterialStatePropertyAll(TextStyle(
                      color: Colors.grey,
                      fontFamily: 'ITC',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
                  elevation: MaterialStatePropertyAll(0),
                  backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.background)),
              onPressed: () => _showAddEditTask(),
              child: Text('Adicionar Item'))
        ],
      ),
    );
  }

  _showAddEditTask({Item? item}) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final TextEditingController taskDescController = TextEditingController();
    TextStyle editStyle = TextStyle(fontSize: 18, fontFamily: 'ITC');
    FocusNode f1 = FocusNode();
    f1.requestFocus();

    if (item != null) taskDescController.text = item.desc;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              item == null ? 'Novo item' : 'Editar item',
              textAlign: TextAlign.center,
              style: editStyle,
            ),
            content: SizedBox(
              height: height / 4,
              width: width,
              child: Form(
                child: TextFormField(
                  focusNode: f1,
                  keyboardType: TextInputType.multiline,
                  controller: taskDescController,
                  maxLines: 4,
                  style: editStyle,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    hintText: 'Descrição',
                    hintStyle: Misc().getStyle(size: 18),
                    icon: const Icon(CupertinoIcons.bubble_left_bubble_right,
                        color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text('Cancelar',
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'ITC', fontSize: 18)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (taskDescController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Digite o texto'),
                      duration: Duration(seconds: 1),
                    ));
                    return;
                  } else {
                    if (item == null) {
                      Item item = Item(
                        fId: UniqueKey().toString(),
                        subFid: widget.id,
                        desc: taskDescController.text,
                        isConcluded: false,
                      );
                      widget.taskStore
                          .saveTask(item)
                          .whenComplete(() => Navigator.pop(context));
                    } else {
                      Item editedItem = Item(
                        fId: item.fId,
                        subFid: item.subFid,
                        desc: taskDescController.text,
                        isConcluded: item.isConcluded,
                      );
                      await widget.taskStore
                          .updateItemDesc(editedItem)
                          .whenComplete(() => Navigator.pop(context));
                    }
                  }
                },
                child: const Text('Salvar',
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'ITC', fontSize: 18)),
              ),
            ],
          );
        });
  }
}
