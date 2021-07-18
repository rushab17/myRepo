import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liveasy_admin/controller/ShipperController.dart';
import 'package:liveasy_admin/functions/getShipperApi.dart';
import 'package:liveasy_admin/services/shipperDataSource.dart';
import 'package:liveasy_admin/widgets/filterButtonWidget.dart';
import 'package:liveasy_admin/constants/screenSizeConfig.dart';
import 'package:liveasy_admin/services/showDialog.dart';
import 'package:liveasy_admin/widgets/tableStructure.dart';

class ShipperDetailsScreen extends StatefulWidget {
  @override
  _ShipperDetailsScreenState createState() => _ShipperDetailsScreenState();
}

class _ShipperDetailsScreenState extends State<ShipperDetailsScreen> {
  double height = SizeConfig.safeBlockVertical!;
  double width = SizeConfig.safeBlockHorizontal!;
  ShipperController shipperController = Get.put(ShipperController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: height * 37),
              Row(children: [
                Container(
                    height: height * 40,
                    width: width * 240,
                    child: FittedBox(
                        fit: BoxFit.cover,
                        child: Text('Shipper details',
                            style: TextStyle(fontSize: 32)))),
                SizedBox(width: width * 727),
                FilterButtonWidget(type: "Shipper")
              ]),
              SizedBox(height: height * 30),
              Container(
                  width: width * 1137,
                  child: Obx(() {
                    shipperController.shipperDeleted.value;
                    shipperController.shipperAPIfailed.value;
                    return FutureBuilder(
                        future: runGetShipperApi(
                            shipperController.choosenShipperFilter.value),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              if (snapshot.data.length == 0) {
                                return Center(child: Text('NO Data'));
                              } else {
                                var dts = ShipperDataSource(
                                    data: snapshot.data, context: context);
                                return TableStructure(
                                    type: "Shipper", dts: dts);
                              }
                            } else {
                              Future(() {
                                dialogBox(
                                    context,
                                    'Error Loading Shipper Details',
                                    'Unable to Fetch Shipper Details\nPlease try again later',
                                    null,
                                    "Shipper");
                              });
                              return Container();
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        });
                  }))
            ]));
  }
}
