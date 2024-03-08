import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:listinha/components/list_taskview.dart';
import 'package:listinha/components/misc.dart';
import 'package:listinha/models/item.dart';
import 'package:listinha/models/list.dart';
import 'package:listinha/stores/lists_store.dart';
import 'package:listinha/utils/dao.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

class ListDetailPage extends StatefulWidget {
  const ListDetailPage({super.key});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  int itemsChecked = 0;
  int itemCount = 0;
  DAO dao = new DAO();
  late ObservableList<Item> list;
  late ListsStore taskStore;
  late ListM args;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    list = ObservableList<Item>();
    args = ModalRoute.of(context)?.settings.arguments as ListM;
    taskStore = Provider.of<ListsStore>(context);
    await taskStore.getItems(args.fId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              color: Theme.of(context).colorScheme.background,
              margin: EdgeInsets.all(0),
              elevation: 3,
              child: Column(
                children: [
                  Misc().getCachedImage(args.image),
                  Misc().getTitle(args.name),
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Itens',
                            style: Misc().getStyle(size: 18),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: Colors.green.shade700,
                              ),
                              Observer(
                                builder: (context) => Text(
                                    "${taskStore.tasksCheckedLength}/${taskStore.taskListLength}",
                                    style: Misc().getStyle(size: 18)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            List_TaskView(taskStore: taskStore, id: args.fId),
          ],
        ),
      ),
    );
  }
}
