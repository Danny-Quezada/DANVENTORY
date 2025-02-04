import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/domain/entities/sale_model.dart';
import 'package:danventory/domain/enums/stock_management_enum.dart';
import 'package:danventory/providers/order_provider.dart';
import 'package:danventory/providers/product_provider.dart';
import 'package:danventory/providers/sale_provider.dart';
import 'package:danventory/ui/pages/sale_page.dart';

import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/empty_widget.dart';
import 'package:danventory/ui/widgets/list_tile_widget_order.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:danventory/ui/widgets/snack_bar.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:danventory/ui/widgets/ai_button.dart';

class OrderPage extends StatelessWidget {
  final ProductModel productModel;
  const OrderPage({super.key, required this.productModel});
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.menu),
            fabSize: ExpandableFabSize.regular,
            backgroundColor: ThemeSetting.principalColor,
            foregroundColor: Colors.white),
        closeButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.close),
            fabSize: ExpandableFabSize.regular,
            backgroundColor: ThemeSetting.principalColor,
            foregroundColor: Colors.white),
        initialOpen: true,
        distance: 80,
        type: ExpandableFabType.up,
        children: [
          FloatingActionButton(
              heroTag: "btn1",
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      content: Builder(
                        builder: (context) {
                          var width = MediaQuery.of(context).size.width;

                          return SizedBox(
                            width: width - 20,
                            child: OrderForm(
                              productId: productModel.productId,
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
          FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: ThemeSetting.redColor,
              child: const Icon(
                Icons.remove,
                color: Colors.white,
              ),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      content: Builder(
                        builder: (context) {
                          var width = MediaQuery.of(context).size.width;

                          return SizedBox(
                            width: width - 20,
                            child: SaleForm(),
                          );
                        },
                      ),
                      title: const Text("Crear ventas"),
                      insetPadding: const EdgeInsets.all(20),
                    );
                  },
                );
              }),
        ],
      ),
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: "Órdenes de: ",
            children: [
              TextSpan(
                text: productModel.productName,
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
                const PopupMenuItem(child: RemainingQuantitySwitch()),
                const PopupMenuItem(child: CalendarPicker()),
                const PopupMenuItem(child: ChangeStockManagement())
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

                  bool isDateInRange = true;
                  if (principalOrderProvider.dates.isNotEmpty) {
                    final orderDate = x.orderDate;
                    isDateInRange = orderDate
                            .isAfter(principalOrderProvider.dates[0]!) &&
                        orderDate.isBefore(principalOrderProvider.dates[1]!);
                  }

                  if (orderProvider.isRemainingQuantity) {
                    return isStatusMatching &&
                        isDateInRange &&
                        x.remainingQuantity > 0;
                  } else {
                    return isStatusMatching && isDateInRange;
                  }
                }).toList();
                if (orderProvider.orderModels.isNotEmpty) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            const Text("Método de gestión:"),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              orderProvider.stockManagementEnum ==
                                      StockManagementEnum.fifo
                                  ? "FIFO."
                                  : "LIFO.",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ThemeSetting.principalColor),
                            ),
                            Text(
                              stockManagementDescriptions[
                                  principalOrderProvider.stockManagementEnum]!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Mostrando: ",
                            children: [
                              TextSpan(
                                text: orderProvider.isRemainingQuantity
                                    ? "Con cantidades"
                                    : "Todos",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeSetting.principalColor),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Órdenes: ",
                            children: [
                              TextSpan(
                                text: "${orderModels.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeSetting.principalColor),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Cantidad de producto restante: ",
                            children: [
                              TextSpan(
                                text:
                                    "${orderModels.fold(0, (a, b) => a + b.remainingQuantity)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeSetting.principalColor),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        AIButtonWidget(message: message(orderProvider.orderModels)),
                        principalOrderProvider.dates.isEmpty
                            ? const SizedBox
                                .shrink() // Si no hay fechas, no mostrar nada
                            : Container(
                                child: TextButton.icon(
                                  label: Text(
                                    'Rango de fechas: ${_formatDate(principalOrderProvider.dates[0]!)} - ${_formatDate(principalOrderProvider.dates[1]!)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeSetting.redColor),
                                  ),
                                  onPressed: () {
                                    principalOrderProvider.addDates(null);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: ThemeSetting.redColor,
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
                                              orderModel.productid,
                                              orderModel.remainingQuantity,
                                              orderModel.status);
                                        },
                                      )
                                    ]),
                                child: ListTileWidgetOrder(
                                  orderModel: orderModel,
                                  onTap: () async {
                                    await Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return SalePage(orderModel: orderModel);
                                    }));
                                  },
                                ),
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
        future: principalOrderProvider.read(productModel.productId),
      ),
    );
  }

  String message(List<OrderModel> orderModels) {
    return """
# Resumen de Órdenes del Usuario

A continuación, se muestra un resumen de las órdenes que he creado. Este contenido está diseñado para que la IA de DANVENTORY lo utilice y te brinde respuestas, consejos o sugerencias personalizadas.

## Lista de Órdenes

${orderModels.map((order) {
      return '''
- **ID de Orden:** ${order.orderid}
  - **ID de Producto:** ${order.productid}
  - **Fecha de Orden:** ${order.orderDate.toLocal().toString()}
  - **Cantidad:** ${order.quantity}
  - **Cantidad Restante:** ${order.remainingQuantity}
  - **Precio de Venta:** \$${order.salePrice.toStringAsFixed(2)}
  - **Precio de Compra:** \$${order.purchasePrice.toStringAsFixed(2)}
  - **Estado:** ${order.status == true ? "Activo" : "Inactivo"}
''';
    }).join('\n')}

## Información Adicional

- **Total de Órdenes Activas:** ${orderModels.where((x) => x.status == true).length}
- **Total de Órdenes Inactivas:** ${orderModels.where((x) => x.status == false).length}
- **Órdenes con Cantidad Restante Baja (menos de 5 unidades):** ${orderModels.where((x) => x.remainingQuantity < 5).length}
- **Órdenes con Mayor Margen de Ganancia:** ${orderModels.where((x) => (x.salePrice - x.purchasePrice) > 50).length}

---

## Preguntas para la IA

Aquí tienes algunas preguntas que puedes hacerle a la IA sobre tus órdenes:

1. ¿Cómo puedo mejorar la gestión de mis órdenes?
2. ¿Qué órdenes tienen una cantidad restante baja y necesitan atención?
3. ¿Qué órdenes tienen el mayor margen de ganancia?
4. ¿Cómo puedo optimizar el precio de venta de mis productos?
5. ¿Qué órdenes debería reactivar o desactivar según mis necesidades?
6. ¿Cómo puedo manejar órdenes que tienen un margen de ganancia bajo?

""";
  }
}

