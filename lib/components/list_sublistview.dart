import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:listinha/components/misc.dart';
import 'package:listinha/models/list.dart';
import 'package:listinha/stores/lists_store.dart';
import 'package:listinha/utils/app_routes.dart';
import 'package:listinha/utils/dao.dart';
import 'package:listinha/utils/dummy_data.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class List_SubListView extends StatefulWidget {
  final double height;
  final String id;

  List_SubListView({super.key, required this.id, this.height = 20});

  @override
  State<List_SubListView> createState() => _List_SubListViewState();
}

class _List_SubListViewState extends State<List_SubListView> {
  late ListsStore menuStore;
  DAO dao = new DAO();
  FirebaseDAO fDao = FirebaseDAO();
  String image = "food.jpg";
  var controller = TextEditingController(text: "");
  String errText = "";
  TextStyle style = Misc().getStyle();
  late SharedPreferences prefs;
  late ObservableList<ListM> list;
  FocusNode f1 = FocusNode();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    menuStore = Provider.of<ListsStore>(context);
    prefs = await SharedPreferences.getInstance();
    await menuStore.getSubLists(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: widget.height),
          Expanded(
            child: Observer(builder: (context) {
              list = menuStore.subMenuList;
              if (list.isEmpty) {
                menuStore.getSubLists(widget.id);
              }
              return ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          ListM item = ListM(
                            fId: list[i].fId,
                            image: list[i].image,
                            name: list[i].name,
                          );
                          Navigator.pushNamed(context, AppRoutes.LIST_DETAIL,
                              arguments: item);
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Misc().getCachedImage(list[i].image)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Text(
                          list[i].name,
                          textAlign: TextAlign.start,
                          style: style,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  );
                },
              );
            }),
          ),
          InkWell(
            onTap: () {
              f1.requestFocus();
              setState(() => errText = "");
              showModalBottomSheet(
                scrollControlDisabledMaxHeightRatio: 0.8,
                context: context,
                backgroundColor: ThemeData().colorScheme.background,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, s) => Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, 20, 20, MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          width: double.infinity,
                          child: Wrap(
                            children: [
                              Text(errText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'ITC',
                                      fontSize: 16,
                                      color: Colors.red.shade700)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Qual o nome da lista?',
                                    style: style,
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green.shade400,
                                        size: 32,
                                      ),
                                      onPressed: () async {
                                        if (controller.text.isEmpty)
                                          controller.text = "Minha Lista";

                                        ListM item = new ListM(
                                          fId: UniqueKey().toString(),
                                          image: await fDao.getImageURL(image),
                                          name: controller.text,
                                          subFId: widget.id,
                                        );
                                        if (await menuStore.saveSubItem(item) ==
                                            true) {
                                          s(() => controller.text = "");
                                          Navigator.popAndPushNamed(
                                              context, AppRoutes.LIST_DETAIL,
                                              arguments: item);
                                        } else {
                                          s(() => errText =
                                              "Ocorreu um erro, tente novamente");
                                        }
                                      }),
                                ],
                              ),
                              TextField(controller: controller, focusNode: f1),
                              SizedBox(height: 80),
                              Text('Qual a imagem de fundo?', style: style),
                              CarouselSlider.builder(
                                itemCount: imageList.length,
                                itemBuilder: (context, index, realIndex) =>
                                    Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                        "lib/images/${imageList[index]}"),
                                  ),
                                ),
                                options: CarouselOptions(
                                    onPageChanged: (i, reason) {
                                      image = imageList[i];
                                    },
                                    height:
                                        MediaQuery.of(context).size.height / 6),
                              ),
                            ],
                          )),
                    ),
                  );
                },
              );
            },
            child: ClipRRect(
                child: Icon(
              Icons.add,
              size: 32,
            )),
          ),
        ],
      ),
    );
  }
}
