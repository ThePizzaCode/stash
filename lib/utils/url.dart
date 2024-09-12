const dev = false;

const apiURL = dev ? 'http://localhost:6000' : 'https://stocard.blitzapp.ro';

const Map<String, String> basicHeader = <String, String>{
  'Content-Type': 'application/json',
};

Map<String, String> authHeader(String token) {
  return <String, String>{
    'ContentType': 'application/json',
    'Authorization': 'Bearer $token',
  };
}