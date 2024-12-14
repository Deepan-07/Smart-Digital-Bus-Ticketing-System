main.dart:

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personal_detail.dart';

import 'home_screen.dart';
import 'women_screen.dart';
import 'history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Ticket App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(), // Initial screen is Sign In
    );
  }
}

// Sign In Page
class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bus,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  try {
                    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (userCredential.user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign In Failed: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Sign In'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sign Up Page
class SignUpPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                "Create Your Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final phone = phoneController.text.trim();
                  final password = passwordController.text.trim();

                  if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  try {
                    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (userCredential.user != null) {
                      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                        'name': name,
                        'email': email,
                        'phone': phone,
                      });

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign Up Failed: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Sign Up'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Already have an account? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MainScreen
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userDetails = snapshot.data();
      });
    }
  }

  static List<Widget> _screens = [
    HomeScreen(),
    WomenScreen(),
    HistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Ticket'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
              ListTile(
  leading: Icon(Icons.person),
  title: Text('Personal Details'),
  onTap: () {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonalDetailsPage()), // Ensure PersonalDetailsPage is imported
    );
  },
),

           
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.woman),
            label: 'Women',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}



personal_detail.dart:

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDetailsPage extends StatefulWidget {
  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _usernameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _contactNumberController.text = data['phone'] ?? '';
        });
      }
    }
  }

  Future<void> _saveDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _usernameController.text,
        'email': _emailController.text,
        'phone': _contactNumberController.text,
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDetails,
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





