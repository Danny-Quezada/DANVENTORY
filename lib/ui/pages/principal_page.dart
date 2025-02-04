import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/providers/product_provider.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/pages/order_page.dart';
import 'package:danventory/ui/pages/product_page.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/ai_button.dart';
import 'package:danventory/ui/widgets/empty_widget.dart';
import 'package:danventory/ui/widgets/list_tile_widget_product.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final principalProductProvider =
        Provider.of<ProductProvider>(context, listen: false);

    return SafeScaffold(
      floatingActionButton: FloatingActionButton(
          heroTag: "add",
          backgroundColor: ThemeSetting.greenColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ProductPage();
              },
            ));
            principalProductProvider.images = [];
            principalProductProvider.category = null;
            principalProductProvider.productImageModels = [];
          }),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar los productos"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonListView();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                List productModels = productProvider.productModels.where((x) {
                  final searchQuery = productProvider.search.toLowerCase();
                  final isStatusMatching = x.status == productProvider.isActive;
                  final isNameMatching = searchQuery.isEmpty ||
                      x.productName.toLowerCase().contains(searchQuery);
                  return isStatusMatching && isNameMatching;
                }).toList();

                if (productProvider.productModels.isNotEmpty) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SearchWidget(),
                        const SizedBox(
                          height: 10,
                        ),
                        AIButtonWidget(
                            message: message(productProvider.productModels)),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              ProductModel productModel = productModels[index];
                              return Slidable(
                                startActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) async {
                                          await Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              principalProductProvider
                                                  .productModel = productModel;
                                              return ProductPage();
                                            },
                                          ));
                                          principalProductProvider.images = [];
                                          principalProductProvider.category =
                                              null;
                                          principalProductProvider
                                              .productImageModels = [];
                                          principalProductProvider
                                              .productModel = null;
                                        },
                                        icon: Icons.edit,
                                        backgroundColor:
                                            ThemeSetting.principalColor,
                                      ),
                                      SlidableAction(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            productModel.status! == true
                                                ? ThemeSetting.redColor
                                                : ThemeSetting.greenColor,
                                        icon: productModel.status! == true
                                            ? Icons.delete
                                            : Icons.replay,
                                        onPressed: (context) async {
                                          if (productModel.status != null) {
                                            productModel.status =
                                                !productModel.status!;
                                          }
                                          await productProvider
                                              .delete(productModel);
                                        },
                                      )
                                    ]),
                                child: ListTileWidgetProduct(
                                    onTap: () async {
                                      await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return OrderPage(
                                          productModel: productModel,
                                        );
                                      }));
                                    },
                                    productModel: productModel),
                              );
                            },
                            itemCount: productModels.length,
                          ),
                        ),
                      ]);
                } else {
                  return const EmptyWidget(title: "Añade productos");
                }
              },
            );
          }
          return Container();
        },
        future: principalProductProvider.read(userProvider.userModel!.userId),
      ),
    );
  }

  String message(List<ProductModel> productModels) {
    return """
# Resumen de Productos del Usuario

A continuación, se muestra un resumen de los productos que has creado. Este contenido está diseñado para que la IA de DANVENTORY lo utilice y te brinde respuestas, consejos o sugerencias personalizadas.

## Lista de Productos

${productModels.map((product) {
      return '''
- **${product.productName}**
  - **Descripción:** ${product.description}
  - **Cantidad:** ${product.quantity}
  - **Estado:** ${product.status == true ? "Activo" : "Inactivo"}
  - **Categoría:** ${product.categoryName ?? "Sin categoría"}
  - **ID de Usuario:** ${product.userId}
''';
    }).join('\n')}

## Información Adicional

- **Total de Productos Activos:** ${productModels.where((x) => x.status == true).length}
- **Total de Productos Inactivos:** ${productModels.where((x) => x.status == false).length}
- **Productos sin Descripción:** ${productModels.where((x) => x.description.isEmpty).length}
- **Productos con Bajo Stock (menos de 10 unidades):** ${productModels.where((x) => x.quantity < 10).length}


## Preguntas para la IA


1. ¿Cómo puedo mejorar la organización de mis productos?
2. ¿Qué productos debería reactivar o desactivar según mis necesidades?
3. ¿Cómo puedo manejar productos que no encajan en ninguna categoría existente?
4. ¿Qué productos tienen bajo stock y necesitan reabastecimiento?
5. ¿Cómo puedo optimizar las descripciones de mis productos para que sean más claras?
6. ¿Qué categorías tienen más productos y cuáles tienen menos?

""";
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productValue, child) {
        return Row(
          children: [
            Expanded(
                child: TextField(
              decoration:
                  const InputDecoration(hintText: "Escriba el producto"),
              onChanged: (valueWord) {
                productValue.searchFind(valueWord);
              },
            )),
            const SizedBox(
              width: 10,
            ),
            DropdownButton(
              value: productValue.isActive,
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
                productValue.changeDrop();
              },
            )
          ],
        );
      },
    );
  }
}
