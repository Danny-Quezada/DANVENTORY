import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/providers/order_provider.dart';
import 'package:danventory/providers/product_provider.dart';

import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/empty_widget.dart';
import 'package:danventory/ui/widgets/list_tile_widget_order.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatelessWidget {
  final int productId;
  final String productName;
  const OrderPage(
      {super.key, required this.productId, required this.productName});
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final principalOrderProvider =
        Provider.of<OrderProvider>(context, listen: false);

    return SafeScaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: ThemeSetting.greenColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  content: Builder(
                    builder: (context) {
                      var width = MediaQuery.of(context).size.width;

                      return SizedBox(
                        width: width - 20,
                        child: OrderForm(
                          productId: productId,
                        ),
                      );
                    },
                  ),
                  title: const Text("Crear orden"),
                  insetPadding: const EdgeInsets.all(20),
                );
              },
            );
          }),
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: "Órdenes de: ",
            children: [
              TextSpan(
                text: productName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeSetting.principalColor),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(child: StateSwitch()),
                const PopupMenuItem(child: CalendarPicker())
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar las órdenes"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonListView();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                List<OrderModel> orderModels =
                    orderProvider.orderModels.where((x) {
                  final isStatusMatching = x.status == orderProvider.isActive;

                  if (principalOrderProvider.dates.isEmpty) {
                    return isStatusMatching;
                  }

                  final orderDate = x.orderDate;
                  final isDateInRange =
                      orderDate.isAfter(principalOrderProvider.dates[0]!) &&
                          orderDate.isBefore(principalOrderProvider.dates[1]!);

                  return isStatusMatching && isDateInRange;
                }).toList();
                if (orderProvider.orderModels.isNotEmpty) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        principalOrderProvider.dates.isEmpty
                            ? const SizedBox
                                .shrink() // Si no hay fechas, no mostrar nada
                            : Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () {
                                    principalOrderProvider.addDates(null);
                                  },
                                  child: Text(
                                    'Rango de fechas: ${_formatDate(principalOrderProvider.dates[0]!)} - ${_formatDate(principalOrderProvider.dates[1]!)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeSetting.redColor),
                                  ),
                                ),
                              ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              OrderModel orderModel = orderModels[index];
                              return Slidable(
                                startActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            orderModel.status == true
                                                ? ThemeSetting.redColor
                                                : ThemeSetting.greenColor,
                                        icon: orderModel.status == true
                                            ? Icons.delete
                                            : Icons.replay,
                                        onPressed: (context) async {
                                          orderModel.status =
                                              !orderModel.status;
                                          await orderProvider
                                              .delete(orderModel);
                                          productProvider.updateQuantity(
                                              productId,
                                              orderModel.quantity,
                                              orderModel.status);
                                        },
                                      )
                                    ]),
                                child:
                                    ListTileWidgetOrder(orderModel: orderModel),
                              );
                            },
                            itemCount: orderModels.length,
                          ),
                        ),
                      ]);
                } else {
                  return const EmptyWidget(title: "Añade órdenes");
                }
              },
            );
          }
          return Container();
        },
        future: principalOrderProvider.read(productId),
      ),
    );
  }
}

class StateSwitch extends StatelessWidget {
  const StateSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProviderValue, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Estado:"),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  value: orderProviderValue.isActive,
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
                    orderProviderValue.changeDrop();
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class CalendarPicker extends StatelessWidget {
  const CalendarPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final principalOrderProvider =
        Provider.of<OrderProvider>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        var results = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
              calendarType: CalendarDatePicker2Type.range),
          dialogSize: const Size(325, 400),
          borderRadius: BorderRadius.circular(15),
        );
        if (results != null) {
          principalOrderProvider.addDates(results);
        }
      },
      child: const Row(
        children: [Text("Rango de fecha:"), Icon(Icons.calendar_month)],
      ),
    );
  }
}

class OrderForm extends StatelessWidget {
  final _quantityController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _datetimeController = TextEditingController();
  final int productId;
  final _formKey = GlobalKey<FormState>();
  OrderForm({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final principalOrderProvider =
        Provider.of<OrderProvider>(context, listen: false);
    final principalProductProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final format = DateFormat("yyyy-MM-dd");
    return SingleChildScrollView(
        child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: "Cantidad",
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[\.\-]')),
                  ],
                  keyboardType: const TextInputType.numberWithOptions(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa la cantidad';
                    } else if (int.parse(value) <= 0) {
                      return 'La cantidad debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _purchasePriceController,
                  decoration: const InputDecoration(
                    labelText: "Precio de compra",
                    prefixIcon: Icon(Icons.money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa la cantidad';
                    } else if (double.parse(value) <= 0) {
                      return 'La cantidad debe ser mayor a 0';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _salePriceController,
                  decoration: const InputDecoration(
                    labelText: "Precio de venta",
                    prefixIcon: Icon(Icons.money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa la cantidad';
                    } else if (double.parse(value) <= 0) {
                      return 'La cantidad debe ser mayor a 0';
                    }

                    if (_purchasePriceController.text.isNotEmpty &&
                        double.parse(value) <=
                            double.parse(_purchasePriceController.text)) {
                      return 'El precio de venta debe ser mayor al precio de compra';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                DateTimeField(
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecciona una fecha';
                    }
                    return null;
                  },
                  controller: _datetimeController,
                  format: format,
                  decoration: const InputDecoration(
                    labelText: "Fecha de la orden",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onShowPicker: (context, currentValue) async {
                    return await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    ).then((DateTime? date) async {
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await principalOrderProvider.create(OrderModel(
                          orderid: 0,
                          remainingQuantity:
                              int.parse(_quantityController.text),
                          orderDate: DateTime.parse(_datetimeController.text),
                          quantity: int.parse(_quantityController.text),
                          salePrice: double.parse(_salePriceController.text),
                          purchasePrice:
                              double.parse(_purchasePriceController.text),
                          productid: productId,
                          status: true,
                        ));
                        principalProductProvider.updateQuantity(productId,
                            int.parse(_quantityController.text), true);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Crear orden"))
              ],
            )));
  }
}