home_screen.dart:

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _busNoController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  double? _singlePrice;
  double? _totalPrice;
  bool _showTicket = false;
  List<String> _ticketIds = [];
  int _lastTicketNumber = 0;
  late Razorpay _razorpay;
  List<String> _places = [];
  List<String> _filteredPlaces = [];
  
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _fetchPlaces();  // Fetch places on initialization
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchPlaces() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('places').get();
      List<String> places = snapshot.docs.map((doc) => doc.id).toList();
      places.sort();
      setState(() {
        _places = places;
        _filteredPlaces = places;
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  void _filterPlaces(String query) {
    setState(() {
      _filteredPlaces = _places
          .where((place) => place.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showPlaceDialog(TextEditingController controller) {
    setState(() {
      _filteredPlaces = _places; // Show all places initially
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: double.infinity,
                height: 300,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Search place'),
                      onChanged: (query) {
                        setState(() {
                          _filterPlaces(query);
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredPlaces.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_filteredPlaces[index]),
                            onTap: () {
                              controller.text = _filteredPlaces[index];
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _searchPrice() async {
    String busNo = _busNoController.text;
    String from = _fromController.text;
    String to = _toController.text;
    int quantity = int.tryParse(_quantityController.text) ?? 0;

    String docId = "$busNo-$from-$to";

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('fares')
          .doc(docId)
          .get();

      if (doc.exists) {
        int fare = doc['price'];
        setState(() {
          _singlePrice = fare.toDouble();
          _totalPrice = fare.toDouble() * quantity;
        });
      } else {
        setState(() {
          _singlePrice = null;
          _totalPrice = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No fare found for this route")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching fare")),
      );
    }
  }

  void _startPayment() {
    if (_totalPrice == null) return;

    var options = {
      'key': 'your_razorpay_api_key',
      'amount': (_totalPrice! * 100).toInt(),
      'name': 'Bus Ticket Payment',
      'description': 'Payment for bus tickets',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _simulatePaymentSuccess() {
    _handlePaymentSuccess();
  }

  void _handlePaymentSuccess() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    _generateTicketIds(quantity);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed, please try again")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

 void _generateTicketIds(int quantity) async {
    setState(() {
      _ticketIds = [];
    });

    String busNo = _busNoController.text.trim();

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('home_last_ticket_info')
        .doc(busNo)
        .get();

    int lastTicketNumber = 0;

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('lastTicketNumber')) {
        lastTicketNumber = data['lastTicketNumber'];
      }
    }

    List<String> newTicketIds = List.generate(quantity, (index) {
      lastTicketNumber++;
      return "TNSTC${lastTicketNumber.toString().padLeft(2, '0')}";
    });

    setState(() {
      _ticketIds = newTicketIds;  
      _lastTicketNumber = lastTicketNumber;
    });

    await FirebaseFirestore.instance.collection('home_last_ticket_info').doc(busNo).set({
      'lastTicketNumber': _lastTicketNumber,
    });

    _showTicketDetailsDialog();
  }
  void _showTicketDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Digital Bus Ticket Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ticket IDs: ${_ticketIds.join(", ")}'),
              Text('Bus No: ${_busNoController.text}'),
              Text('From: ${_fromController.text}'),
              Text('To: ${_toController.text}'),
              Text('Single Price: ₹$_singlePrice'),
              Text('Total Price: ₹$_totalPrice'),
              Text('Date: ${DateFormat.yMMMd().format(DateTime.now())}'),
              Text('Time: ${DateFormat.jm().format(DateTime.now())}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _saveTicketToHistory();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/history');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTicketToHistory() async {
  try {
    if (_ticketIds.isEmpty) return;

    await FirebaseFirestore.instance.collection('history').add({
      'ticketIds': _ticketIds,
      'busNo': _busNoController.text,
      'from': _fromController.text,
      'to': _toController.text,
      'singlePrice': _singlePrice,
      'totalPrice': _totalPrice,
      'date': DateFormat.yMMMd().format(DateTime.now()),
      'time': DateFormat.jm().format(DateTime.now()),
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Tickets saved successfully");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tickets saved successfully")));

    // Clear input fields after saving
    _busNoController.clear();
    _fromController.clear();
    _toController.clear();
    _quantityController.clear();

    setState(() {
      _singlePrice = null;
      _totalPrice = null;
      _ticketIds = [];
    });
  } catch (e) {
    print("Error saving tickets: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving tickets: ${e.toString()}")));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Book Your Tickets'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _busNoController,
                      decoration: InputDecoration(labelText: 'Bus No'),
                    ),
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        labelText: 'From',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () => _showPlaceDialog(_fromController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _showPlaceDialog(_fromController),
                    ),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(
                        labelText: 'To',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () => _showPlaceDialog(_toController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _showPlaceDialog(_toController),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _searchPrice,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Text('Search Price'),
                    ),
                  ],
                ),
              ),
            ),
            if (_singlePrice != null) ...[
              SizedBox(height: 20),
              Text('Single Price: $_singlePrice'),
              Text('Total Price: $_totalPrice'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text('Pay Now'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _simulatePaymentSuccess,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: Colors.green,
                ),
                child: Text('Simulate Payment Success'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}


women_screen.dart:

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WomenScreen extends StatefulWidget {
  @override
  _WomenScreenState createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
  final TextEditingController _busNoController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  double? _singlePrice;
  double? _totalPrice;
  bool _isLoading = false;
  List<String> _ticketIds = [];
  int _lastTicketNumber = 0;

  List<String> _places = [];
  List<String> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('places').get();
      List<String> places = snapshot.docs.map((doc) => doc.id).toList();
      places.sort();
      setState(() {
        _places = places;
        _filteredPlaces = places;
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  void _filterPlaces(String query) {
    setState(() {
      _filteredPlaces = _places
          .where((place) => place.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showPlaceDialog(TextEditingController controller) {
    setState(() {
      _filteredPlaces = _places;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: double.infinity,
                height: 300,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Search place'),
                      onChanged: (query) {
                        setState(() {
                          _filterPlaces(query);
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredPlaces.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_filteredPlaces[index]),
                            onTap: () {
                              controller.text = _filteredPlaces[index];
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _searchPrice() async {
    setState(() {
      _isLoading = true;
    });

    String busNo = _busNoController.text.trim();
    String from = _fromController.text.trim();
    String to = _toController.text.trim();
    int quantity = int.tryParse(_quantityController.text) ?? 0;

    if (busNo.isEmpty || from.isEmpty || to.isEmpty || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields with valid values")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String docId = "$busNo-$from-$to";

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('fares')
          .doc(docId)
          .get();

      var data = doc.data() as Map<String, dynamic>?;

      if (doc.exists && data != null && data.containsKey('price')) {
        int fare = data['price'];
        setState(() {
          _singlePrice = fare.toDouble();
          _totalPrice = fare.toDouble() * quantity;
        });
      } else {
        setState(() {
          _singlePrice = null;
          _totalPrice = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No fare found for this route")),
        );
      }
    } catch (e) {
      print("Error fetching fare: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching fare: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateTicketIds(int quantity) async {
    setState(() {
      _ticketIds = [];
    });

    String busNo = _busNoController.text.trim();

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('bus_ticket_info')
        .doc(busNo)
        .get();

    int lastTicketNumber = 0;

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('lastTicketNumber')) {
        lastTicketNumber = data['lastTicketNumber'];
      }
    }

    List<String> newTicketIds = List.generate(quantity, (index) {
      lastTicketNumber++;
      return "TNSTC(WS)${lastTicketNumber.toString().padLeft(2, '0')}";
    });

    setState(() {
      _ticketIds = newTicketIds;  
      _lastTicketNumber = lastTicketNumber;
    });

    await FirebaseFirestore.instance.collection('bus_ticket_info').doc(busNo).set({
      'lastTicketNumber': _lastTicketNumber,
    });

    _showTicketDetailsDialog();
  }

  void _showTicketDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Digital Bus Ticket Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ticket IDs: ${_ticketIds.join(", ")}'),
              Text('Bus No: ${_busNoController.text}'),
              Text('From: ${_fromController.text}'),
              Text('To: ${_toController.text}'),
              Text('Single Price: ₹$_singlePrice'),
              Text('Total Price: ₹$_totalPrice'),
              Text('Date: ${DateFormat.yMMMd().format(DateTime.now())}'),
              Text('Time: ${DateFormat.jm().format(DateTime.now())}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _saveTicketToHistory();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/history');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTicketToHistory() async {
  try {
    if (_ticketIds.isEmpty) return;

    await FirebaseFirestore.instance.collection('history').add({
      'ticketIds': _ticketIds,
      'busNo': _busNoController.text,
      'from': _fromController.text,
      'to': _toController.text,
      'singlePrice': _singlePrice,
      'totalPrice': _totalPrice,
      'date': DateFormat.yMMMd().format(DateTime.now()),
      'time': DateFormat.jm().format(DateTime.now()),
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Tickets saved successfully");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tickets saved successfully")));

    // Clear input fields after saving
    _busNoController.clear();
    _fromController.clear();
    _toController.clear();
    _quantityController.clear();

    setState(() {
      _singlePrice = null;
      _totalPrice = null;
      _ticketIds = [];
    });
  } catch (e) {
    print("Error saving tickets: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving tickets: ${e.toString()}")));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
           automaticallyImplyLeading: false,
           title: Center(child: Text('Special for Women'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _busNoController,
                      decoration: InputDecoration(labelText: 'Bus No'),
                    ),
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        labelText: 'From',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () => _showPlaceDialog(_fromController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _showPlaceDialog(_fromController),
                    ),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(
                        labelText: 'To',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () => _showPlaceDialog(_toController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _showPlaceDialog(_toController),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: 'Ticket Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchPrice,
                      child: _isLoading ? CircularProgressIndicator() : Text('Check Price'),
                    ),
                    if (_totalPrice != null)
                      Column(
                        children: [
                          SizedBox(height: 20),
                          Text("Single Ticket Price: ₹$_singlePrice"),
                          Text("Total Price: ₹$_totalPrice"),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              int quantity = int.tryParse(_quantityController.text) ?? 0;
                              if (quantity > 0) {
                                _generateTicketIds(quantity);
                              }
                            },
                            child: Text('Generate Digital Ticket'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


history_screen.dart:

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
             automaticallyImplyLeading: false,
             title: Center(child: Text('Ticket History'))),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('history')
            .orderBy('timestamp', descending: true)  // Order by timestamp, newest first
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tickets found.'));
          }

          var tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ticket = tickets[index];
              List<dynamic> ticketIds = ticket['ticketIds'] ?? [];

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket ID: ${ticketIds.join(', ')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Bus No: ${ticket['busNo']}'),
                      Text('From: ${ticket['from']}'),
                      Text('To: ${ticket['to']}'),
                      Text('Single Price: ₹${ticket['singlePrice']}'),
                      Text('Total Price: ₹${ticket['totalPrice']}'),
                      Text('Date: ${ticket['date']}'),
                      Text('Time: ${ticket['time']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


