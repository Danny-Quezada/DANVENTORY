import 'package:danventory/domain/entities/category_model.dart';
import 'package:danventory/providers/category_provider.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/empty_widget.dart';
import 'package:danventory/ui/widgets/list_tile_widget_category.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final principalCategoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    return SafeScaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: ThemeSetting.greenColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Crear categoría"),
                  content: CategoryForm(),
                );
              },
            );
          }),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar las categorias"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonListView();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                List categoryModels =
                    categoryProvider.categoryModels.where((x) {
                  final searchQuery = categoryProvider.search.toLowerCase();
                  final isStatusMatching =
                      x.status == categoryProvider.isActive;
                  final isNameMatching = searchQuery.isEmpty ||
                      x.name.toLowerCase().contains(searchQuery);
                  return isStatusMatching && isNameMatching;
                }).toList();

                if (categoryProvider.categoryModels.isNotEmpty) {
                  return Column(children: [
                    const SearchWidget(),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          CategoryModel categoryModel = categoryModels[index];
                          return Slidable(
                            startActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    backgroundColor:
                                        ThemeSetting.principalColor,
                                    icon: Icons.edit,
                                    onPressed: (context) async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Actualizar categoría"),
                                            content: CategoryForm(
                                              categoryModel: categoryModel,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SlidableAction(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        categoryModel.status! == true
                                            ? ThemeSetting.redColor
                                            : ThemeSetting.greenColor,
                                    icon: categoryModel.status! == true
                                        ? Icons.delete
                                        : Icons.replay,
                                    onPressed: (context) async {
                                      if (categoryModel.status != null) {
                                        categoryModel.status =
                                            !categoryModel.status!;
                                      }
                                      await categoryProvider
                                          .delete(categoryModel);
                                    },
                                  )
                                ]),
                            child: ListTileWidgetCategory(
                                categoryModel: categoryModel),
                          );
                        },
                        itemCount: categoryModels.length,
                      ),
                    ),
                  ]);
                } else {
                  return const EmptyWidget(title: "Añade categorías");
                }
              },
            );
          }
          return Container();
        },
        future: principalCategoryProvider.read(userProvider.userModel!.userId),
      ),
    );
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryValue, child) {
        return Row(
          children: [
            Expanded(
                child: TextField(
              decoration: InputDecoration(hintText: "Escriba la categoría"),
              onChanged: (valueWord) {
                categoryValue.searchFind(valueWord);
              },
            )),
            const SizedBox(
              width: 10,
            ),
            DropdownButton(
              value: categoryValue.isActive,
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text("Activo"),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text("Inactivo"),
                )
              ],
              onChanged: (value) {
                categoryValue.changeDrop();
              },
            )
          ],
        );
      },
    );
  }
}

class CategoryForm extends StatefulWidget {
  CategoryModel? categoryModel;

  CategoryForm({super.key, this.categoryModel});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final principalCategoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    _titleController.text =
        widget.categoryModel != null ? widget.categoryModel!.name : "";
    _descriptionController.text = (widget.categoryModel != null
        ? widget.categoryModel?.description
        : "")!;
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: widget.categoryModel != null
                    ? widget.categoryModel!.name
                    : "Nombre de la categoría",
                prefixIcon: const Icon(Icons.title),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa el nombre';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: widget.categoryModel != null
                    ? widget.categoryModel!.description
                    : "descripción de la categoría",
                prefixIcon: const Icon(Icons.title),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa la descripción';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            widget.categoryModel != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Estado:"),
                          const SizedBox(
                            width: 3,
                          ),
                          Switch(
                            activeColor: Colors.green.shade900,
                            inactiveTrackColor: ThemeSetting.redColor,
                            inactiveThumbColor: Colors.redAccent.shade700,
                            trackColor: WidgetStateProperty.all(
                                widget.categoryModel!.status == true
                                    ? ThemeSetting.greenColor
                                    : Colors.red),
                            trackOutlineColor: WidgetStatePropertyAll(
                                widget.categoryModel!.status == true
                                    ? ThemeSetting.greenColor
                                    : Colors.red),
                            value: widget.categoryModel!.status!,
                            onChanged: (value) {
                              setState(() {
                                widget.categoryModel!.status = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  )
                : const SizedBox(
                    height: 15,
                  ),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (widget.categoryModel == null) {
                      principalCategoryProvider.create(CategoryModel(
                          name: _titleController.text,
                          description: _descriptionController.text,
                          userId: userProvider.userModel?.userId));
                    } else {
                      widget.categoryModel?.description =
                          _descriptionController.text.isEmpty
                              ? widget.categoryModel?.description
                              : _descriptionController.text;
                      widget.categoryModel?.name =
                          (_titleController.text.isEmpty
                              ? widget.categoryModel?.name
                              : _titleController.text)!;

                      principalCategoryProvider.update(widget.categoryModel!);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(
                    "${widget.categoryModel == null ? "Crear" : "Actualizar"} categoría"))
          ],
        ),
      ),
    );
  }
}
