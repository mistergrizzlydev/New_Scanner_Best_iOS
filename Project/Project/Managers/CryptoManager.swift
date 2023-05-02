import CommonCrypto
import Foundation
import Security

//enum SecurityError: Error {
//  case PublicKeyCopyError
//  case EncryptionFailedError(_ status: CCCryptorStatus)
//  case DigestFailedError
//  case EncryptionLengthError
//  case EncryptionKeyLengthError
//  case UnexpectedNilKeys
//  case NonceCopyError
//}
//
//class Crypto {
//  private static var cachedExportPublicKey: Data?
//  private static var cachedAesKey: Data?
//  private static var cachedMacKey: Data?
//  private static var keyGenTime: Int64 = Int64.min
//  private static var counter: UInt16 = 0
//  private static let NONCE_PADDING: Data = Data([UInt8](repeating: UInt8(0x0E), count: 14))
//  private static let keyCacheQueue = DispatchQueue(label: "au.gov.health.covidsafe.crypto")
//  private static let KEY_GEN_TIME_DELTA: Int64 = 450  // 7.5 minutes
//#if DEBUG
//  private static let publicKey = Data(base64Encoded: "BNrAcR+C6nkCpIYS9KWYt0Z5Sbleh7UybHmIT2T9YzuR9RzTh3YZcMBjr1K6smeDJW7sPCvMFJNWVPkk3exqjkQ=")
//#else
//  private static let publicKey = Data(base64Encoded: "BDQbOM4lxeK6ed9br26qvcwsYgaUK9w3CozIHP1gOhR7+qwb7vrh0kSSUUtsayekard9EHElA9RNn/3dJW9hr7I=")
//#endif
//
//  /**
//   Get a series of secrets that can be decrypted by the server key. The returned data is:
//   1. the ephemeral key used for decrypting
//   2. the AES encryption key
//   3. the HMAC signature key
//   4. the IV for AES encryption
//   - Parameter serverKey: X9.63  formatted P-256 key for the server
//   - Throws: Errors from Security framework, or `SecurityError.PublicKeyCopyError`
//   if function failed to derive key from the ephemeral private key
//   - Returns:
//   - publicKey: exported P-256 key (compressed form)
//   - aesKey: ephemeral 16-byte AES-128 key
//   - macKey: ephemeral 16-byte key for HMAC
//   - iv: ephemeral 16-byte AES-128 IV
//   */
//  private static func getEphemeralSecrets(_ serverKey: Data) throws -> (publicKey: Data, aesKey: Data, macKey: Data) {
//    // Server key
//    var err: Unmanaged<CFError>?
//    let serverKeyOptions: [CFString: Any] = [
//      kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
//      kSecAttrKeySizeInBits: 256,
//      kSecAttrKeyClass: kSecAttrKeyClassPublic,
//    ]
//    guard let serverPublicKey = SecKeyCreateWithData(serverKey as CFData, serverKeyOptions as CFDictionary, &err) else {
//      throw err!.takeRetainedValue() as Error
//    }
//
//    // CREATE A LOCAL EPHEMERAL P-256 KEYPAIR
//    let ephemeralPublicKeyAttributes: [CFString: Any] = [
//      kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
//      kSecAttrKeySizeInBits: 256,
//    ]
//
//    guard let ephemeralPrivateKey = SecKeyCreateRandomKey(ephemeralPublicKeyAttributes as CFDictionary, &err) else {
//      throw err!.takeRetainedValue() as Error
//    }
//    guard let ephemeralPublicKey = SecKeyCopyPublicKey(ephemeralPrivateKey) else {
//      throw SecurityError.PublicKeyCopyError
//    }
//
//    // Exported ephemeral key for sending/MACing later (compressed format, per ANSI X9.62)
//    let exportPublicKey = try ephemeralPublicKey.CopyCompressedECPublicKey()
//
//    // COMPUTE SHARED SECRET
//    let params = [SecKeyKeyExchangeParameter.requestedSize.rawValue: 32]
//    guard let sharedSecret = SecKeyCopyKeyExchangeResult(ephemeralPrivateKey,
//                                                         SecKeyAlgorithm.ecdhKeyExchangeStandard,
//                                                         serverPublicKey,
//                                                         params as CFDictionary,
//                                                         &err) as Data? else {
//      throw err!.takeRetainedValue() as Error
//    }
//
//    // KDF THE SHARED SECRET TO GET ENC KEY, MAC KEY
//    var keysHashCtx = CC_SHA256_CTX()
//
//    // For keys we'll be using SHA256(sharedSecret)
//    var res: Int32
//    var keysHashValue = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
//    CC_SHA256_Init(&keysHashCtx)
//    res = sharedSecret.withUnsafeBytes {
//      return CC_SHA256_Update(&keysHashCtx, $0.baseAddress, CC_LONG(sharedSecret.count))
//    }
//    guard res == 1 else { throw SecurityError.DigestFailedError }
//    res = keysHashValue.withUnsafeMutableBytes {
//      return CC_SHA256_Final($0.bindMemory(to: UInt8.self).baseAddress, &keysHashCtx)
//    }
//    guard res == 1 else { throw SecurityError.DigestFailedError }
//
//    // Form the keys
//    let aesKey = keysHashValue[..<kCCKeySizeAES128]
//    let macKey = keysHashValue[kCCKeySizeAES128...]
//
//    // At return, the refs to ephemeralPrivateKey and sharedSecret will be dropped and they will be cleared
//    return (exportPublicKey, aesKey, macKey)
//  }
//
//  static func buildSecretData(_ serverPublicKey: Data, _ plaintext: Data) throws -> Data {
//    let (cachedExportPublicKey, cachedAESKey, cachedMacKey, nonce) = try keyCacheQueue.sync { () -> (Data?, Data?, Data?, Data) in
//      if Crypto.keyGenTime <= Int64(Date().timeIntervalSince1970) - KEY_GEN_TIME_DELTA || Crypto.counter >= 255 {
//        (Crypto.cachedExportPublicKey, Crypto.cachedAesKey, Crypto.cachedMacKey) = try getEphemeralSecrets(serverPublicKey)
//        Crypto.keyGenTime = Int64(Date().timeIntervalSince1970)
//        Crypto.counter = 0
//      } else {
//        Crypto.counter += 1
//      }
//      var nonce = [UInt8](repeating: 0, count: 2)
//      let status = SecRandomCopyBytes(kSecRandomDefault, nonce.count, &nonce)
//      guard status == errSecSuccess else { throw SecurityError.NonceCopyError }
//      return (Crypto.cachedExportPublicKey, Crypto.cachedAesKey, Crypto.cachedMacKey, Data(nonce))
//
//    }
//    guard let exportPublicKey = cachedExportPublicKey, let aesKey = cachedAESKey, let macKey = cachedMacKey else {
//      throw SecurityError.UnexpectedNilKeys
//    }
//
//
//    // AES ENCRYPT DATA
//    // IV = AES(ctr, iv=null), AES(plaintext, iv=IV) === AES(ctr_with_padding || plaintext, iv=null)
//    // Using the latter construction to reduce key expansions
//
//    // Under PKCS#7 padding, we pad out to a complete blocksize but if the input is an exact multiple of blocksize,
//    // then we add an extra block on. So in both cases it's 16 bytes + (dataLen/16 + 1) * 16 bytes long
//    let outputLen = ((plaintext.count / kCCBlockSizeAES128) + 2) * kCCBlockSizeAES128
//
//    let nullIV = Data(count: 16)
//    var plaintextWithIV = Data(capacity: plaintext.count + 16)
//    plaintextWithIV.append(nonce)
//    plaintextWithIV.append(NONCE_PADDING)
//    plaintextWithIV.append(plaintext)
//
//    var ciphertextWithIV = Data(count: outputLen)
//    var dataWrittenLen = 0
//    let status = ciphertextWithIV.withUnsafeMutableBytes { ciphertextPtr in
//      plaintextWithIV.withUnsafeBytes { plaintextPtr in
//        nullIV.withUnsafeBytes { ivPtr in
//          aesKey.withUnsafeBytes { aesKeyPtr in
//            return CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding),
//                           aesKeyPtr.baseAddress, kCCKeySizeAES128, ivPtr.baseAddress,
//                           plaintextPtr.baseAddress, plaintextWithIV.count,
//                           ciphertextPtr.baseAddress, outputLen,
//                           &dataWrittenLen)
//          }
//        }
//      }
//    }
//    guard status == kCCSuccess else {
//      throw SecurityError.EncryptionFailedError(status)
//    }
//    guard outputLen == dataWrittenLen else {
//      throw SecurityError.EncryptionLengthError
//    }
//
//    let ciphertext = ciphertextWithIV[16...]
//
//    // HMAC
//    var macValue = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
//    var hmacContext = CCHmacContext()
//    macKey.withUnsafeBytes { CCHmacInit(&hmacContext, CCHmacAlgorithm(kCCHmacAlgSHA256), $0.baseAddress, macKey.count) }
//    exportPublicKey.withUnsafeBytes { CCHmacUpdate(&hmacContext, $0.baseAddress, exportPublicKey.count) }
//    nonce.withUnsafeBytes { CCHmacUpdate(&hmacContext, $0.baseAddress, nonce.count) }
//    ciphertext.withUnsafeBytes { CCHmacUpdate(&hmacContext, $0.baseAddress, ciphertext.count) }
//    macValue.withUnsafeMutableBytes { CCHmacFinal(&hmacContext, $0.bindMemory(to: UInt8.self).baseAddress) }
//
//    // Build the final payload: ephemeral key || nonce || encrypted data || HMAC
//    var finalData = Data(capacity: exportPublicKey.count + ciphertext.count + 18)
//    finalData.append(exportPublicKey)
//    finalData.append(nonce)
//    finalData.append(ciphertext)
//    finalData.append(macValue[..<16])
//
//    return finalData
//  }
//
//  static func encrypt(dataToEncrypt: Data) throws -> String {
//    guard let publicKey = publicKey else {
//      throw SecurityError.PublicKeyCopyError
//    }
//    let encryptedData = try buildSecretData(publicKey, dataToEncrypt)
//    return encryptedData.base64EncodedString()
//  }
//}
//
//
//extension SecKey {
//  enum SecKeyError: Error {
//    case UnableToInspectAttributesError
//    case UnsupportedKeyTypeError
//    case InvalidUncompressedRepresentationError
//  }
//
//  /**
//   Copy the compressed elliptic-curve key representation as defined in
//   section 4.3.6 of ANSI X9.62.
//
//   - Throws:
//   - `SecKeyError.UnableToInspectAttributesError`: if `SecKeyCopyAttributes()` fails on the key
//   - `SecKeyError.UnsupportedKeyTypeError`: if the key isn't of type `kSecAttrKeyTypeECSECPrimeRandom`
//   - `SecKeyError.InvalidUncompressedRepresentationError`: if parsing the uncompressed representation
//   of the key failed (from `SecKeyCopyExternalRepresentation()`)
//
//   - Returns: Data with 1 + key size bytes, representing the key
//   */
//  func CopyCompressedECPublicKey() throws -> Data {
//    // Validate the key is of EC type
//    guard let attributes = SecKeyCopyAttributes(self) as? [CFString: AnyObject] else {
//      throw SecKeyError.UnableToInspectAttributesError
//    }
//    guard attributes[kSecAttrKeyType] as! CFNumber == kSecAttrKeyTypeECSECPrimeRandom else {
//      throw SecKeyError.UnsupportedKeyTypeError
//    }
//    // Get key size in bytes
//    let keySize = Int(truncating: attributes[kSecAttrKeySizeInBits] as! CFNumber) / 8
//
//    // Get the uncompressed key representation
//    var err: Unmanaged<CFError>?
//    guard let uncompressed = SecKeyCopyExternalRepresentation(self, &err) as Data? else {
//      throw err!.takeRetainedValue() as Error
//    }
//    // Uncompressed begins with 0x04 per section 4.3.6 of X9.62
//    guard uncompressed[0] == 4 else {
//      throw SecKeyError.InvalidUncompressedRepresentationError
//    }
//    // Uncompressed key will be 1 + keysize * 2, private has K appended to public
//    guard uncompressed.count >= 1 + keySize * 2 else {
//      throw SecKeyError.InvalidUncompressedRepresentationError
//    }
//
//    // To compress, take the X coordinate
//    let x = uncompressed[1...keySize]
//    // And determine whether Y coordinate is odd or even
//    let y_lsb = uncompressed[keySize*2] & 1
//
//    // Compressed format is PC || X_1
//    var compressed = Data(capacity: 1 + keySize)
//    // PC: 0x02 if even, 0x03 if odd
//    compressed.append(2 | y_lsb)
//    compressed.append(x)
//
//    return compressed
//  }
//}

