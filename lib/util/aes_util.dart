
import 'package:encrypt/encrypt.dart';

class AESUtil{
static final String SHARE_TAG = "@LWX6WG@";
static final String _KEY_STR = "Irj9WBX7aOr1J5KpBbXEzwMqlSnn95Av";
static final Key _KEY = Key.fromUtf8(_KEY_STR);
static final IV _IV = IV.fromLength(16);

static final _encrypter = Encrypter(AES(_KEY));


static String encrypt(String plainText) =>_encrypter.encrypt(plainText,iv: _IV).base64;
static String decrypt(String encrypted) =>_encrypter.decrypt(Encrypted.from64(encrypted),iv: _IV);
}