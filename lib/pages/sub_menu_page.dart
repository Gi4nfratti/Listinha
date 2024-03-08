import 'package:flutter/material.dart';
import 'package:listinha/components/list_sublistview.dart';
import 'package:listinha/components/misc.dart';
import 'package:listinha/models/list.dart';
import 'package:listinha/stores/lists_store.dart';
import 'package:provider/provider.dart';

class SubMenuPage extends StatefulWidget {
  const SubMenuPage({super.key});

  @override
  State<SubMenuPage> createState() => _SubMenuPageState();
}

class _SubMenuPageState extends State<SubMenuPage> {
  late ListM args;
  late ListsStore menuStore;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    args = ModalRoute.of(context)?.settings.arguments as ListM;
    menuStore = Provider.of<ListsStore>(context);
    await menuStore.getSubLists(args.fId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
          child: Column(
            children: [
              Container(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Misc().getCachedImage(args.image)),
              Misc().getTitle(args.name),
              List_SubListView(height: 70, id: args.fId)
            ],
          ),
        ),
      ),
    );
  }
}
