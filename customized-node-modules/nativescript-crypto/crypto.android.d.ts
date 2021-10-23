import { INSCryto } from './crypto.common';
export declare class NSCrypto implements INSCryto {
    private crypto_pwhash_consts;
    private _hashTypeLibsodiumNamespace;
    private rsaEncPaddingType;
    private rsaSigDigestType;
    hash(input: string, type: string): string;
    secureRandomBytes(length: number): string;
    deriveSecureKey(password: string, key_size: number, salt?: string, ops_limits?: number, mem_limits?: number, alg?: string): {
        key: string;
        salt: string;
        ops_limits: number;
        mem_limits: number;
        alg: string;
    };
    secureSymetricAEADkeyLength(): number;
    secureSymetricAEADnonceLength(): number;
    encryptSecureSymetricAEAD(key: string, plainb: string, aad: string, pnonce: string, alg?: string): {
        cipherb: string;
        alg: string;
    };
    decryptSecureSymetricAEAD(key: string, cipherb: string, aad: string, pnonce: string, alg?: string): string;
    private initSpongyCastle();
    private hasServiceProvider(service, provider);
    encryptAES256GCM(key: string, plaint: string, aad: string, iv: string, tagLength?: number): {
        cipherb: string;
        atag: string;
    };
    decryptAES256GCM(key: string, cipherb: string, aad: string, iv: string, atag: string): string;
    encryptRSA(pub_key_pem: string, plainb: string, padding: string): string;
    decryptRSA(priv_key_pem: string, cipherb: string, padding: string): string;
    signRSA(priv_key_pem: string, messageb: string, digest_type: string): string;
    verifyRSA(pub_key_pem: string, messageb: string, signatureb: string, digest_type: string): boolean;
    deflate(input: string): string;
    inflate(input: string): string;
    base64encode(input: string): string;
    base64decode(input: string): string;
    randomUUID(): string;
    keyWrapAES(wrappingKey: string, key: string): string;
    keyUnWrapAES(unwrappingKey: string, wrappedkey: string): string;
}
