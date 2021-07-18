import 'package:flutter/material.dart';
import 'package:liveasy_admin/functions/updateDocumentApi.dart';
import 'package:liveasy_admin/functions/updateUserApi.dart';
import 'package:liveasy_admin/models/shipperApiModel.dart';
import 'package:get/get.dart';
import 'package:liveasy_admin/controller/ShipperController.dart';
import 'package:liveasy_admin/services/getUserDocuments.dart';
import 'package:liveasy_admin/widgets/appBar.dart';
import 'package:liveasy_admin/widgets/cancelButtonWidget.dart';
import 'package:liveasy_admin/services/showDialog.dart';
import 'package:liveasy_admin/widgets/radioButtonWidget.dart';
import 'package:liveasy_admin/widgets/saveButtonWidget.dart';
import 'package:liveasy_admin/widgets/updateScreenCardLayout.dart';
import 'package:liveasy_admin/widgets/updateScreenTextField.dart';
import 'package:liveasy_admin/constants/color.dart';
import 'package:liveasy_admin/constants/fontWeight.dart';
import 'package:liveasy_admin/constants/screenSizeConfig.dart';
import 'package:liveasy_admin/constants/space.dart';

class UpdateShipperScreen extends StatefulWidget {
  final ShipperDetailsModel shipperDetails;
  UpdateShipperScreen({required this.shipperDetails});

  @override
  _UpdateShipperScreenState createState() => _UpdateShipperScreenState();
}

class _UpdateShipperScreenState extends State<UpdateShipperScreen> {
  double height = SizeConfig.safeBlockVertical!;
  double width = SizeConfig.safeBlockHorizontal!;
  FocusNode nameFocusNode = FocusNode();
  FocusNode locationFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode companyFocusNode = FocusNode();
  bool isNameEditable = false;
  bool isLocationEditable = false;
  bool isCompanyNameEditable = false;
  List<bool?> documentVerificationStatus = [];
  Map<String, dynamic> dataToUpdate = {};
  Map<String, dynamic> documentDataToUpdate = {};
  List<Map<String, dynamic>> listofDocuments = [];
  Map<String, dynamic> documentData = {};
  ShipperController shipperController = Get.find<ShipperController>();

