#Notes on DH parameters, post-Logjam

There are two ways to make sure you have a DH key that is at least 2048 bits in size; generate one yourself, or use the standard DH groups described in [RFC 3526](http://datatracker.ietf.org/doc/rfc3526/?include_text=1).

There seem to be pros and cons to each;

* [Twitter discussion post-Logjam](https://twitter.com/a_z_e_t/status/601001358746062848)
* [Is it safer to generate your own Diffie-Hellman primes or to use those defined in RFC 3526?](http://crypto.stackexchange.com/questions/1999/is-it-safer-to-generate-your-own-diffie-hellman-primes-or-to-use-those-defined-i/2000#2000)

The basic gist is that the predefined primes have been reviewed thorougly by many eyes, and can therefore be considered secure. Drawback is that they are known, and once broken the impact can be quite severe because they are shared by many servers. This is one of the reasons why anything less than 2048 bits is considered insecure.

[BetterCrypto](https://bettercrypto.org/) currently recommends using the predefined primes, as long as they are at least 2048 bits in size, while a lot of online advice recommends generating your own, including the Logjam [Guide to Deploying Diffie-Hellman for TLS](https://weakdh.org/sysadmin.html).

#### Generating your own

I have generally generated my own so far, unique per server, on my own noisy desktop;
```
$ openssl dhparams 2048
```
And then pasting the output directly into a prepped file on the target server, limited to read-only by root. It can be referenced from nginx via the 'ssl_dhparam' setting, and will be loaded before nginx drops privileges. The same approach works for Postfix, and various other daemons that allow one to override the 1024-bit default they currently have.

*Not all daemons default to 1024-bit DH keys. Apache 2.4 and recent versions of stunnel use 2048 bits. Review the defaults for your software; if you're fine with using the predefined primes, you may not need to specify your own.*

#### Using the default primes

They are defined in [RFC 3526](http://datatracker.ietf.org/doc/rfc3526/?include_text=1), and [BetterCrypto](https://bettercrypto.org/) provides a list of them [https://bettercrypto.org/static/dhparams/](in PEM format).

How do we know that they are one and the same? Let's look at the 2048-bit example, which is still considered secure at the moment. The RFC defines the group as the following hexadecimal value;
```
FFFFFFFF FFFFFFFF C90FDAA2 2168C234 C4C6628B 80DC1CD1
29024E08 8A67CC74 020BBEA6 3B139B22 514A0879 8E3404DD
EF9519B3 CD3A431B 302B0A6D F25F1437 4FE1356D 6D51C245
E485B576 625E7EC6 F44C42E9 A637ED6B 0BFF5CB6 F406B7ED
EE386BFB 5A899FA5 AE9F2411 7C4B1FE6 49286651 ECE45B3D
C2007CB8 A163BF05 98DA4836 1C55D39A 69163FA8 FD24CF5F
83655D23 DCA3AD96 1C62F356 208552BB 9ED52907 7096966D
670C354E 4ABC9804 F1746C08 CA18217C 32905E46 2E36CE3B
E39E772C 180E8603 9B2783A2 EC07A28F B5C55DF0 6F4C52C9
DE2BCBF6 95581718 3995497C EA956AE5 15D22618 98FA0510
15728E5A 8AACAA68 FFFFFFFF FFFFFFFF
```
When we compare that to the 'group14.pem' provided by BetterCrypto, and tell OpenSSL to show the text output, we can compare the prime with the value defined in the RFC;
```
$ openssl dhparam -in group14.pem -text
    PKCS#3 DH Parameters: (2048 bit)
        prime:
            00:ff:ff:ff:ff:ff:ff:ff:ff:c9:0f:da:a2:21:68:
            c2:34:c4:c6:62:8b:80:dc:1c:d1:29:02:4e:08:8a:
            67:cc:74:02:0b:be:a6:3b:13:9b:22:51:4a:08:79:
            8e:34:04:dd:ef:95:19:b3:cd:3a:43:1b:30:2b:0a:
            6d:f2:5f:14:37:4f:e1:35:6d:6d:51:c2:45:e4:85:
            b5:76:62:5e:7e:c6:f4:4c:42:e9:a6:37:ed:6b:0b:
            ff:5c:b6:f4:06:b7:ed:ee:38:6b:fb:5a:89:9f:a5:
            ae:9f:24:11:7c:4b:1f:e6:49:28:66:51:ec:e4:5b:
            3d:c2:00:7c:b8:a1:63:bf:05:98:da:48:36:1c:55:
            d3:9a:69:16:3f:a8:fd:24:cf:5f:83:65:5d:23:dc:
            a3:ad:96:1c:62:f3:56:20:85:52:bb:9e:d5:29:07:
            70:96:96:6d:67:0c:35:4e:4a:bc:98:04:f1:74:6c:
            08:ca:18:21:7c:32:90:5e:46:2e:36:ce:3b:e3:9e:
            77:2c:18:0e:86:03:9b:27:83:a2:ec:07:a2:8f:b5:
            c5:5d:f0:6f:4c:52:c9:de:2b:cb:f6:95:58:17:18:
            39:95:49:7c:ea:95:6a:e5:15:d2:26:18:98:fa:05:
            10:15:72:8e:5a:8a:ac:aa:68:ff:ff:ff:ff:ff:ff:
            ff:ff
        generator: 2 (0x2)
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA///////////JD9qiIWjCNMTGYouA3BzRKQJOCIpnzHQCC76mOxOb
IlFKCHmONATd75UZs806QxswKwpt8l8UN0/hNW1tUcJF5IW1dmJefsb0TELppjft
awv/XLb0Brft7jhr+1qJn6WunyQRfEsf5kkoZlHs5Fs9wgB8uKFjvwWY2kg2HFXT
mmkWP6j9JM9fg2VdI9yjrZYcYvNWIIVSu57VKQdwlpZtZww1Tkq8mATxdGwIyhgh
fDKQXkYuNs474553LBgOhgObJ4Oi7Aeij7XFXfBvTFLJ3ivL9pVYFxg5lUl86pVq
5RXSJhiY+gUQFXKOWoqsqmj//////////wIBAg==
-----END DH PARAMETERS-----
```
The part that you need to store on your server is the PEM-encoded bit;
```
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA///////////JD9qiIWjCNMTGYouA3BzRKQJOCIpnzHQCC76mOxOb
IlFKCHmONATd75UZs806QxswKwpt8l8UN0/hNW1tUcJF5IW1dmJefsb0TELppjft
awv/XLb0Brft7jhr+1qJn6WunyQRfEsf5kkoZlHs5Fs9wgB8uKFjvwWY2kg2HFXT
mmkWP6j9JM9fg2VdI9yjrZYcYvNWIIVSu57VKQdwlpZtZww1Tkq8mATxdGwIyhgh
fDKQXkYuNs474553LBgOhgObJ4Oi7Aeij7XFXfBvTFLJ3ivL9pVYFxg5lUl86pVq
5RXSJhiY+gUQFXKOWoqsqmj//////////wIBAg==
-----END DH PARAMETERS-----
```
The same applies to the other DH groups available. For example, this is group 15, 3072 bits;
```
$ openssl dhparam -in group15.pem -text
    PKCS#3 DH Parameters: (3072 bit)
        prime:
            00:ff:ff:ff:ff:ff:ff:ff:ff:c9:0f:da:a2:21:68:
            c2:34:c4:c6:62:8b:80:dc:1c:d1:29:02:4e:08:8a:
            67:cc:74:02:0b:be:a6:3b:13:9b:22:51:4a:08:79:
            8e:34:04:dd:ef:95:19:b3:cd:3a:43:1b:30:2b:0a:
            6d:f2:5f:14:37:4f:e1:35:6d:6d:51:c2:45:e4:85:
            b5:76:62:5e:7e:c6:f4:4c:42:e9:a6:37:ed:6b:0b:
            ff:5c:b6:f4:06:b7:ed:ee:38:6b:fb:5a:89:9f:a5:
            ae:9f:24:11:7c:4b:1f:e6:49:28:66:51:ec:e4:5b:
            3d:c2:00:7c:b8:a1:63:bf:05:98:da:48:36:1c:55:
            d3:9a:69:16:3f:a8:fd:24:cf:5f:83:65:5d:23:dc:
            a3:ad:96:1c:62:f3:56:20:85:52:bb:9e:d5:29:07:
            70:96:96:6d:67:0c:35:4e:4a:bc:98:04:f1:74:6c:
            08:ca:18:21:7c:32:90:5e:46:2e:36:ce:3b:e3:9e:
            77:2c:18:0e:86:03:9b:27:83:a2:ec:07:a2:8f:b5:
            c5:5d:f0:6f:4c:52:c9:de:2b:cb:f6:95:58:17:18:
            39:95:49:7c:ea:95:6a:e5:15:d2:26:18:98:fa:05:
            10:15:72:8e:5a:8a:aa:c4:2d:ad:33:17:0d:04:50:
            7a:33:a8:55:21:ab:df:1c:ba:64:ec:fb:85:04:58:
            db:ef:0a:8a:ea:71:57:5d:06:0c:7d:b3:97:0f:85:
            a6:e1:e4:c7:ab:f5:ae:8c:db:09:33:d7:1e:8c:94:
            e0:4a:25:61:9d:ce:e3:d2:26:1a:d2:ee:6b:f1:2f:
            fa:06:d9:8a:08:64:d8:76:02:73:3e:c8:6a:64:52:
            1f:2b:18:17:7b:20:0c:bb:e1:17:57:7a:61:5d:6c:
            77:09:88:c0:ba:d9:46:e2:08:e2:4f:a0:74:e5:ab:
            31:43:db:5b:fc:e0:fd:10:8e:4b:82:d1:20:a9:3a:
            d2:ca:ff:ff:ff:ff:ff:ff:ff:ff
        generator: 2 (0x2)
-----BEGIN DH PARAMETERS-----
MIIBiAKCAYEA///////////JD9qiIWjCNMTGYouA3BzRKQJOCIpnzHQCC76mOxOb
IlFKCHmONATd75UZs806QxswKwpt8l8UN0/hNW1tUcJF5IW1dmJefsb0TELppjft
awv/XLb0Brft7jhr+1qJn6WunyQRfEsf5kkoZlHs5Fs9wgB8uKFjvwWY2kg2HFXT
mmkWP6j9JM9fg2VdI9yjrZYcYvNWIIVSu57VKQdwlpZtZww1Tkq8mATxdGwIyhgh
fDKQXkYuNs474553LBgOhgObJ4Oi7Aeij7XFXfBvTFLJ3ivL9pVYFxg5lUl86pVq
5RXSJhiY+gUQFXKOWoqqxC2tMxcNBFB6M6hVIavfHLpk7PuFBFjb7wqK6nFXXQYM
fbOXD4Wm4eTHq/WujNsJM9cejJTgSiVhnc7j0iYa0u5r8S/6BtmKCGTYdgJzPshq
ZFIfKxgXeyAMu+EXV3phXWx3CYjAutlG4gjiT6B05asxQ9tb/OD9EI5LgtEgqTrS
yv//////////AgEC
-----END DH PARAMETERS-----
```
The configuration steps to include one of these in your server configuration are the same as for DH parameters you have generated yourself.
