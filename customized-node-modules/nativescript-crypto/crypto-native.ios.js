"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var toBase64 = function (input, length) {
    var data = NSData.dataWithBytesLength(input, length);
    var base64 = data.base64EncodedStringWithOptions(0);
    return base64;
};
var base64toBytes = function (input) {
    var input_data = new NSData({ base64Encoding: input });
    var _input_length = input_data.length;
    var _input = interop.alloc(_input_length * interop.sizeof(interop.types.unichar));
    input_data.getBytes(_input);
    return { bytes: _input, length: _input_length };
};
var NSCrypto = (function () {
    function NSCrypto() {
        this.crypto_pwhash_consts = {
            scryptsalsa208sha256: {
                mem_limits: { min: 8192 * 7168, max: 8192 * 9126 },
                ops_limits: { min: 768 * 512, max: 768 * 768 }
            },
            argon2i: {
                mem_limits: { min: 8192 * 308, max: 8192 * 436 },
                ops_limits: { min: 4, max: 6 }
            }
        };
        this.rsaEncPaddingType = {
            pkcs1: SwRSA_AsymmetricPadding.Pkcs1,
            oaep: SwRSA_AsymmetricPadding.Oaep
        };
        this.digestType = {
            sha1: SwCC_DigestAlgorithm.Sha1,
            sha256: SwCC_DigestAlgorithm.Sha256,
            sha512: SwCC_DigestAlgorithm.Sha512
        };
    }
    NSCrypto.prototype.hash = function (input, type) {
        if (Object.keys(this.digestType).indexOf(type) === -1) {
            throw new Error("hash type \"" + type + "\" not found!");
        }
        var inputData = new NSData({
            base64EncodedString: input,
            options: 1
        });
        return SwCC.digestAlg(inputData, this.digestType[type]).base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.secureRandomBytes = function (length) {
        return SwCC.generateRandom(length).base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.randomBytes = function (length) {
        return SwCC.generateRandom(length);
    };
    NSCrypto.prototype.deriveSecureKey = function (password, key_size, salt, ops_limits, mem_limits, alg) {
        sodium_init();
        var _salt;
        var _salt_length = -1;
        if (salt) {
            var salt_data = new NSData({ base64Encoding: salt });
            _salt_length = salt_data.length;
            _salt = interop.alloc(_salt_length * interop.sizeof(interop.types.unichar));
            salt_data.getBytes(_salt);
        }
        alg = alg || 'argon2i';
        if (['argon2i', 'scryptsalsa208sha256'].indexOf(alg) === -1) {
            throw new Error("deriveSecureKey algorithm \"" + alg + "\" not found");
        }
        if (!mem_limits) {
            var diff = this.crypto_pwhash_consts[alg].mem_limits.max -
                this.crypto_pwhash_consts[alg].mem_limits.min;
            mem_limits =
                this.crypto_pwhash_consts[alg].mem_limits.min +
                    randombytes_uniform(diff + 1);
        }
        if (!ops_limits) {
            var diff = this.crypto_pwhash_consts[alg].ops_limits.max -
                this.crypto_pwhash_consts[alg].ops_limits.min;
            ops_limits =
                this.crypto_pwhash_consts[alg].ops_limits.min +
                    randombytes_uniform(diff + 1);
        }
        if (_salt_length === -1) {
            if (alg === 'argon2i') {
                _salt_length = crypto_pwhash_argon2i_saltbytes();
            }
            else if (alg === 'argon2i') {
                _salt_length = crypto_pwhash_scryptsalsa208sha256_saltbytes();
            }
            _salt = interop.alloc(_salt_length * interop.sizeof(interop.types.unichar));
            randombytes_buf(_salt, _salt_length);
        }
        var derived_key = interop.alloc(key_size * interop.sizeof(interop.types.unichar));
        if (alg === 'argon2i') {
            if (crypto_pwhash_argon2i(derived_key, key_size, password, password.length, _salt, ops_limits, mem_limits, crypto_pwhash_alg_argon2i13()) !== 0) {
                throw new Error('deriveSecureKey out of memory');
            }
        }
        else if (alg === 'scryptsalsa208sha256') {
            if (crypto_pwhash_scryptsalsa208sha256(derived_key, key_size, password, password.length, _salt, ops_limits, mem_limits) !== 0) {
                throw new Error('deriveSecureKey out of memory');
            }
        }
        return {
            key: toBase64(derived_key, key_size),
            salt: toBase64(_salt, _salt_length),
            ops_limits: ops_limits,
            mem_limits: mem_limits,
            alg: alg
        };
    };
    NSCrypto.prototype.secureSymetricAEADkeyLength = function () {
        if (crypto_aead_aes256gcm_is_available() !== 0) {
            return crypto_aead_aes256gcm_keybytes();
        }
        return crypto_aead_chacha20poly1305_ietf_keybytes();
    };
    NSCrypto.prototype.secureSymetricAEADnonceLength = function () {
        if (crypto_aead_aes256gcm_is_available() !== 0) {
            return crypto_aead_aes256gcm_npubbytes();
        }
        return crypto_aead_chacha20poly1305_ietf_npubbytes();
    };
    NSCrypto.prototype.encryptSecureSymetricAEAD = function (key, plainb, aad, pnonce, alg) {
        var cipherb;
        var cipherb_length = new interop.Reference();
        var dataPlainb = base64toBytes(plainb);
        var dataAAD = base64toBytes(aad);
        if (crypto_aead_aes256gcm_is_available() !== 0 &&
            (alg === 'aes256gcm' || !alg)) {
            cipherb = interop.alloc((dataPlainb.length + crypto_aead_aes256gcm_abytes()) *
                interop.sizeof(interop.types.unichar));
            crypto_aead_aes256gcm_encrypt(cipherb, cipherb_length, dataPlainb.bytes, dataPlainb.length, dataAAD.bytes, dataAAD.length, null, base64toBytes(pnonce).bytes, base64toBytes(key).bytes);
            return {
                cipherb: toBase64(cipherb, cipherb_length.value),
                alg: 'aes256gcm'
            };
        }
        else if (alg === 'chacha20poly1305_ietf' || !alg) {
            cipherb = interop.alloc((plainb.length + crypto_aead_chacha20poly1305_ietf_abytes()) *
                interop.sizeof(interop.types.unichar));
            crypto_aead_chacha20poly1305_ietf_encrypt(cipherb, cipherb_length, dataPlainb.bytes, dataPlainb.length, dataAAD.bytes, dataAAD.length, null, base64toBytes(pnonce).bytes, base64toBytes(key).bytes);
            return {
                cipherb: toBase64(cipherb, cipherb_length.value),
                alg: 'chacha20poly1305_ietf'
            };
        }
        else {
            throw new Error("encryptSecureSymetricAEAD algorith " + alg + " not found or is not available in this hardware");
        }
    };
    NSCrypto.prototype.decryptSecureSymetricAEAD = function (key, cipherb, aad, pnonce, alg) {
        var plainb;
        var plainb_length = new interop.Reference();
        if (crypto_aead_aes256gcm_is_available() !== 0 &&
            (alg === 'aes256gcm' || !alg)) {
            var cipherb_p = base64toBytes(cipherb);
            plainb = interop.alloc((cipherb_p.length - crypto_aead_chacha20poly1305_ietf_abytes()) *
                interop.sizeof(interop.types.unichar));
            crypto_aead_aes256gcm_decrypt(plainb, plainb_length, cipherb_p, cipherb_p.length, aad, aad.length, null, base64toBytes(pnonce).bytes, base64toBytes(key).bytes);
        }
        else if (alg === 'chacha20poly1305_ietf' || !alg) {
            plainb = interop.alloc(cipherb.length * interop.sizeof(interop.types.unichar));
            crypto_aead_chacha20poly1305_ietf_decrypt(plainb, plainb_length, cipherb, cipherb.length, aad, aad.length, null, base64toBytes(pnonce).bytes, base64toBytes(key).bytes);
        }
        else {
            throw new Error("decryptSecureSymetricAEAD algorith " + alg + " not found or is not available in this hardware");
        }
        return toBase64(plainb, plainb_length.value);
    };
    NSCrypto.prototype.encryptAES256GCM = function (key, plainb, aad, iv, tagLength) {
        if (tagLength === void 0) { tagLength = 128; }
        var plaintData = new NSData({ base64Encoding: plainb });
        var aadData = new NSData({ base64Encoding: aad });
        var ivData = new NSData({ base64Encoding: iv });
        var keyData = new NSData({ base64Encoding: key });
        var res = SwCC.cryptAuthBlockModeAlgorithmDataADataKeyIvTagLengthTagError(SwCC_OpMode.Encrypt, SwCC_AuthBlockMode.Gcm, SwCC_Algorithm.Aes, plaintData, aadData, keyData, ivData, tagLength / 8, null);
        return {
            cipherb: res
                .valueForKey('data')
                .base64EncodedStringWithOptions(kNilOptions),
            atag: res.valueForKey('tag').base64EncodedStringWithOptions(kNilOptions)
        };
    };
    NSCrypto.prototype.decryptAES256GCM = function (key, cipherb, aad, iv, atag) {
        var cipherbData = new NSData({
            base64EncodedString: cipherb,
            options: 1
        });
        var atagData = new NSData({
            base64EncodedString: atag,
            options: 1
        });
        var aadData = new NSData({
            base64EncodedString: aad,
            options: 1
        });
        var ivData = new NSData({
            base64EncodedString: iv,
            options: 1
        });
        var keyData = new NSData({
            base64EncodedString: key,
            options: 1
        });
        var res = SwCC.cryptAuthBlockModeAlgorithmDataADataKeyIvTagLengthTagError(SwCC_OpMode.Decrypt, SwCC_AuthBlockMode.Gcm, SwCC_Algorithm.Aes, cipherbData, aadData, keyData, ivData, atagData.length, atagData);
        return res.valueForKey('data').base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.encryptRSA = function (pub_key_pem, plainb, padding) {
        if (Object.keys(this.rsaEncPaddingType).indexOf(padding) === -1) {
            throw new Error("encryptRSA padding \"" + padding + "\" not found!");
        }
        var plainbData = new NSData({
            base64EncodedString: plainb,
            options: 1
        });
        var derKey = SwKeyConvert_PublicKey.pemToPKCS1DERError(pub_key_pem);
        return SwRSA.encryptDerKeyTagPaddingDigestError(plainbData, derKey, null, this.rsaEncPaddingType[padding], SwCC_DigestAlgorithm.Sha1).base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.decryptRSA = function (priv_key_pem, cipherb, padding) {
        if (Object.keys(this.rsaEncPaddingType).indexOf(padding) === -1) {
            throw new Error("decryptRSA padding \"" + padding + "\" not found!");
        }
        var cipherbData = new NSData({
            base64EncodedString: cipherb,
            options: 1
        });
        var derKey = SwKeyConvert_PrivateKey.pemToPKCS1DERError(priv_key_pem);
        return SwRSA.decryptDerKeyTagPaddingDigestError(cipherbData, derKey, null, this.rsaEncPaddingType[padding], SwCC_DigestAlgorithm.Sha1).base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.signRSA = function (priv_key_pem, messageb, digest_type) {
        if (Object.keys(this.digestType).indexOf(digest_type) === -1) {
            throw new Error("signRSA digest type \"" + digest_type + "\" not found!");
        }
        var messagebData = new NSData({
            base64EncodedString: messageb,
            options: 1
        });
        var derKey = SwKeyConvert_PrivateKey.pemToPKCS1DERError(priv_key_pem);
        return SwRSA.signDerKeyPaddingDigestSaltLenError(messagebData, derKey, SwRSA_AsymmetricSAPadding.Pkcs15, SwCC_DigestAlgorithm.Sha256, 0, null).base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.verifyRSA = function (pub_key_pem, messageb, signatureb, digest_type) {
        if (Object.keys(this.digestType).indexOf(digest_type) === -1) {
            throw new Error("verifyRSA digest type \"" + digest_type + "\" not found!");
        }
        var messagebData = new NSData({
            base64EncodedString: messageb,
            options: 1
        });
        var signaturebData = new NSData({
            base64EncodedString: signatureb,
            options: 1
        });
        var derKey = SwKeyConvert_PublicKey.pemToPKCS1DERError(pub_key_pem);
        try {
            return (SwRSA.verifyDerKeyPaddingDigestSaltLenSignedDataError(messagebData, derKey, SwRSA_AsymmetricSAPadding.Pkcs15, SwCC_DigestAlgorithm.Sha256, 0, signaturebData, null) == 1);
        }
        catch (err) {
            return false;
        }
    };
    NSCrypto.prototype.deflate = function (input, alg) {
        var data = new NSData({
            base64EncodedString: input,
            options: 1
        });
        var dc = new DataCompression({ data: data });
        return dc.zip().base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.inflate = function (input, alg) {
        var data = new NSData({
            base64EncodedString: input,
            options: 1
        });
        var dc = new DataCompression({ data: data });
        return dc
            .unzipWithSkipHeaderAndCheckSumValidation(true)
            .base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.base64encode = function (input) {
        var plainData = new NSString({
            UTF8String: input
        }).dataUsingEncoding(NSUTF8StringEncoding);
        return plainData.base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.base64decode = function (input) {
        var data = new NSData({
            base64EncodedString: input,
            options: 1
        });
        return new NSString({
            data: data,
            encoding: NSUTF8StringEncoding
        });
    };
    NSCrypto.prototype.randomUUID = function () {
        return NSUUID.UUID().UUIDString;
    };
    NSCrypto.prototype.keyWrapAES = function (wrappingKey, key) {
        var wrappingKeyData = new NSData({
            base64EncodedString: wrappingKey,
            options: 1
        });
        var keyData = new NSData({
            base64EncodedString: key,
            options: 1
        });
        return SwKeyWrap.SymmetricKeyWrapKekRawKeyError(SwKeyWrap.rfc3394IV, wrappingKeyData, keyData, null).base64EncodedStringWithOptions(kNilOptions);
    };
    NSCrypto.prototype.keyUnWrapAES = function (unwrappingKey, wrappedkey) {
        var unwrappingKeyData = new NSData({
            base64EncodedString: unwrappingKey,
            options: 1
        });
        var wrappedData = new NSData({
            base64EncodedString: wrappedkey,
            options: 1
        });
        return SwKeyWrap.SymmetricKeyUnwrapKekWrappedKeyError(SwKeyWrap.rfc3394IV, unwrappingKeyData, wrappedData, null).base64EncodedStringWithOptions(kNilOptions);
    };
    return NSCrypto;
}());
exports.NSCrypto = NSCrypto;
//# sourceMappingURL=crypto.ios.js.map
