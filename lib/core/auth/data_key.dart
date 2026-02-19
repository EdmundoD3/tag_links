class DataKey {
  final String ciphertext;
  final String nonce;
  final String mac;
  final String salt;

  DataKey({required this.ciphertext, required this.nonce, required this.mac, required this.salt});
  
}