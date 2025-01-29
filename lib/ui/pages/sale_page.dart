import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/domain/entities/sale_model.dart';
import 'package:danventory/providers/order_provider.dart';
import 'package:danventory/providers/product_provider.dart';
import 'package:danventory/providers/sale_provider.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/empty_widget.dart';
import 'package:danventory/ui/widgets/list_tile_widget_sales.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SalePage extends StatelessWidget {
  final OrderModel orderModel;
  const SalePage({super.key, required this.orderModel});
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final principalSaleProvider =
        Provider.of<SaleProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

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
                          child: SaleForm(
                              productId: orderModel.productid,
                              orderid: orderModel.orderid));
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
            text: "Orden ID: ",
            children: [
              TextSpan(
                text: orderModel.orderid.toString(),
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
              child: Text("Error al cargar las ventas"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonListView();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<SaleProvider>(
              builder: (context, saleProvider, child) {
                List<SaleModel> saleModels = saleProvider.saleModels.where((x) {
                  final isStatusMatching = x.status == saleProvider.isActive;

                  if (principalSaleProvider.dates.isEmpty) {
                    return isStatusMatching;
                  }

                  final orderDate = x.saleDate;
                  final isDateInRange =
                      orderDate.isAfter(principalSaleProvider.dates[0]!) &&
                          orderDate.isBefore(principalSaleProvider.dates[1]!);

                  return isStatusMatching && isDateInRange;
                }).toList();
                if (saleProvider.saleModels.isNotEmpty) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Cantidad restante: ",
                            children: [
                              TextSpan(
                                text: orderModel.remainingQuantity.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: getColor(),
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        principalSaleProvider.dates.isEmpty
                            ? const SizedBox
                                .shrink() // Si no hay fechas, no mostrar nada
                            : Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () {
                                    principalSaleProvider.addDates(null);
                                  },
                                  child: Text(
                                    'Rango de fechas: ${_formatDate(principalSaleProvider.dates[0]!)} - ${_formatDate(principalSaleProvider.dates[1]!)}',
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
                              SaleModel saleModel = saleModels[index];
                              return Slidable(
                                startActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            saleModel.status == true
                                                ? ThemeSetting.redColor
                                                : ThemeSetting.greenColor,
                                        icon: saleModel.status == true
                                            ? Icons.delete
                                            : Icons.replay,
                                        onPressed: (context) async {
                                          saleModel.status = !saleModel.status;
                                          await principalSaleProvider
                                              .delete(saleModel);
                                          productProvider.updateQuantity(
                                              orderModel.productid,
                                              saleModel.quantity,
                                              orderModel.status);
                                          orderProvider.updateQuantity(
                                              orderModel.orderid,
                                              saleModel.quantity,
                                              orderModel.status);
                                          if (saleModel.status == true) {
                                            orderModel.remainingQuantity -=
                                                saleModel.quantity;
                                          } else {
                                            orderModel.remainingQuantity +=
                                                saleModel.quantity;
                                          }
                                        },
                                      )
                                    ]),
                                child:
                                    ListTileWidgetSales(saleModel: saleModel),
                              );
                            },
                            itemCount: saleModels.length,
                          ),
                        ),
                      ]);
                } else {
                  return const EmptyWidget(title: "Añade ventas");
                }
              },
            );
          }
          return Container();
        },
        future: principalSaleProvider.read(orderModel.orderid),
      ),
    );
  }

  Color getColor() {
    if (orderModel.remainingQuantity == orderModel.quantity) {
      return ThemeSetting.principalColor;
    } else if (orderModel.remainingQuantity < orderModel.quantity) {
      return ThemeSetting.greenColor;
    } else {
      return ThemeSetting.redColor;
    }
  }
}

class StateSwitch extends StatelessWidget {
  const StateSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleProvider>(
      builder: (context, saleProviderValue, child) {
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
                  value: saleProviderValue.isActive,
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
                    saleProviderValue.changeDrop();
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
    final principalSaleProvider =
        Provider.of<SaleProvider>(context, listen: false);
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
          principalSaleProvider.addDates(results);
        }
      },
      child: const Row(
        children: [Text("Rango de fecha:"), Icon(Icons.calendar_month)],
      ),
    );
  }
}

class SaleForm extends StatelessWidget {
  final _quantityController = TextEditingController();
  final _datetimeController = TextEditingController();
  final int productId;
  final int orderid;
  final _formKey = GlobalKey<FormState>();
  SaleForm({super.key, required this.productId, required this.orderid});

  @override
  Widget build(BuildContext context) {
    final principalSaleProvider =
        Provider.of<SaleProvider>(context, listen: false);
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
                    } else if (int.parse(value) >
                        principalOrderProvider.orderModels
                            .where((element) => element.orderid == orderid)
                            .first
                            .remainingQuantity) {
                      return 'La cantidad debe ser menor o igual a la cantidad restante';
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
                        principalSaleProvider.create(SaleModel(
                          saleDate: DateTime.parse(_datetimeController.text),
                          quantity: int.parse(_quantityController.text),
                          status: true,
                          orderId: orderid,
                          saleId: 0,
                        ));
                        principalProductProvider.updateQuantity(productId,
                            int.parse(_quantityController.text), true);
                        principalOrderProvider.updateQuantity(
                            orderid, int.parse(_quantityController.text), true);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Crear venta"))
              ],
            )));
  }
}