enum EncryptionError: Error {
  case key(String = "Invalid key length")
  case iv(String = "Invalid iv length")
  case statusCode(String = "Crypt status code unsuccessful")
  case data(String = "Invalid decryption/encryption data")
}

class AESCrypter {
  private let validKeyLengths = [kCCKeySizeAES128,
                                 kCCKeySizeAES192,
                                 kCCKeySizeAES256]
  private let ivSize = kCCBlockSizeAES128
  private let options = CCOptions(kCCOptionPKCS7Padding)
  private let algorithm = CCAlgorithm(kCCAlgorithmAES)
  private let key: Data
  
  init(key: Data) {
    self.key = key
  }
  
  func encrypt(data: Data) throws -> Data {
    let keyLength = try validated()
    let cryptLength = size_t(ivSize + data.count + ivSize)
    var cryptData = Data(count: cryptLength)
    let status = cryptData.withUnsafeMutableBytes { ivBytes in
      SecRandomCopyBytes(kSecRandomDefault, ivSize, ivBytes)
    }
    if status != 0 {
      throw EncryptionError.iv()
    }
    var numBytesEncrypted: size_t = 0
    let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
      data.withUnsafeBytes { dataBytes in
        key.withUnsafeBytes { keyBytes in
          CCCrypt(CCOperation(kCCEncrypt),
                  algorithm,
                  options,
                  keyBytes,
                  keyLength,
                  cryptBytes,
                  dataBytes,
                  data.count,
                  (cryptBytes + ivSize),
                  cryptLength,
                  &numBytesEncrypted)
        }
      }
    }
    if Int(cryptStatus) == kCCSuccess {
      cryptData.count = numBytesEncrypted + ivSize
    } else {
      throw EncryptionError.statusCode()
    }
    return cryptData;
  }
  
  func decrypt(data: Data) throws -> Data {
    let keyLength = try validated()
    let clearLength = size_t(data.count - ivSize)
    guard clearLength >= 0 else {
      throw EncryptionError.data()
    }
    var clearData = Data(count: clearLength)
    var numBytesDecrypted: size_t = 0
    let cryptStatus = clearData.withUnsafeMutableBytes { cryptBytes in
      data.withUnsafeBytes { dataBytes in
        key.withUnsafeBytes { keyBytes in
          CCCrypt(CCOperation(kCCDecrypt),
                  algorithm,
                  options,
                  keyBytes,
                  keyLength,
                  dataBytes,
                  (dataBytes + ivSize),
                  clearLength,
                  cryptBytes,
                  clearLength,
                  &numBytesDecrypted)
        }
      }
    }
    if Int(cryptStatus) == kCCSuccess {
      clearData.count = numBytesDecrypted
    }
    else {
      throw EncryptionError.statusCode()
    }
    return clearData;
  }
  
  private func validated() throws -> Int {
    let keyLength = key.count
    if (validKeyLengths.contains(keyLength) == false) {
      throw EncryptionError.key()
    }
    return keyLength
  }
}

