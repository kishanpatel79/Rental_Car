import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  // Add const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Rental',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

// Data Storage (in production use shared_preferences or database)
class AppData {
  static List<Booking> bookings = [];
  static String adminPhone = '+917600200361'; // Admin number
}

class Booking {
  final Car car;
  final String pickupCity;
  final String dropCity;
  final double distance;
  final double totalCost;
  final DateTime bookingTime;

  Booking({
    required this.car,
    required this.pickupCity,
    required this.dropCity,
    required this.distance,
    required this.totalCost,
  }) : bookingTime = DateTime.now();
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      UserData.email = _emailController.text;
      UserData.phone = _phoneController.text;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (with country code)',
                  hintText: '+919876543210',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserData {
  static String email = '';
  static String phone = '';
}

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rental Cars in Gujarat')),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Car Rental App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarListScreen()),
                );
              },
              child: Text('View Available Cars'),
            ),
          ],
        ),
      ),
    );
  }
}

// Drawer Widget
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Car Rental Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.car_rental),
            title: Text('Available Cars'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CarListScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Ride History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RideHistoryScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

// Car Model and Data
class Car {
  final String name;
  final String image;
  final double pricePerKm;

  Car({required this.name, required this.image, required this.pricePerKm});
}

Map<String, Map<String, double>> cityDistances = {
  "Ahmedabad": {
    "Anand": 76,
    "Nadiad": 65,
    "Dakor": 90,
    "Umreth": 85,
    "Changa": 78
  },
  "Anand": {
    "Ahmedabad": 76,
    "Nadiad": 15,
    "Dakor": 35,
    "Umreth": 12,
    "Changa": 10
  },
  "Nadiad": {
    "Ahmedabad": 65,
    "Anand": 15,
    "Dakor": 50,
    "Umreth": 20,
    "Changa": 18
  },
  "Dakor": {
    "Ahmedabad": 90,
    "Anand": 35,
    "Nadiad": 50,
    "Umreth": 25,
    "Changa": 30
  },
  "Umreth": {
    "Ahmedabad": 85,
    "Anand": 12,
    "Nadiad": 20,
    "Dakor": 25,
    "Changa": 8
  },
  "Changa": {
    "Ahmedabad": 78,
    "Anand": 10,
    "Nadiad": 18,
    "Dakor": 30,
    "Umreth": 8
  },
};

class CarListScreen extends StatelessWidget {
  final List<Car> cars = [
    Car(
        name: "Maruti Swift",
        image: "https://images.pexels.com/photos/112460/pexels-photo-112460.jpeg?auto=compress&cs=tinysrgb&w=600",
        pricePerKm: 10),
    Car(
        name: "Hyundai Creta",
        image: "https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=600",
        pricePerKm: 15),
    Car(
        name: "Mahindra Thar",
        image: "https://images.pexels.com/photos/909907/pexels-photo-909907.jpeg?auto=compress&cs=tinysrgb&w=600",
        pricePerKm: 20),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rental Cars in Gujarat')),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          Car car = cars[index];
          return Card(
            child: ListTile(
              leading: Image.network(car.image,
                  width: 80, height: 80, fit: BoxFit.cover),
              title: Text(car.name),
              subtitle: Text("₹${car.pricePerKm}/km"),
              trailing: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingScreen(car: car))),
                child: Text("Book"),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  final Car car;

  BookingScreen({required this.car});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? pickupCity;
  String? dropCity;
  double distance = 0.0;
  double totalCost = 0.0;

  void _calculatePrice() {
    if (pickupCity != null && dropCity != null && pickupCity != dropCity) {
      double dist = cityDistances[pickupCity!]![dropCity!]!;
      double cost = dist * widget.car.pricePerKm;
      setState(() {
        distance = dist;
        totalCost = cost;
      });
    }
  }




  Future<void> _sendAdminNotification(Booking booking) async {
    final String body = Uri.encodeComponent('''
New Booking:
User: ${UserData.email} (${UserData.phone})
Car: ${booking.car.name}
From: ${booking.pickupCity}
To: ${booking.dropCity}
Distance: ${booking.distance.toStringAsFixed(2)} km
Amount: ₹${booking.totalCost.toStringAsFixed(2)}
Time: ${booking.bookingTime}
''');

    final Uri smsUri = Uri.parse(
        Platform.isAndroid
            ? "sms:${AppData.adminPhone}?body=$body"
            : "sms:${AppData.adminPhone}&body=$body"
    );
    await launchUrl(smsUri);
    // if (await canLaunchUrl(smsUri)) {
    //   await launchUrl(smsUri);
    // } else {
    //   print("Could not launch SMS app");
    // }
  }


  Future<void> _sendAdminNotification1(Booking booking) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: AppData.adminPhone,
      queryParameters: {
        'body': '''
New Booking:
User: ${UserData.email} (${UserData.phone})
Car: ${booking.car.name}
From: ${booking.pickupCity}
To: ${booking.dropCity}
Distance: ${booking.distance.toStringAsFixed(2)} km
Amount: ₹${booking.totalCost.toStringAsFixed(2)}
Time: ${booking.bookingTime}
'''
      },
    );

    if (await canLaunchUrlString(smsLaunchUri.toString())) {
      await launchUrlString(smsLaunchUri.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book ${widget.car.name}")),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(widget.car.image, height: 200),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: pickupCity,
              decoration: InputDecoration(labelText: "Pickup City"),
              items: cityDistances.keys
                  .map((city) =>
                  DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  pickupCity = value;
                  dropCity = null;
                  distance = 0.0;
                  totalCost = 0.0;
                });
              },
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: dropCity,
              decoration: InputDecoration(labelText: "Drop City"),
              items: pickupCity != null
                  ? cityDistances[pickupCity!]!
                  .keys
                  .map((city) =>
                  DropdownMenuItem(value: city, child: Text(city)))
                  .toList()
                  : [],
              onChanged: (value) {
                setState(() => dropCity = value);
                _calculatePrice();
              },
            ),
            SizedBox(height: 20),
            Text("Distance: ${distance.toStringAsFixed(2)} km",
                style: TextStyle(fontSize: 16)),
            Text("Total Cost: ₹${totalCost.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (pickupCity != null &&
                  dropCity != null &&
                  pickupCity != dropCity)
                  ? () async {
                final booking = Booking(
                  car: widget.car,
                  pickupCity: pickupCity!,
                  dropCity: dropCity!,
                  distance: distance,
                  totalCost: totalCost,
                );

                AppData.bookings.add(booking);
                await _sendAdminNotification(booking);

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(booking: booking),
                  ),
                );

                Navigator.pushReplacementNamed(context, '/home');
              }
                  : null,
              child: Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptScreen extends StatefulWidget {
  final Booking booking;

  ReceiptScreen({required this.booking});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  void initState() {
    super.initState();
    _sendReceipt();
  }

  Future<void> _sendReceipt() async {
    // Send email
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: UserData.email,
      queryParameters: {
        'subject': 'Your Car Rental Booking Confirmation',
        'body': '''
Booking Details:
Car: ${widget.booking.car.name}
From: ${widget.booking.pickupCity}
To: ${widget.booking.dropCity}
Distance: ${widget.booking.distance.toStringAsFixed(2)} km
Total: ₹${widget.booking.totalCost.toStringAsFixed(2)}
Time: ${widget.booking.bookingTime}
'''
      },
    );

    // Send SMS
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: UserData.phone,
      queryParameters: {
        'body': '''
Your Booking:
${widget.booking.car.name}
From: ${widget.booking.pickupCity}
To: ${widget.booking.dropCity}
Amount: ₹${widget.booking.totalCost.toStringAsFixed(2)}
'''
      },
    );

    try {
      if (await canLaunch(emailUri.toString()))
        await launch(emailUri.toString());
      if (await canLaunch(smsUri.toString())) await launch(smsUri.toString());
    } catch (e) {
      print('Error sending receipts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Receipt")),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking Confirmed!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            SizedBox(height: 20),
            Text("Car: ${widget.booking.car.name}",
                style: TextStyle(fontSize: 18)),
            Text("From: ${widget.booking.pickupCity}"),
            Text("To: ${widget.booking.dropCity}"),
            Text("Distance: ${widget.booking.distance.toStringAsFixed(2)} km"),
            Text("Total: ₹${widget.booking.totalCost.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.green)),
            Text("Time: ${widget.booking.bookingTime}"),
            SizedBox(height: 30),
            Text("Receipt sent to:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(UserData.email),
            Text(UserData.phone),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ride History')),
      drawer: AppDrawer(),
      body: AppData.bookings.isEmpty
          ? Center(child: Text('No bookings yet'))
          : ListView.builder(
        itemCount: AppData.bookings.length,
        itemBuilder: (context, index) {
          final booking = AppData.bookings[index];
          return Card(
            child: ListTile(
              title: Text(booking.car.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${booking.pickupCity} → ${booking.dropCity}'),
                  Text('${booking.distance.toStringAsFixed(2)} km'),
                  Text('₹${booking.totalCost.toStringAsFixed(2)}'),
                  Text('${booking.bookingTime}'),
                ],
              ),
              trailing: Icon(Icons.receipt),
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Email: ${UserData.email}'),
            Text('Phone: ${UserData.phone}'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RideHistoryScreen()),
                );
              },
              child: Text('View Ride History'),
            ),
          ],
        ),
      ),
    );
  }
}