  Future<void> saveChangesOnPressed() async {
    if (shipperController.shipperName.value != "" &&
        widget.shipperDetails.shipperName !=
            shipperController.shipperName.value) {
      dataToUpdate.addAll({'shipperName': shipperController.shipperName.value});
    }
    if (shipperController.shipperLocation.value != "" &&
        widget.shipperDetails.shipperLocation !=
            shipperController.shipperLocation.value) {
      dataToUpdate['shipperLocation'] = shipperController.shipperLocation.value;
    }
    if (shipperController.shipperCompanyName.value != "" &&
        widget.shipperDetails.companyName !=
            shipperController.shipperCompanyName.value) {
      dataToUpdate['companyName'] = shipperController.shipperCompanyName.value;
    }

    if (shipperController.identityProofApprovalStatus.value !=
        documentVerificationStatus[0]) {
      documentData = {'documentType': 'PAN'};
      documentData['verified'] =
          shipperController.identityProofApprovalStatus.value;
      listofDocuments.add(documentData);
    }
    if (shipperController.addressProofFrontApprovalStatus.value !=
        documentVerificationStatus[1]) {
      documentData = {'documentType': 'Aadhar1'};
      documentData['verified'] =
          shipperController.addressProofFrontApprovalStatus.value;
      listofDocuments.add(documentData);
    }
    if (shipperController.addressProofBacktApprovalStatus.value !=
        documentVerificationStatus[2]) {
      documentData = {'documentType': 'Aadhar2'};
      documentData['verified'] =
          shipperController.addressProofBacktApprovalStatus.value;
      listofDocuments.add(documentData);
    }
    if (shipperController.companyProofApprovalStatus.value !=
        documentVerificationStatus[3]) {
      documentData = {'documentType': 'GST'};
      documentData['verified'] =
          shipperController.companyProofApprovalStatus.value;
      listofDocuments.add(documentData);
    }

    bool changedShipperApprovalStatus;
    if (shipperController.shipperApprovalStatus.value == 1) {
      changedShipperApprovalStatus = true;
    } else {
      changedShipperApprovalStatus = false;
    }
    if (changedShipperApprovalStatus != widget.shipperDetails.companyApproved) {
      dataToUpdate.addAll({"companyApproved": changedShipperApprovalStatus});
    }

    bool changedShipperProcessStatus;
    if (shipperController.shipperAccountVerficationInProgress.value == 2) {
      changedShipperProcessStatus = true;
    } else {
      changedShipperProcessStatus = false;
    }
    if (changedShipperProcessStatus != widget.shipperDetails.companyApproved) {
      dataToUpdate.addAll(
          {"accountVerificationInProgress": changedShipperProcessStatus});
    }

    if (shipperController.shipperApprovalStatus.value == 1) {
      if (shipperController.identityProofApprovalStatus.value &&
          shipperController.addressProofFrontApprovalStatus.value &&
          shipperController.addressProofBacktApprovalStatus.value &&
          shipperController.companyProofApprovalStatus.value) {
        if (shipperController.shipperName.value != "") {
          if (shipperController.shipperLocation.value != "") {
            if (shipperController.shipperCompanyName.value != "") {
              if (shipperController.shipperAccountVerficationInProgress.value ==
                  1) {
                if (dataToUpdate.isNotEmpty) {
                  print('Shipper Data to Update');
                  print(dataToUpdate);
                  String status = await runPutUserApi(
                      type: "Shipper",
                      toBeUpdated: dataToUpdate,
                      userId: widget.shipperDetails.shipperId!);
                  if (status == "Error") {
                    dialogBox(
                        context,
                        "Error",
                        'User Details Not Updated\nPlease try again',
                        null,
                        "DataNotUpdated");
                  }
                } else {
                  print("Nothing to Update");
                }
                if (listofDocuments.isNotEmpty) {
                  documentDataToUpdate["documents"] = listofDocuments;
                  documentDataToUpdate["entityId"] =
                      widget.shipperDetails.shipperId!;
                  print('Document Data to Update');
                  print(documentDataToUpdate);
                  String docUpdateStatus = await runPutDocumentApi(
                      toBeUpdated: documentDataToUpdate,
                      userId: widget.shipperDetails.shipperId!);
                  if (docUpdateStatus == "Error") {
                    dialogBox(
                        context,
                        "Error",
                        "Document Details Not Updated\nPlease try again",
                        null,
                        "DataNotUpdated");
                  } else {
                    Navigator.of(context).pop();
                  }
                } else {
                  print("\n\nNo Document to Update");
                  Navigator.of(context).pop();
                }
              } else {
                dialogBox(
                    context,
                    "Alert",
                    "Account Verification Process Status should be Completed not Pending\n Please make necessary changes",
                    null,
                    "NonDismissible");
              }
            } else {
              dialogBox(context, 'Alert', 'Company is not entered', null,
                  "NonDismissible");
            }
          } else {
            dialogBox(context, 'Alert', 'Shipper Location is not entered', null,
                "NonDismissible");
          }
        } else {
          dialogBox(context, 'Alert', 'Shipper Name is not entered', null,
              "NonDismissible");
        }
      } else {
        dialogBox(
            context,
            'Alert',
            'All Documents should be approved\nApprove all documents OR Keep Company Approval Status On Halt',
            null,
            "NonDismissible");
      }
    } else if (shipperController.shipperAccountVerficationInProgress.value ==
            2 &&
        shipperController.shipperApprovalStatus.value == 2) {
      if (dataToUpdate.isNotEmpty) {
        print('Shipper Data to Update');
        print(dataToUpdate);
        String status = await runPutUserApi(
            type: "Shipper",
            toBeUpdated: dataToUpdate,
            userId: widget.shipperDetails.shipperId!);
        if (status == "Error") {
          dialogBox(
              context,
              "Error",
              'User Details Not Updated\nPlease try again',
              null,
              "DataNotUpdated");
        }
      } else {
        print("\n\nNothing to Update");
      }
      if (listofDocuments.isNotEmpty) {
        documentDataToUpdate["documents"] = listofDocuments;
        documentDataToUpdate["entityId"] = widget.shipperDetails.shipperId!;
        print('Document Data to Update');
        print(documentDataToUpdate);
        String docUpdateStatus = await runPutDocumentApi(
            toBeUpdated: dataToUpdate,
            userId: widget.shipperDetails.shipperId!);
        if (docUpdateStatus == "Error") {
          dialogBox(
              context,
              "Error",
              "Document Details Not Updated\nPlease try again",
              null,
              "DataNotUpdated");
        } else {
          Navigator.of(context).pop();
        }
      } else {
        print("No Document to Update");
        Navigator.of(context).pop();
      }
    } else if (shipperController.shipperAccountVerficationInProgress.value ==
            1 &&
        shipperController.shipperApprovalStatus.value == 2) {
      if (dataToUpdate.isNotEmpty) {
        print("Shipper Data to Update");
        print(dataToUpdate);
        return showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Alert'),
                  content: Text('Are you sure you want to Reject this User'),
                  actions: [
                    TextButton(
                        child: Text('Confirm'),
                        onPressed: () async {
                          dataToUpdate.addAll({
                            "accountVerificationInProgress": false,
                            "companyApproved": false
                          });
                          String status = await runPutUserApi(
                              type: "Shipper",
                              toBeUpdated: dataToUpdate,
                              userId: widget.shipperDetails.shipperId!);
                          Navigator.of(context).pop();
                          if (status == "Error") {
                            dialogBox(
                                context,
                                "Error",
                                'Details Not Update\nPlease try again',
                                null,
                                "DataNotUpdated");
                          }
                        }),
                    SizedBox(width: width * 40),
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ]);
            });
      } else {
        print("Nothing to update");
      }
      if (listofDocuments.isNotEmpty) {
        documentDataToUpdate["documents"] = listofDocuments;
        documentDataToUpdate["entityId"] = widget.shipperDetails.shipperId!;
        print('Document Data to Update');
        print(documentDataToUpdate);
        String docUpdateStatus = await runPutDocumentApi(
            toBeUpdated: dataToUpdate,
            userId: widget.shipperDetails.shipperId!);
        if (docUpdateStatus == "Error") {
          dialogBox(
              context,
              "Error",
              "Document Details Not Updated\nPlease try again",
              null,
              "DataNotUpdated");
        } else {
          Navigator.of(context).pop();
        }
      } else {
        print("No Document to Update");
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController name =
        TextEditingController(text: widget.shipperDetails.shipperName);
    shipperController.updateShipperName(
        widget.shipperDetails.shipperName == null
            ? ""
            : widget.shipperDetails.shipperName!);
    TextEditingController contact =
        TextEditingController(text: widget.shipperDetails.phoneNo);
    TextEditingController location =
        TextEditingController(text: widget.shipperDetails.shipperLocation);
    shipperController.updateShipperLocation(
        widget.shipperDetails.shipperLocation == null
            ? ""
            : widget.shipperDetails.shipperLocation!);
    TextEditingController companyName =
        TextEditingController(text: widget.shipperDetails.companyName);
    shipperController.updateShipperCompanyName(
        widget.shipperDetails.companyName == null
            ? ""
            : widget.shipperDetails.companyName!);
    shipperController.updateOnShipperApproval(
        widget.shipperDetails.companyApproved! ? 1 : 2);
    shipperController.updateShipperAccountVerification(
        widget.shipperDetails.accountVerificationInProgress! ? 2 : 1);
    return Scaffold(
        appBar: appBar(),
        body: SingleChildScrollView(child: Center(child: Obx(() {
          shipperController.shipperDocumentAPIfailed.value;
          return FutureBuilder(
              future: getUserDocumentURL(widget.shipperDetails.shipperId!),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    Future(() {
                      dialogBox(
                          context,
                          'Error Loading Documents',
                          'Unable to Fetch the User Documents\nPlease try again later',
                          null,
                          "ShipperDocuments");
                    });
                    return Container();
                  } else {
                    documentVerificationStatus.addAll([
                      snapshot.data[2],
                      snapshot.data[4],
                      snapshot.data[6],
                      snapshot.data[8]
                    ]);
                    shipperController.updateIdentityProofApprovalStatus(
                        snapshot.data[2] != null ? snapshot.data[2] : false);
                    shipperController.updateAddressProofFrontApprovalStatus(
                        snapshot.data[4] != null ? snapshot.data[4] : false);
                    shipperController.updateAddressProofBackApprovalStatus(
                        snapshot.data[6] != null ? snapshot.data[6] : false);
                    shipperController.updateCompanyProofApprovalStatus(
                        snapshot.data[8] != null ? snapshot.data[8] : false);
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 37),
                          Container(
                              height: height * 40,
                              width: width * 240,
                              child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Text('Shipper details',
                                      style: TextStyle(
                                          fontSize: 32,
                                          color: greyColor,
                                          fontWeight: regularWeight)))),
                          SizedBox(height: height * 30),
                          Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(radius_30)),
                              shadowColor: black,
                              elevation: 2.0,
                              child: Container(
                                  width: width * 1138,
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 46,
                                      horizontal: width * 64),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            height: height * 34,
                                            width: width * 230,
                                            child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: Text('Edit information',
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        color: greyColor,
                                                        fontWeight:
                                                            regularWeight)))),
                                        SizedBox(height: height * 35),
                                        if (snapshot.data[0] == null)
                                          Center(
                                              child: Container(
                                                  height: height * 63,
                                                  width: width * 63,
                                                  child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Image.asset(
                                                          "icons/profile.png"))))
                                        else
                                          Center(
                                              child: Container(
                                                  height: height * 63,
                                                  width: width * 63,
                                                  child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: CircleAvatar(
                                                          child: Image.network(
                                                              snapshot
                                                                  .data[0]))))),
                                        SizedBox(height: height * 70),
                                        Row(children: [
                                          Container(
                                              height: height * 18,
                                              width: width * 48,
                                              child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: Text('Name',
                                                      style: TextStyle(
                                                          color: greyColor,
                                                          fontWeight:
                                                              boldWeight,
                                                          fontSize: 14)))),
                                          SizedBox(width: width * 342),
                                          Container(
                                              height: height * 20,
                                              width: width * 60,
                                              child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: Text('Contact',
                                                      style: TextStyle(
                                                          color: greyColor,
                                                          fontWeight:
                                                              boldWeight,
                                                          fontSize: 14)))),
                                          SizedBox(width: width * 240),
                                          Container(
                                              height: height * 18,
                                              width: width * 68,
                                              child: FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: Text('Location',
                                                      style: TextStyle(
                                                          color: greyColor,
                                                          fontWeight:
                                                              boldWeight,
                                                          fontSize: 14))))
                                        ]),
                                        SizedBox(height: height * 10),
                                        Row(children: [
                                          UpdateScreenTextField(
                                              type: "Shipper",
                                              labelText: "Name",
                                              controller: name,
                                              editable: isNameEditable,
                                              focusNode: nameFocusNode),
                                          SizedBox(width: width * 130),
                                          UpdateScreenTextField(
                                              type: "Shipper",
                                              labelText: "Contact",
                                              controller: contact,
                                              editable: false),
                                          SizedBox(width: width * 130),
                                          UpdateScreenTextField(
                                              type: "Shipper",
                                              labelText: "Location",
                                              controller: location,
                                              editable: isLocationEditable,
                                              focusNode: locationFocusNode)
                                        ]),
                                        SizedBox(height: height * 30),
                                        Container(
                                            height: height * 18,
                                            width: width * 132,
                                            child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: Text('Document image',
                                                    style: TextStyle(
                                                        color: greyColor,
                                                        fontWeight: boldWeight,
                                                        fontSize: 14)))),
                                        SizedBox(height: height * 15),
                                        Obx(() {
                                          return DocumentImageLayout(
                                              type: "Shipper",
                                              pan: snapshot.data[1],
                                              aadhar1: snapshot.data[3],
                                              aadhar2: snapshot.data[5],
                                              panApproved: shipperController
                                                  .identityProofApprovalStatus
                                                  .value,
                                              aadhar1Approved: shipperController
                                                  .addressProofFrontApprovalStatus
                                                  .value,
                                              aadhar2Approved: shipperController
                                                  .addressProofBacktApprovalStatus
                                                  .value);
                                        }),
                                        SizedBox(height: height * 50),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                  height: height * 18,
                                                  width: width * 121,
                                                  child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Text(
                                                          'Company Name',
                                                          style: TextStyle(
                                                              color: greyColor,
                                                              fontWeight:
                                                                  boldWeight,
                                                              fontSize: 10)))),
                                              SizedBox(width: width * 269),
                                              Container(
                                                  height: height * 18,
                                                  width: width * 150,
                                                  child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Text(
                                                          'Shipper Appoval ?',
                                                          style: TextStyle(
                                                              color: greyColor,
                                                              fontWeight:
                                                                  boldWeight,
                                                              fontSize: 14)))),
                                              SizedBox(width: width * 150),
                                              Container(
                                                  height: height * 18,
                                                  width: width * 180,
                                                  child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: Text(
                                                          'Account Verification?',
                                                          style: TextStyle(
                                                              color: greyColor,
                                                              fontWeight:
                                                                  boldWeight,
                                                              fontSize: 14))))
                                            ]),
                                        SizedBox(height: height * 15),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              UpdateScreenTextField(
                                                  type: "Shipper",
                                                  labelText: "Company Name",
                                                  controller: companyName,
                                                  editable:
                                                      isCompanyNameEditable,
                                                  focusNode: companyFocusNode),
                                              SizedBox(width: width * 122),
                                              RadioButtonWidget(
                                                  type: "ShipperApproval"),
                                              SizedBox(width: width * 72),
                                              RadioButtonWidget(
                                                  type:
                                                      "ShipperAccountVerification")
                                            ]),
                                        SizedBox(height: height * 50),
                                        Container(
                                            height: height * 18,
                                            width: width * 130,
                                            child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: Text('Company Details',
                                                    style: TextStyle(
                                                        color: greyColor,
                                                        fontWeight: boldWeight,
                                                        fontSize: 10)))),
                                        SizedBox(height: height * 16),
                                        Obx(() {
                                          return CompanyProofLayout(
                                              gst: snapshot.data[7],
                                              companyProofApproved:
                                                  shipperController
                                                      .companyProofApprovalStatus
                                                      .value);
                                        }),
                                        SizedBox(height: height * 45),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SaveButtonWidget(
                                                  onPressed:
                                                      saveChangesOnPressed),
                                              SizedBox(width: width * 50),
                                              CancelButtonWidget()
                                            ])
                                      ]))),
                          SizedBox(height: height * 50)
                        ]);
                  }
                }
              });
        }))));
  }
}
