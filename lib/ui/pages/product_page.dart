import 'dart:io';
import 'package:danventory/domain/entities/category_model.dart';
import 'package:danventory/domain/entities/product_image.dart';
import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/providers/category_provider.dart';
import 'package:danventory/providers/product_provider.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  final _productNameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final principalProductProvider =
        Provider.of<ProductProvider>(context, listen: false);
    _productNameController.text = principalProductProvider.productModel != null
        ? principalProductProvider.productModel!.productName
        : "";
    _descriptionController.text = (principalProductProvider.productModel != null
        ? principalProductProvider.productModel?.description
        : "")!;
    principalProductProvider.productModel != null
        ? principalProductProvider.category = CategoryModel(
            name: principalProductProvider.productModel!.categoryName!,
            categoryId: principalProductProvider.productModel?.categoryId)
        : null;
    return SafeScaffold(
      appBar: AppBar(
        title: Text(
            "${principalProductProvider.productModel == null ? "Crear" : "Actualizar"} producto"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePickerSelector(
                productModel: principalProductProvider.productModel,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: principalProductProvider.productModel != null
                      ? principalProductProvider.productModel!.productName
                      : "Nombre del producto",
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
                height: 20,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: principalProductProvider.productModel != null
                      ? principalProductProvider.productModel!.description
                      : "descripción del producto",
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
              principalProductProvider.productModel != null
                  ? const SwitchStateWidget()
                  : const SizedBox(
                      height: 15,
                    ),
              const CategoryPicker(),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (principalProductProvider.productModel == null) {
                        await principalProductProvider.create(
                            ProductModel(
                                categoryId: principalProductProvider
                                    .category!.categoryId!,
                                productId: 0,
                                quantity: 0,
                                status: true,
                                image: "",
                                productName: _productNameController.text,
                                description: _descriptionController.text,
                                userId: userProvider.userModel!.userId),
                            principalProductProvider.images
                                .map((e) => File(e.path))
                                .toList());
                      } else {
                        principalProductProvider.productModel?.description =
                            (_descriptionController.text.isEmpty
                                ? principalProductProvider
                                    .productModel?.description
                                : _descriptionController.text)!;
                        principalProductProvider.productModel?.productName =
                            (_productNameController.text.isEmpty
                                ? principalProductProvider
                                    .productModel?.productName
                                : _productNameController.text)!;
                        principalProductProvider.productModel?.categoryId =
                            principalProductProvider.category!.categoryId!;
                        principalProductProvider.productModel?.categoryName =
                            principalProductProvider.category!.name!;
                        await principalProductProvider
                            .update(principalProductProvider.productModel!);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                      "${principalProductProvider.productModel == null ? "Crear" : "Actualizar"} producto"))
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    return Selector<ProductProvider, CategoryModel?>(
      builder: (context, value, child) {
        return TextButton(
            style: const ButtonStyle().copyWith(),
            onPressed: () async {
              await categoryProvider.read(userProvider.userModel!.userId);
              await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    final activeCategories = categoryProvider.categoryModels
                        .where((x) => x.status == true)
                        .toList();
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: activeCategories.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(activeCategories[index].name),
                            onTap: () {
                              Provider.of<ProductProvider>(context,
                                          listen: false)
                                      .setCategory =
                                  categoryProvider.categoryModels[index];

                              Navigator.pop(context);
                            },
                          );
                        });
                  });
            },
            child: Text(value != null
                ? value.name
                : "Escoja una categoria (obligatorio)"));
      },
      selector: (p0, p1) => p1.category,
    );
  }
}

class ImagePickerSelector extends StatelessWidget {
  final ProductModel? productModel;
  ImagePickerSelector({
    super.key,
    required this.productModel,
  });

  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final principalProductProvider =
        Provider.of<ProductProvider>(context, listen: false);
    return productModel != null
        ? FutureBuilder<void>(
            future:
                principalProductProvider.readImages(productModel!.productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                  width: double.infinity,
                  minHeight: MediaQuery.of(context).size.height / 8,
                  maxHeight: MediaQuery.of(context).size.height / 3,
                ));
              }

              return FlutterCarousel(
                  items: List.generate(
                    principalProductProvider.productImageModels.length,
                    (index) {
                      return Image.network(principalProductProvider
                          .productImageModels[index].url!);
                    },
                  ),
                  options: FlutterCarouselOptions());
            },
          )
        : Selector<ProductProvider, int>(
            selector: (p0, p1) => p1.images.length,
            builder: (context, value, child) {
              if (value != 0) {
                return FlutterCarousel(
                    items: List.generate(
                      value,
                      (index) {
                        return Stack(alignment: Alignment.center, children: [
                          Image.file(
                            File(principalProductProvider.images[index].path),
                          ),
                          IconButton(
                              onPressed: () {
                                principalProductProvider.deleteImageFile(index);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: ThemeSetting.redColor.withOpacity(0.8),
                                size: 50,
                              ))
                        ]);
                      },
                    ),
                    options: FlutterCarouselOptions(autoPlay: true));
              }
              return GestureDetector(
                onTap: () async {
                  final List<XFile> images = await picker.pickMultiImage();
                  principalProductProvider.setImages = images;
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                ),
              );
            },
          );
  }
}

class SwitchStateWidget extends StatefulWidget {
  const SwitchStateWidget({super.key});

  @override
  State<SwitchStateWidget> createState() => _SwitchStateWidgetState();
}

class _SwitchStateWidgetState extends State<SwitchStateWidget> {
  @override
  Widget build(BuildContext context) {
    final principalProductProvider =
        Provider.of<ProductProvider>(context, listen: false);
    return Column(
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
                  principalProductProvider.productModel!.status == true
                      ? ThemeSetting.greenColor
                      : Colors.red),
              trackOutlineColor: WidgetStatePropertyAll(
                  principalProductProvider.productModel!.status == true
                      ? ThemeSetting.greenColor
                      : Colors.red),
              value: principalProductProvider.productModel!.status!,
              onChanged: (value) {
                setState(() {
                  principalProductProvider.productModel!.status = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}
