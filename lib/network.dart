import 'package:http/http.dart' as http;


void sendRecord(double amount, String note, String categoryStr, int timestamp) async {

  var url = "http://96b03e19.ngrok.io/api/v1/add_record";
  print("sendRecord...");
  http.post(url, body: {"amount": amount.toString(), "note": note, "category": categoryStr, "timestamp":timestamp.toString()})
      .then((response) {
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
  });
}