extension String {
  func encrypted(with key: String) throws -> Data {
    guard let keyData = key.data(using: .utf8) else {
      throw EncryptionError.key()
    }
    guard let data = self.data(using: .utf8) else {
      throw EncryptionError.data()
    }
    do {
      let crypter = AESCrypter(key: keyData)
      return try crypter.encrypt(data: data)
    } catch let error {
      throw error
    }
  }
  
  func decrypted(with key: String) throws -> String  {
    guard let keyData = key.data(using: .utf8) else {
      throw EncryptionError.key()
    }
    guard let data = self.data(using: .utf8) else {
      throw EncryptionError.data()
    }
    do {
      let crypter = AESCrypter(key: keyData)
      guard let decrypted = try crypter.decrypt(data: data).string else {
        throw EncryptionError.statusCode()
      }
      return decrypted
    } catch let error {
      throw error
    }
  }
}

extension Data {
  var hex: String {
    return self.reduce("", { $0 + String(format: "%02x", $1) })
  }
  var string: String? {
    return String(bytes: self, encoding: .utf8)
  }
}

//import Foundation
//import CommonCrypto
//
//extension String {
////  let key = "0123456789abcdef" // 128-bit key in hexadecimal format
////  let iv = "1234567890abcdef" // 128-bit initialization vector in hexadecimal format
//
//  func encrypt(data: Data, key: String = "0123456789abcdef", iv: String = "1234567890abcdef") throws -> Data {
//      let dataLength = data.count
//      let bufferSize = dataLength + kCCBlockSizeAES128
//      var buffer = [UInt8](repeating: 0, count: bufferSize)
//      var numBytesEncrypted = 0
//
//      let cryptStatus = key.withCString { keyPtr in
//          iv.withCString { ivPtr in
//              data.withUnsafeBytes { dataPtr in
//                  CCCrypt(CCOperation(kCCEncrypt),
//                          CCAlgorithm(kCCAlgorithmAES),
//                          CCOptions(kCCOptionPKCS7Padding),
//                          keyPtr, kCCBlockSizeAES128,
//                          ivPtr,
//                          dataPtr.baseAddress, dataLength,
//                          &buffer, bufferSize,
//                          &numBytesEncrypted)
//              }
//          }
//      }
//
//      guard cryptStatus == kCCSuccess else {
//          throw NSError(domain: "Encryption error", code: Int(cryptStatus), userInfo: nil)
//      }
//
//      return Data(bytes: buffer, count: numBytesEncrypted)
//  }
//
//  func decrypt(data: Data, key: String = "0123456789abcdef", iv: String = "1234567890abcdef") throws -> Data {
//      let dataLength = data.count
//      let bufferSize = dataLength + kCCBlockSizeAES128
//      var buffer = [UInt8](repeating: 0, count: bufferSize)
//      var numBytesDecrypted = 0
//
//      let cryptStatus = key.withCString { keyPtr in
//          iv.withCString { ivPtr in
//              data.withUnsafeBytes { dataPtr in
//                  CCCrypt(CCOperation(kCCDecrypt),
//                          CCAlgorithm(kCCAlgorithmAES),
//                          CCOptions(kCCOptionPKCS7Padding),
//                          keyPtr, kCCBlockSizeAES128,
//                          ivPtr,
//                          dataPtr.baseAddress, dataLength,
//                          &buffer, bufferSize,
//                          &numBytesDecrypted)
//              }
//          }
//      }
//
//      guard cryptStatus == kCCSuccess else {
//          throw NSError(domain: "Decryption error", code: Int(cryptStatus), userInfo: nil)
//      }
//
//      return Data(bytes: buffer, count: numBytesDecrypted)
//  }
//
//}


