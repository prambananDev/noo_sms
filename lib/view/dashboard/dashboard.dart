import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noo_sms/assets/global.dart';
import 'package:noo_sms/controllers/dashboard/dashboard_sms_controller.dart';
import 'package:noo_sms/view/dashboard/dashboard_noo.dart';
import 'package:noo_sms/view/dashboard/dashboard_sample.dart';
import 'package:noo_sms/view/dashboard/dashboard_sms.dart';
import 'package:noo_sms/view/noo/approval/approval_page.dart';
import 'package:noo_sms/view/noo/approved/approved_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({Key? key}) : super(key: key);

  @override
  DashboardMainState createState() => DashboardMainState();
}

class DashboardMainState extends State<DashboardMain> {
  final DashboardController _controller = DashboardController();

  String? longitudeData;
  String? latitudeData;
  String? streetName;
  String? city;
  String? state;
  String? countrys;
  String? zipCode;
  String? addressDetail;
  String? ward;
  String? districts;
  String? role;

  @override
  void initState() {
    super.initState();
    // _checkRoleAndNavigate();
    getCurrentLocation();
  }

  Future<void> _checkRoleAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString("Role");

    if (role == '1') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ApprovalPage(
                  role: role,
                )),
      );
    } else if (role == '0') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardNoo()),
      );
    }
  }

  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    await _getAddressFromPosition(position);
  }

  Future<void> _getAddressFromPosition(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placeMark = placemarks[0];

      String street = "${placeMark.thoroughfare} ${placeMark.subThoroughfare}";
      String subLocality = placeMark.subLocality ?? '';
      String locality = placeMark.locality ?? '';
      String administrativeArea = placeMark.administrativeArea ?? '';
      String subAdministrativeArea = placeMark.subAdministrativeArea ?? '';
      String postalCode = placeMark.postalCode ?? '';
      String country = placeMark.country ?? '';

      String fullAddress =
          "$street, $subLocality, $locality, $subAdministrativeArea, $administrativeArea, $postalCode, $country";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        longitudeData = "${position.longitude}";
        latitudeData = "${position.latitude}";
        streetName = street;
        city = subAdministrativeArea;
        state = administrativeArea;
        countrys = country;
        zipCode = postalCode;
        addressDetail = fullAddress;
        ward = subLocality;
        districts = locality;

        prefs.setString("getStreetName", streetName!);
        prefs.setString("getCity", city!);
        prefs.setString("getCountry", countrys!);
        prefs.setString("getState", state!);
        prefs.setString("getZipCode", zipCode!);
        prefs.setString("getSubLocality", ward!);
        prefs.setString("getLocality", districts!);
        prefs.setString("getAddressDetail", addressDetail!);
        prefs.setString("getLongitude", longitudeData!);
        prefs.setString("getLatitude", latitudeData!);
      });
      _checkPrefsData(prefs);
    } else {}
  }

  void _checkPrefsData(SharedPreferences prefs) {
    String? savedStreetName = prefs.getString("getStreetName");
    String? savedCity = prefs.getString("getCity");
    String? savedCountry = prefs.getString("getCountry");
    String? savedLatitude = prefs.getString("getLatitude");
    String? savedaddress = prefs.getString("getAddressDetail");

    if (savedStreetName == streetName &&
        savedCity == city &&
        savedCountry == countrys &&
        savedLatitude == latitudeData) {
      debugPrint(savedaddress);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorNetral,
      appBar: AppBar(
        backgroundColor: colorAccent,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _controller.logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                ),
                onPressed: () => _navigateTo(
                    context,
                    const DashboardPage(
                      initialIndex: 0,
                    )),
                child: Text(
                  "Dashboard SMS",
                  style: TextStyle(color: colorNetral),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                ),
                onPressed: () =>
                    _navigateTo(context, const DashboardOrderSample()),
                child:
                    Text("Sample Order", style: TextStyle(color: colorNetral)),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                ),
                onPressed: () {
                  // _checkRoleAndNavigate();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ApprovedView()),
                  );
                },
                child:
                    Text("NOO Dashboard", style: TextStyle(color: colorNetral)),
              ),
            ),
            // Get Current Location Button
            // ElevatedButton(
            //   onPressed: getCurrentLocation,
            //   child: const Text("Get Current Location"),
            // ),
          ],
        ),
      ),
    );
  }
}
