import 'package:http/http.dart' as http;
import 'dart:convert';

String createSubscriptionUrl(String topicArn, String endpoint) {
  // Replace 'your_access_key' and 'your_secret_key' with your AWS credentials
  String accessKey = 'your_access_key';
  String secretKey = 'your_secret_key';
  String region = 'us-east-1'; // Replace with your AWS region
  String service = 'sns';

  String urlString = 'https://sns.$region.amazonaws.com/';
  String action = 'Subscribe';
  String protocol = 'https'; // Adjust protocol as needed
  String parameters =
      'Action=$action&TopicArn=$topicArn&Protocol=$protocol&Endpoint=$endpoint';

  // Construct the canonical query string
  String canonicalQueryString = Uri.encodeComponent(parameters);

  // The actual signing process would be here. For now, we'll just use the canonical query string.

  // Construct the final URL
  String finalUrl = '$urlString?$canonicalQueryString';

  return finalUrl;
}
