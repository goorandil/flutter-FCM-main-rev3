import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final String? message;

  HomePage({Key? key, this.message}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  ///  start new code
  Future<String> futureString =
      fetchString(); // Replace with your Future<String> source

  String textToCopy = "";

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Text copied to clipboard'),
    ));
  }

  /// end new code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You will receive notification',
            ),
            SizedBox(
              height: 10,
            ),

            /// start new code
            FutureBuilder<String>(
                future: futureString,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While the Future is waiting, display a loading indicator or message.
                    return CircularProgressIndicator(); // You can use a CircularProgressIndicator or any other widget.
                  } else if (snapshot.hasError) {
                    // Handle errors here if the Future completes with an error.
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    // If the Future has successfully completed, display the string in a Text widget.
                    return GestureDetector(
                        onTap: () {
                          textToCopy = snapshot.data!;
                          _copyToClipboard(context);
                        },
                        child: Text(snapshot.data!));
                  } else {
                    // Handle other cases here.
                    return Text('No data');
                  }
                }),

            /// end new code
          ],
        ),
      ),
    );
  }
}

/// start new code
Future<String> fetchString() async {
  // Simulated asynchronous operation, replace with your actual logic
  final fcmToken = await FirebaseMessaging.instance.getToken();

  return Future.delayed(Duration(seconds: 3), () {
    print('fcmToken $fcmToken');
    return "$fcmToken";
  });
}
/// end new code