class ChangeStockManagement extends StatelessWidget {
  const ChangeStockManagement({super.key});

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
                const Text("Método:"),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton<StockManagementEnum>(
                  value: orderProviderValue.stockManagementEnum,
                  items: const [
                    DropdownMenuItem(
                      value: StockManagementEnum.fifo,
                      child: Text("FIFO"),
                    ),
                    DropdownMenuItem(
                      value: StockManagementEnum.lifo,
                      child: Text("LIFO"),
                    )
                  ],
                  onChanged: (value) {
                    orderProviderValue
                        .changeStock(value ?? StockManagementEnum.fifo);
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

class RemainingQuantitySwitch extends StatelessWidget {
  const RemainingQuantitySwitch({super.key});

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
                const Text("Cantidades:"),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  value: orderProviderValue.isActive,
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text("Todos"),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text("Con cantidades"),
                    )
                  ],
                  onChanged: (value) {
                    orderProviderValue.changeRemaingQuantity();
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
  DateTime _dateTime = DateTime.now();
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
                        _dateTime = DateTimeField.combine(date, time);
                        return _dateTime;
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
                          orderDate: _dateTime,
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

class SaleForm extends StatelessWidget {
  SaleForm({super.key});
  final _quantityController = TextEditingController();

  final _datetimeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final principalOrderProvider =
        Provider.of<OrderProvider>(context, listen: false);
    final principalProductProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final principalSaleProvider =
        Provider.of<SaleProvider>(context, listen: false);
    List<OrderModel> orderModels =
        principalOrderProvider.orderModels.where((x) {
      final isStatusMatching = x.status == true;

      bool isDateInRange = true;
      if (principalOrderProvider.dates.isNotEmpty) {
        final orderDate = x.orderDate;
        isDateInRange = orderDate.isAfter(principalOrderProvider.dates[0]!) &&
            orderDate.isBefore(principalOrderProvider.dates[1]!);
      }

      return isStatusMatching && isDateInRange && x.remainingQuantity > 0;
    }).toList();
    final int remainingQuantity =
        orderModels.fold(0, (a, b) => a + b.remainingQuantity);
    final format = DateFormat("yyyy-MM-dd");
    return SingleChildScrollView(
        child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    const Text("Método de gestión:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      principalOrderProvider.stockManagementEnum ==
                              StockManagementEnum.fifo
                          ? "FIFO."
                          : "LIFO.",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeSetting.principalColor),
                    ),
                    Text(
                      stockManagementDescriptions[
                          principalOrderProvider.stockManagementEnum]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
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
                    } else if (int.parse(value) > remainingQuantity) {
                      return "La cantidad debe ser menor";
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
                    labelText: "Fecha de las ventas",
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
                        _datetimeController.text =
                            DateTimeField.combine(date, time).toString();
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
                        final int quantity =
                            int.parse(_quantityController.text);
                        if (quantity < orderModels[0].remainingQuantity) {
                          principalSaleProvider.create(SaleModel(
                            saleDate: DateTime.parse(_datetimeController.text),
                            quantity: int.parse(_quantityController.text),
                            status: true,
                            orderId: orderModels[0].orderid,
                            saleId: 0,
                          ));
                          principalProductProvider.updateQuantity(
                              orderModels[0].productid,
                              int.parse(_quantityController.text),
                              true);
                          principalOrderProvider.updateQuantity(
                              orderModels[0].orderid,
                              int.parse(_quantityController.text),
                              true);
                        } else {
                          try {
                            List<SaleModel> sales = [];
                            int quantity = int.parse(_quantityController.text);
                            for (OrderModel orderModel in orderModels) {
                              if (quantity > orderModel.remainingQuantity) {
                                sales.add(SaleModel(
                                    saleId: 0,
                                    orderId: orderModel.orderid,
                                    saleDate: DateTime.parse(
                                        _datetimeController.text),
                                    quantity: orderModel.remainingQuantity,
                                    status: true));
                                quantity -= orderModel.remainingQuantity;
                              } else {
                                sales.add(SaleModel(
                                    saleId: 0,
                                    orderId: orderModel.orderid,
                                    saleDate: DateTime.parse(
                                        _datetimeController.text),
                                    quantity: quantity,
                                    status: true));

                                break;
                              }
                            }
                            await principalSaleProvider.createSales(sales);
                            principalOrderProvider.decreaseQuantity(sales);
                            principalProductProvider.updateQuantity(
                                orderModels[0].productid,
                                int.parse(_quantityController.text),
                                false);
                            showSnackBar(context,
                                "Se ha realizado el registro de las diferentes ventas de órdenes.");
                          } catch (e) {
                            showSnackBar(context, e.toString());
                          }
                        }

                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Crear ventas"))
              ],
            )));
  }
}
