import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oitaxi/models/customer.dart';
import 'package:oitaxi/models/driver.dart';

class DataBaseService {
  final String email;
  DataBaseService({this.email});
  static bool isDriver;

  final CollectionReference userCollection =
      Firestore.instance.collection('customer');
  final CollectionReference driverCollection =
      Firestore.instance.collection('driver');
//  final CollectionReference loginInfo = Firestore.instance.collection('login');

//  Future<void> successfulLogin() async {
//    return await loginInfo.document(uid).setData({'isLogin': true, 'uid': uid});
//  }

//  Future<void> logout() async {
//    print('await called');
//    return await loginInfo.document(uid).updateData({'isLogin': false});
//  }

  Future<void> updateCustomerData(
      String displayName,
      String email,
      String photoUrl,
      String phoneNumber,
      String uid,
      String address,
      String gender) async {
    return await userCollection.document(email).setData({
      'name': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'uid': uid,
      'phoneNumber': phoneNumber,
      'address': address,
      'gender': gender
    });
  }

  Future<void> updateDriverData(
      String displayName,
      String email,
      String photoUrl,
      String phoneNumber,
      String uid,
      String address,
      String carModel,
      String carNo,
      String gender) async {
    return await driverCollection.document(email).setData({
      'name': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'uid': uid,
      'phoneNumber': phoneNumber,
      'address': address,
      'carModel': carModel,
      'carNo': carNo,
      'gender': gender
    });
  }

  Customer _customerDataFromSnapshot(DocumentSnapshot snapshot) {
    return Customer(
        uid: snapshot.data['uid'],
        displayName: snapshot.data['name'],
        email: snapshot.data['email'],
        photoUrl: snapshot.data['photoUrl'],
        phoneNumber: snapshot.data['phoneNumber'],
        address: snapshot.data['address'],
        gender: snapshot.data['gender']);
  }

  Stream<Customer> get customerData {
    return userCollection
        .document(email)
        .snapshots()
        .map(_customerDataFromSnapshot);
  }

  Driver _driverDataFromSnapshot(DocumentSnapshot snapshot) {
    return Driver(
        uid: snapshot.data['uid'],
        displayName: snapshot.data['name'],
        email: snapshot.data['email'],
        photoUrl: snapshot.data['photoUrl'],
        phoneNumber: snapshot.data['phoneNumber'],
        address: snapshot.data['address'],
        carModel: snapshot.data['carModel'],
        carNo: snapshot.data['carNo'],
        gender: snapshot.data['gender']);
  }

  Stream<Driver> get driverData {
    return driverCollection
        .document(email)
        .snapshots()
        .map(_driverDataFromSnapshot);
  }

//  Future<bool> getLoginInfo() async {
//    QuerySnapshot snapshot =
//        await loginInfo.where('uid', isEqualTo: uid).getDocuments();
//    if (snapshot.documents.isEmpty ||
//        snapshot.documents[0].data['isLogin'] == false) {
//      print("Returning true..............................");
//      return true;
//    } else if ((snapshot.documents[0].data['isLogin']) == true) {
//      print("Returning false..............................");
//      return false;
//    }
//  }
  Future<int> previousLogin() async {
    QuerySnapshot customerSnapshot =
        await userCollection.where('email', isEqualTo: email).getDocuments();
    QuerySnapshot driverSnapshot =
        await driverCollection.where('email', isEqualTo: email).getDocuments();
    if (customerSnapshot.documents.isNotEmpty) {
      DataBaseService.isDriver = false;
      return 1;
    } else if (driverSnapshot.documents.isNotEmpty) {
      DataBaseService.isDriver = true;
      return 2;
    } else
      return 3;
  }
}
