cmd_crypto/built-in.o :=  arm-linux-gnueabi-ld -EL    -r -o crypto/built-in.o crypto/crypto.o crypto/crypto_algapi.o crypto/crypto_hash.o crypto/aes_generic.o crypto/crc32c.o 
