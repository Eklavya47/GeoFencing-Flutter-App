import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:geofence_service/geofence_service.dart' as geoFence;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MyLocation extends StatefulWidget {
  const MyLocation({super.key});

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {

  final Color myColor = Color.fromRGBO(128,178,247, 1);

  String coordinates="No Location found";
  String address='No Address found';
  bool scanning=false;
  bool isGeofencingActive = false;

  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController radiusController = TextEditingController();
  final geoFence.GeofenceService geofenceService = geoFence.GeofenceService.instance;
  geo.Position? currentPosition;

  // Function to send email via SMTP
  Future<void> sendEmail() async {
    String username = 'hokagenaruto2679@gmail.com'; // your email address
    String password = 'bmqn csmq yfvz nyfi';  // your email password (for Gmail use App Passwords if 2FA is enabled)

    final smtpServer = gmail(username, password); // Use Gmail or any other SMTP server

    final message = Message()
      ..from = Address(username, 'Geofence Alert')
      ..recipients.add('${user!.email}') // Email recipient
      ..subject = 'Geofence Exit Alert'
      ..text = 'You have exited the geofence area. Your last coordinates were: $coordinates';

    try {
      final sendReport = await send(message, smtpServer);
      Fluttertoast.showToast(msg: "Email sent");
      print('Email sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      print('Error sending email: ${e.toString()}');
    }
  }

  checkPermission()async{

    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled=await geo.Geolocator.isLocationServiceEnabled();

    print(serviceEnabled);

    if (!serviceEnabled){
      await geo.Geolocator.openLocationSettings();
      return ;
    }


    permission=await geo.Geolocator.checkPermission();

    print(permission);

    if (permission==geo.LocationPermission.denied){

      permission=await geo.Geolocator.requestPermission();

      if (permission==geo.LocationPermission.denied){
        Fluttertoast.showToast(msg: 'Request Denied !');
        return ;
      }

    }

    if(permission==geo.LocationPermission.deniedForever){
      Fluttertoast.showToast(msg: 'Denied Forever !');
      return ;
    }

    getLocation();

  }

  getLocation()async{

    setState(() {scanning=true;});

   try{

    geo.Position position = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);

    setState(() {
      currentPosition = position;
      coordinates = 'Latitude: ${position.latitude} \nLongitude: ${position.longitude}';
    });

    //coordinates='Latitude : ${position.latitude} \nLongitude : ${position.longitude}';

    List<geoCoding.Placemark> result  = await geoCoding.placemarkFromCoordinates(position.latitude, position.longitude);

    if (result.isNotEmpty){
      //address='${result[0].name}, ${result[0].locality} ${result[0].administrativeArea}';
      setState(() {
        address = '${result[0].name}, ${result[0].locality} ${result[0].administrativeArea}';
      });
    }


   }catch(e){
    Fluttertoast.showToast(msg:"${e.toString()}");
   }

    setState(() {scanning=false;});
  }

  void startGeofencing() {
    if (currentPosition == null) {
      Fluttertoast.showToast(msg: "Please get current location first");
      return;
    }

    double radiusValue = double.tryParse(radiusController.text) ?? 100;

    final geofenceList = [
      geoFence.Geofence(
        id: 'my_geofence',
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        radius: [geoFence.GeofenceRadius(id: "radius", length: radiusValue)],
        //triggers: GeofenceTrigger.enter | GeofenceTrigger.exit,
      ),
    ];

    geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    geofenceService.start(geofenceList).catchError(_onError);
    Fluttertoast.showToast(msg: "Geofencing Started!");

    setState(() {
      isGeofencingActive = true; // Mark geofencing as active
    });
  }

  void stopGeofencing() {
    geofenceService.stop();
    Fluttertoast.showToast(msg: "Geofencing Stopped!");

    setState(() {
      isGeofencingActive = false; // Mark geofencing as inactive
    });
  }

  // Geofence status change listener
  Future<void> _onGeofenceStatusChanged(
      geoFence.Geofence geofence,
      geoFence.GeofenceRadius geofenceRadius,
      geoFence.GeofenceStatus geofenceStatus,
      geoFence.Location location
      ) async {

    if (geofenceStatus == geoFence.GeofenceStatus.ENTER){
      Fluttertoast.showToast(msg: "Geofence Entered!");
    }

    // Trigger alarm
    if (geofenceStatus == geoFence.GeofenceStatus.EXIT) {
      Fluttertoast.showToast(msg: "Geofence Exited!");
      // Trigger alarm sound
      FlutterRingtonePlayer().play(
        android: AndroidSounds.ringtone,
        ios: IosSounds.alarm,
        looping: true,
        volume: 1,
        asAlarm: false
      );

      await sendEmail();

      Future.delayed(Duration(seconds: 10), () {
        FlutterRingtonePlayer().stop();
      });
    }
  }

  // Error handler
  void _onError(error) {
    final errorCode = geoFence.getErrorCodesFromError(error);
    if (errorCode == null) {
      Fluttertoast.showToast(msg: "Unknown Error");
      print('Undefined error: $error');
      return;
    }

    Fluttertoast.showToast(msg: "$errorCode");
    print('ErrorCode: $errorCode');
  }

  @override
  void dispose() {
    // Remove listeners and stop geofence service
    geofenceService.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 100,),
          // Image.asset('images/l2.png'),

          SizedBox(height: 20,),
          Text('Current Coordinates',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.grey),),
          SizedBox(height: 20,),

          scanning?
          SpinKitThreeBounce(color: myColor,size: 20,):
          Text('${coordinates}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),

          SizedBox(height: 20,),
          Text('Current Address',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.grey),),
          SizedBox(height: 20,),

          scanning?
          SpinKitThreeBounce(color: myColor,size: 20,):
          Text('${address}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),

          Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: (){checkPermission();},
              icon: Icon(Icons.location_pin,color: Colors.white,),
              label: Text('Current Location',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(backgroundColor: myColor,),
              ),

          ),

          Spacer(),

          //SizedBox(height: 20,),
          // Radius Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Geofence Radius (100 meters Default)",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(height: 20),
          if (!isGeofencingActive)
            ElevatedButton.icon(
              onPressed: startGeofencing,
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: const Text(
                'Enable Geofencing',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),

          if (isGeofencingActive)
            ElevatedButton.icon(
              onPressed: stopGeofencing,
              icon: const Icon(Icons.location_off, color: Colors.white),
              label: const Text(
                'Disable Geofencing',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),

          Spacer(),
        ],
      ),
    );
  }
}