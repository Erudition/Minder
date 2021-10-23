"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var NaCl = org.libsodium.jni.NaCl;
var Sodium_ = NaCl.sodium();
var Sodium = org.libsodium.jni.Sodium;
var Base64 = android.util.Base64;
var StandardCharsets = java.nio.charset.StandardCharsets;
var ByteArrayOutputStream = java.io.ByteArrayOutputStream;
var ByteArrayInputStream = java.io.ByteArrayInputStream;
var Arrays = java.util.Arrays;
var System = java.lang.System;
var X509EncodedKeySpec = java.security.spec.X509EncodedKeySpec;
var PKCS8EncodedKeySpec = java.security.spec.PKCS8EncodedKeySpec;
var SecretKeySpec = javax.crypto.spec.SecretKeySpec;
var KeyFactory = java.security.KeyFactory;
var PrivateKey = java.security.PrivateKey;
var PublicKey = java.security.PublicKey;
var Security = java.security.Security;
var Signature = java.security.Signature;
var Cipher = javax.crypto.Cipher;
var BlockCipher = org.spongycastle.crypto.BlockCipher;
var KeyParameter = org.spongycastle.crypto.params.KeyParameter;
var AESEngine = org.spongycastle.crypto.engines.AESFasterEngine;
var KeyWrapEngine = org.spongycastle.crypto.engines.RFC3394WrapEngine;
var AEADParameters = org.spongycastle.crypto.params.AEADParameters;
var GCMBlockCipher = org.spongycastle.crypto.modes.GCMBlockCipher;
var NSCrypto = (function () {
    function NSCrypto() {
        this.crypto_pwhash_consts = {
            scryptsalsa208sha256: {
                mem_limits: {
                    min: 8192 * 7168 * 2,
                    max: 8192 * 9126 * 2
                },
                ops_limits: {
                    min: 768 * 1024 * 2,
                    max: 768 * 2048 * 2
                }
            },
            argon2i: {
                mem_limits: { min: 8192 * 308, max: 8192 * 436 },
                ops_limits: { min: 4, max: 6 }
            }
        };
        this._hashTypeLibsodiumNamespace = {
            sha256: 'crypto_hash_sha256',
            sha512: 'crypto_hash_sha512'
        };
        this.rsaEncPaddingType = {
            pkcs1: 'RSA/NONE/PKCS1Padding',
            oaep: 'RSA/NONE/OAEPwithSHA-1andMGF1Padding'
        };
        this.rsaSigDigestType = {
            sha1: 'SHA1withRSA',
            sha256: 'SHA256withRSA',
            sha512: 'SHA512withRSA'
        };
    }
    NSCrypto.prototype.hash = function (input, type) {
        if (Object.keys(this._hashTypeLibsodiumNamespace).indexOf(type) === -1) {
            throw new Error("hash type \"" + type + "\" not found!");
        }
        input = Base64.decode(input, Base64.DEFAULT);
        Sodium.sodium_init();
        var hash_libsodium_namespace = this._hashTypeLibsodiumNamespace[type];
        var hash = Array.create('byte', Sodium[hash_libsodium_namespace + '_bytes']());
        Sodium[hash_libsodium_namespace](hash, input, input.length);
        return Base64.encodeToString(hash, Base64.DEFAULT);
    };
    NSCrypto.prototype.secureRandomBytes = function (length) {
        Sodium.sodium_init();
        var bytes = Array.create('byte', length);
        Sodium.randombytes_buf(bytes, length);
        return Base64.encodeToString(bytes, Base64.DEFAULT);
    };
    NSCrypto.prototype.randomBytes = function (length) {
        Sodium.sodium_init();
        var bytes = Array.create('byte', length);
        Sodium.randombytes_buf(bytes, length);
//        return Base64.encodeToString(bytes, Base64.DEFAULT);
        return bytes;
    };
    NSCrypto.prototype.deriveSecureKey = function (password, key_size, salt, ops_limits, mem_limits, alg) {
        Sodium.sodium_init();
        password = new java.lang.String(password).getBytes(StandardCharsets.UTF_8);
        var _salt;
        if (salt) {
            _salt = Base64.decode(salt, Base64.DEFAULT);
        }
        alg = alg || 'argon2i';
        if (!mem_limits) {
            var diff = this.crypto_pwhash_consts[alg].mem_limits.max -
                this.crypto_pwhash_consts[alg].mem_limits.min;
            mem_limits =
                this.crypto_pwhash_consts[alg].mem_limits.min +
                    Sodium.randombytes_uniform(diff + 1);
        }
        if (!ops_limits) {
            var diff = this.crypto_pwhash_consts[alg].ops_limits.max -
                this.crypto_pwhash_consts[alg].ops_limits.min;
            ops_limits =
                this.crypto_pwhash_consts[alg].ops_limits.min +
                    Sodium.randombytes_uniform(diff + 1);
        }
        var derived_key = Array.create('byte', key_size);
        if (alg === 'scryptsalsa208sha256') {
            if (!salt) {
                _salt = Array.create('byte', Sodium.crypto_pwhash_scryptsalsa208sha256_saltbytes());
                Sodium.randombytes_buf(_salt, _salt.length);
            }
            if (Sodium.crypto_pwhash_scryptsalsa208sha256(derived_key, key_size, password, password.length, _salt, ops_limits, mem_limits) !== 0) {
                throw new Error('deriveSecureKey out of memory');
            }
        }
        else if (alg === 'argon2i') {
            if (!salt) {
                _salt = Array.create('byte', Sodium.crypto_pwhash_saltbytes());
                Sodium.randombytes_buf(_salt, _salt.length);
            }
            if (Sodium.crypto_pwhash(derived_key, key_size, password, password.length, _salt, ops_limits, mem_limits, Sodium.crypto_pwhash_alg_argon2i13()) !== 0) {
                throw new Error('deriveSecureKey out of memory');
            }
        }
        else {
            throw new Error("deriveSecureKey algorithm \"" + alg + "\" not found");
        }
        return {
            key: Base64.encodeToString(derived_key, Base64.DEFAULT),
            salt: Base64.encodeToString(_salt, Base64.DEFAULT),
            ops_limits: ops_limits,
            mem_limits: mem_limits,
            alg: alg
        };
    };
    NSCrypto.prototype.secureSymetricAEADkeyLength = function () {
        return Sodium.crypto_aead_chacha20poly1305_ietf_keybytes();
    };
    NSCrypto.prototype.secureSymetricAEADnonceLength = function () {
        return Sodium.crypto_aead_chacha20poly1305_ietf_npubbytes();
    };
    NSCrypto.prototype.encryptSecureSymetricAEAD = function (key, plainb, aad, pnonce, alg) {
        if (alg && alg !== 'chacha20poly1305_ietf') {
            throw new Error("decryptSecureSymetricAEAD algorith " + alg + " not found or is not available in this hardware");
        }
        var key_bytes = Base64.decode(key, Base64.DEFAULT);
        var plainb_bytes = Base64.decode(plainb, Base64.DEFAULT);
        var cipherb = Array.create('byte', plainb_bytes.length + Sodium.crypto_aead_chacha20poly1305_ietf_abytes());
        var clen_p = Array.create('int', 1);
        var aad_bytes = Base64.decode(aad, Base64.DEFAULT);
        var pnonce_bytes = Base64.decode(pnonce, Base64.DEFAULT);
        Sodium.crypto_aead_chacha20poly1305_ietf_encrypt(cipherb, clen_p, plainb_bytes, plainb_bytes.length, aad_bytes, aad_bytes.length, pnonce_bytes, null, key_bytes);
        return {
            cipherb: Base64.encodeToString(cipherb, Base64.DEFAULT),
            alg: 'chacha20poly1305_ietf'
        };
    };
    NSCrypto.prototype.decryptSecureSymetricAEAD = function (key, cipherb, aad, pnonce, alg) {
        if (alg && alg !== 'chacha20poly1305_ietf') {
            throw new Error("decryptSecureSymetricAEAD algorith " + alg + " not found or is not available in this hardware");
        }
        var key_bytes = Base64.decode(key, Base64.DEFAULT);
        var cipherb_bytes = Base64.decode(cipherb, Base64.DEFAULT);
        var plaint_bytes = Array.create('byte', cipherb_bytes.length - Sodium.crypto_aead_chacha20poly1305_ietf_abytes());
        var mlen_p = Array.create('int', 1);
        var aad_bytes = new java.lang.String(aad).getBytes(StandardCharsets.UTF_8);
        var pnonce_bytes = Base64.decode(pnonce, Base64.DEFAULT);
        Sodium.crypto_aead_chacha20poly1305_ietf_decrypt(plaint_bytes, mlen_p, cipherb_bytes, cipherb_bytes.length, aad_bytes, aad_bytes.length, pnonce_bytes, null, key_bytes);
        return Base64.encodeToString(plaint_bytes, Base64.DEFAULT);
    };
    NSCrypto.prototype.initSpongyCastle = function () {
        if (java.security.Security.getProvider('SC') == null) {
            java.security.Security.addProvider(new org.spongycastle.jce.provider.BouncyCastleProvider());
        }
    };
    NSCrypto.prototype.hasServiceProvider = function (service, provider) {
        var _provider = java.security.Security.getProvider(provider);
        if (provider != null) {
            if (_provider.getService('Cipher', service) != null)
                return true;
        }
        return false;
    };
    NSCrypto.prototype.encryptAES256GCM = function (key, plaint, aad, iv, tagLength) {
        if (tagLength === void 0) { tagLength = 128; }
        var key_bytes = Base64.decode(key, Base64.DEFAULT);
        var plaint_bytes = Base64.decode(plaint, Base64.DEFAULT);
        var aad_bytes = Base64.decode(aad, Base64.DEFAULT);
        var iv_bytes = Base64.decode(iv, Base64.DEFAULT);
        var cipher = new GCMBlockCipher(new AESEngine());
        cipher.init(true, new AEADParameters(new KeyParameter(key_bytes), tagLength, iv_bytes, aad_bytes));
        var cipherb = Array.create('byte', cipher.getOutputSize(plaint_bytes.length));
        var outputLen = cipher.processBytes(plaint_bytes, 0, plaint_bytes.length, cipherb, 0);
        cipher.doFinal(cipherb, outputLen);
        var tagb = Arrays.copyOfRange(cipherb, cipherb.length - tagLength / 8, cipherb.length);
        cipherb = Arrays.copyOfRange(cipherb, 0, cipherb.length - tagLength / 8);
        return {
            cipherb: Base64.encodeToString(cipherb, Base64.DEFAULT),
            atag: Base64.encodeToString(tagb, Base64.DEFAULT)
        };
    };
    NSCrypto.prototype.decryptAES256GCM = function (key, cipherb, aad, iv, atag) {
        var key_bytes = Base64.decode(key, Base64.DEFAULT);
        var cipherb_bytes = Base64.decode(cipherb, Base64.DEFAULT);
        var aad_bytes = Base64.decode(aad, Base64.DEFAULT);
        var iv_bytes = Base64.decode(iv, Base64.DEFAULT);
        var atag_bytes = Base64.decode(atag, Base64.DEFAULT);
        var cipherb_bytes_complete = Array.create('byte', cipherb_bytes.length + atag_bytes.length);
        System.arraycopy(cipherb_bytes, 0, cipherb_bytes_complete, 0, cipherb_bytes.length);
        System.arraycopy(atag_bytes, 0, cipherb_bytes_complete, cipherb_bytes.length, atag_bytes.length);
        var cipher = new GCMBlockCipher(new AESEngine());
        cipher.init(false, new AEADParameters(new KeyParameter(key_bytes), atag_bytes.length * 8, iv_bytes, aad_bytes));
        var plainb_bytes = Array.create('byte', cipher.getOutputSize(cipherb_bytes_complete.length));
        var outputLen = cipher.processBytes(cipherb_bytes_complete, 0, cipherb_bytes_complete.length, plainb_bytes, 0);
        cipher.doFinal(plainb_bytes, outputLen);
        return Base64.encodeToString(plainb_bytes, Base64.DEFAULT);
    };
    NSCrypto.prototype.encryptRSA = function (pub_key_pem, plainb, padding) {
        pub_key_pem = pub_key_pem.replace('-----BEGIN PUBLIC KEY-----\n', '');
        pub_key_pem = pub_key_pem.replace('-----END PUBLIC KEY-----', '');
        var publicKeyBytes = Base64.decode(pub_key_pem, Base64.DEFAULT);
        var keySpec = new X509EncodedKeySpec(publicKeyBytes);
        var keyFactory = KeyFactory.getInstance('RSA');
        var pubKey = keyFactory.generatePublic(keySpec);
        var cipher = Cipher.getInstance(this.rsaEncPaddingType[padding]);
        cipher.init(Cipher.ENCRYPT_MODE, pubKey);
        var encrypted = cipher.doFinal(Base64.decode(plainb, Base64.DEFAULT));
        return Base64.encodeToString(encrypted, Base64.DEFAULT);
    };
    NSCrypto.prototype.decryptRSA = function (priv_key_pem, cipherb, padding) {
        priv_key_pem = priv_key_pem.replace('-----BEGIN RSA PRIVATE KEY-----\n', '');
        priv_key_pem = priv_key_pem.replace('-----END RSA PRIVATE KEY-----', '');
        var privateKeyBytes = Base64.decode(priv_key_pem, Base64.DEFAULT);
        var keySpec = new PKCS8EncodedKeySpec(privateKeyBytes);
        var keyFactory = KeyFactory.getInstance('RSA');
        var privKey = keyFactory.generatePrivate(keySpec);
        var cipher = Cipher.getInstance(this.rsaEncPaddingType[padding]);
        cipher.init(Cipher.DECRYPT_MODE, privKey);
        var paintb = cipher.doFinal(Base64.decode(cipherb, Base64.DEFAULT));
        return Base64.encodeToString(paintb, Base64.DEFAULT);
    };
    NSCrypto.prototype.signRSA = function (priv_key_pem, messageb, digest_type) {
        priv_key_pem = priv_key_pem.replace('-----BEGIN RSA PRIVATE KEY-----\n', '');
        priv_key_pem = priv_key_pem.replace('-----END RSA PRIVATE KEY-----', '');
        var privateKeyBytes = Base64.decode(priv_key_pem, Base64.DEFAULT);
        var keySpec = new PKCS8EncodedKeySpec(privateKeyBytes);
        var keyFactory = KeyFactory.getInstance('RSA');
        var privKey = keyFactory.generatePrivate(keySpec);
        var signature = Signature.getInstance(this.rsaSigDigestType[digest_type]);
        signature.initSign(privKey);
        signature.update(Base64.decode(messageb, Base64.DEFAULT));
        var signatureBytes = signature.sign();
        return Base64.encodeToString(signatureBytes, Base64.DEFAULT);
    };
    NSCrypto.prototype.verifyRSA = function (pub_key_pem, messageb, signatureb, digest_type) {
        pub_key_pem = pub_key_pem.replace('-----BEGIN PUBLIC KEY-----\n', '');
        pub_key_pem = pub_key_pem.replace('-----END PUBLIC KEY-----', '');
        var publicKeyBytes = Base64.decode(pub_key_pem, Base64.DEFAULT);
        var keySpec = new X509EncodedKeySpec(publicKeyBytes);
        var keyFactory = KeyFactory.getInstance('RSA');
        var pubKey = keyFactory.generatePublic(keySpec);
        var signature = Signature.getInstance(this.rsaSigDigestType[digest_type]);
        signature.initVerify(pubKey);
        signature.update(Base64.decode(messageb, Base64.DEFAULT));
        return signature.verify(Base64.decode(signatureb, Base64.DEFAULT));
    };
    NSCrypto.prototype.deflate = function (input) {
        var data = Base64.decode(input, Base64.DEFAULT);
        var output = Array.create('byte', data.length);
        var compresser = new java.util.zip.Deflater();
        compresser.setInput(data, 0, data.length);
        compresser.finish();
        var compressedDataLength = compresser.deflate(output);
        compresser.end();
        output = Arrays.copyOf(output, compressedDataLength);
        return Base64.encodeToString(output, Base64.DEFAULT);
    };
    NSCrypto.prototype.inflate = function (input) {
        var data = Base64.decode(input, Base64.DEFAULT);
        var decompresser = new java.util.zip.Inflater();
        decompresser.setInput(data, 0, data.length);
        var output = Array.create('byte', data.length * 20);
        var decompressedDataLength = decompresser.inflate(output);
        decompresser.end();
        output = Arrays.copyOf(output, decompressedDataLength);
        return Base64.encodeToString(output, Base64.DEFAULT);
    };
    NSCrypto.prototype.base64encode = function (input) {
        input = new java.lang.String(input).getBytes(StandardCharsets.UTF_8);
        return Base64.encodeToString(input, Base64.DEFAULT);
    };
    NSCrypto.prototype.base64decode = function (input) {
        var data = Base64.decode(input, Base64.DEFAULT);
        return new java.lang.String(data, StandardCharsets.UTF_8);
    };
    NSCrypto.prototype.randomUUID = function () {
        return java.util.UUID.randomUUID().toString();
    };
    NSCrypto.prototype.keyWrapAES = function (wrappingKey, key) {
        var wrappingKey_bytes = Base64.decode(wrappingKey, Base64.DEFAULT);
        var key_bytes = Base64.decode(key, Base64.DEFAULT);
        var cipher = new KeyWrapEngine(new AESEngine());
        cipher.init(true, new KeyParameter(wrappingKey_bytes));
        var wrappedkey_bytes = cipher.wrap(key_bytes, 0, key_bytes.length);
        return Base64.encodeToString(wrappedkey_bytes, Base64.DEFAULT);
    };
    NSCrypto.prototype.keyUnWrapAES = function (unwrappingKey, wrappedkey) {
        var unwrappingKey_bytes = Base64.decode(unwrappingKey, Base64.DEFAULT);
        var wrappedkey_bytes = Base64.decode(wrappedkey, Base64.DEFAULT);
        var cipher = new KeyWrapEngine(new AESEngine());
        cipher.init(false, new KeyParameter(unwrappingKey_bytes));
        var key = cipher.unwrap(wrappedkey_bytes, 0, wrappedkey_bytes.length);
        return Base64.encodeToString(key, Base64.DEFAULT);
    };
    NSCrypto.prototype.constants = {
               'DH_CHECK_P_NOT_SAFE_PRIME': 2,
               'DH_CHECK_P_NOT_PRIME': 1,
               'DH_UNABLE_TO_CHECK_GENERATOR': 4,
               'DH_NOT_SUITABLE_GENERATOR': 8,
               'NPN_ENABLED': 1,
               'ALPN_ENABLED': 1,
               'RSA_PKCS1_PADDING': 1,
               'RSA_SSLV23_PADDING': 2,
               'RSA_NO_PADDING': 3,
               'RSA_PKCS1_OAEP_PADDING': 4,
               'RSA_X931_PADDING': 5,
               'RSA_PKCS1_PSS_PADDING': 6,
               'POINT_CONVERSION_COMPRESSED': 2,
               'POINT_CONVERSION_UNCOMPRESSED': 4,
               'POINT_CONVERSION_HYBRID': 6
             };
    return NSCrypto;
}());
exports.NSCrypto = NSCrypto;



//# sourceMappingURL=crypto.android.js.map
