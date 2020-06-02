class RideReportModel {
  final String customerName;
  final String driverName;
  final String customerPhone;
  final String driverPhone;
  final String carNo;
  final String carModel;
  final double distance;
  final double price;
  final String pickUpLocation;
  final String dropLocation;
  RideReportModel(
      {this.customerName,
      this.driverName,
      this.customerPhone,
      this.driverPhone,
      this.pickUpLocation,
      this.dropLocation,
      this.carModel,
      this.carNo,
      this.distance,
      this.price});
}
