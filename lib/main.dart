import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const ClimaApp());
}

class ClimaApp extends StatelessWidget {
  const ClimaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double? latitude;
  double? longitude;
  String? weatherData;

  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  Future<void> getLocationData() async {
    try {

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude;
      longitude = position.longitude;

      String apiKey = 'e9c748dffdfbea92134d44cd14a3b33a'; 
      var url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        weatherData = response.body;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LocationScreen(weatherData: weatherData!),
          ),
        );
      } else {

        print('Lỗi khi tải dữ liệu thời tiết');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class LocationScreen extends StatefulWidget {
  final String weatherData;
  const LocationScreen({Key? key, required this.weatherData}) : super(key: key);
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double? temperature;
  String? condition;
  String? cityName;

  @override
  void initState() {
    super.initState();
    updateUI(widget.weatherData);
  }

  void updateUI(String weatherData) {
    var decodedData = jsonDecode(weatherData);
    setState(() {
      temperature = decodedData['main']['temp'];
      condition = decodedData['weather'][0]['main'];
      cityName = decodedData['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.near_me,
                        color: Colors.white, size: 30),
                    onPressed: () async {

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoadingScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_city,
                        color: Colors.white, size: 30),
                    onPressed: () async {

                      var typedName = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CityScreen()),
                      );
                      if (typedName != null) {
                        String apiKey = 'YOUR_API_KEY'; 
                        var url =
                            'https://api.openweathermap.org/data/2.5/weather?q=$typedName&appid=$apiKey&units=metric';
                        http.Response response =
                            await http.get(Uri.parse(url));
                        if (response.statusCode == 200) {
                          var weatherData = response.body;
                          updateUI(weatherData);
                        }
                      }
                    },
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    temperature != null
                        ? '${temperature!.toStringAsFixed(1)}°C'
                        : '0°C',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    condition != null && cityName != null
                        ? '$condition in $cityName'
                        : 'Không có dữ liệu',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Have a nice day!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CityScreen extends StatefulWidget {
  const CityScreen({Key? key}) : super(key: key);
  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String? cityName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Thành Phố'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                hintText: 'Nhập tên thành phố',
                hintStyle: TextStyle(color: Colors.white70),
                icon: Icon(Icons.location_city, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (value) {
                cityName = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, cityName);
              },
              child: const Text('Tìm Kiếm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}