import Foundation
import CommonCrypto

final class CryptoManager {
  private let key: String
  private let iv: String
  
  static let `default` = CryptoManager()
  
  private init() {
    self.key = "o6MGa+ZrakJxKX8X2a57ybxoDwkxsMh60PZY8K+7q3Kr3twu2FZazJWnXe7nRxay" //"0123456789abcdef"
    self.iv = "0GzjOJcSiunnfW9vR69y3AqMyBwOFHvqsG+76HSRJJRSlNrnJ6Rp3wQcSUMUTf/d0lb2Gvsg==" //"1234567890abcdef"
  }
  
  func encrypt(data: Data) throws -> Data {
    let dataLength = data.count
    let bufferSize = dataLength + kCCBlockSizeAES128
    var buffer = [UInt8](repeating: 0, count: bufferSize)
    var numBytesEncrypted = 0
    
    let cryptStatus = key.withCString { keyPtr in
      iv.withCString { ivPtr in
        data.withUnsafeBytes { dataPtr in
          CCCrypt(CCOperation(kCCEncrypt),
                  CCAlgorithm(kCCAlgorithmAES),
                  CCOptions(kCCOptionPKCS7Padding),
                  keyPtr, kCCBlockSizeAES128,
                  ivPtr,
                  dataPtr.baseAddress, dataLength,
                  &buffer, bufferSize,
                  &numBytesEncrypted)
        }
      }
    }
    
    guard cryptStatus == kCCSuccess else {
      throw NSError(domain: "Encryption error", code: Int(cryptStatus), userInfo: nil)
    }
    
    return Data(bytes: buffer, count: numBytesEncrypted)
  }
  
