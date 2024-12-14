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

    _fetchPlaces();  
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
          title: Text('Ticket Details'),
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
                      decoration: InputDecoration(labelText: 'Ticket Quantity'),
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
                ),
                child: Text('Payment Successful'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