  func decrypt(data: Data) throws -> Data {
    let dataLength = data.count
    let bufferSize = dataLength + kCCBlockSizeAES128
    var buffer = [UInt8](repeating: 0, count: bufferSize)
    var numBytesDecrypted = 0
    
    let cryptStatus = key.withCString { keyPtr in
      iv.withCString { ivPtr in
        data.withUnsafeBytes { dataPtr in
          CCCrypt(CCOperation(kCCDecrypt),
                  CCAlgorithm(kCCAlgorithmAES),
                  CCOptions(kCCOptionPKCS7Padding),
                  keyPtr, kCCBlockSizeAES128,
                  ivPtr,
                  dataPtr.baseAddress, dataLength,
                  &buffer, bufferSize,
                  &numBytesDecrypted)
        }
      }
    }
    
    guard cryptStatus == kCCSuccess else {
      throw NSError(domain: "Decryption error", code: Int(cryptStatus), userInfo: nil)
    }
    
    return Data(bytes: buffer, count: numBytesDecrypted)
  }
}

extension String {
  func encrypt() throws -> String {
    guard let data = self.data(using: .utf8) else {
      throw NSError(domain: "Encryption error", code: 0, userInfo: nil)
    }
    
    let encryptedData = try CryptoManager.default.encrypt(data: data)
    return encryptedData.base64EncodedString()
  }
  
  func decrypt() throws -> String {
    guard let data = Data(base64Encoded: self) else {
      throw NSError(domain: "Decryption error", code: 0, userInfo: nil)
    }
    
    let decryptedData = try CryptoManager.default.decrypt(data: data)
    guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
      throw NSError(domain: "Decryption error", code: 0, userInfo: nil)
    }
    return decryptedString
  }
}

extension String {
  var encrypted: String {
    let result = try? encrypt()
    return result ?? ""
  }
  
  var decrypted: String {
    let result = try? decrypt()
    return result ?? ""
  }
}

extension String {
  var isValidEmail: Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: self)
  }
}
