**NOTE 2017/01/02**: This project is on hold until further notice, and will not be actively maintained in the meantime.

--

# httpstracker
Our [main issue tracker for ISV security issues](https://github.com/isvsecwatch/httpstracker/issues), such as the SSL/TLS configuration of their online stores. Please check if an issue already exists before filing a new one.

If you are listed in a ticket and not sure how to resolve the issue, please let us know with a ticket comment; we're happy to point you in the right direction, give you pointers on what to look for and such!

#### What to aim for when updating

We're well aware that it's not always possible to walk the cutting edge when it comes to your SSL/TLS deployment, due to limitations in software and/or hardware you have no control over, but in general; aim high! For current best practice, see [RFC 7525](https://tools.ietf.org/html/rfc7525).

Anything you get done now will mean you don't have to get back to it later, and you should be good for a while. Or until the next vulnerability hits, anyway. Scroll down for some reading material. Here are some basics;

* **If it's online, maintain it**: 'we are going to replace it soon' is never an excuse to leave a vulnerable setup online. Maintain it, updating and tuning it as needed. Even if you're going to replace it in a month or so.

* **Compare configuration to documentation**: More often than we'd like to admit, things like this are installed or upgraded without verifying that the configuration is set up correctly. Apache and IIS have embarrassingly insecure defaults, for example, so try tuning what you have first. Quite a few issues can be fixed by tweaking your existing configuration. Enabling server-side ordering, disabling old ciphers and such can all be done without needing to upgrade. If issues like these take longer than two workdays to fix, review your procedures; something's wrong with your change management process.

* **Aim for TLSv1.2**: upgrade your web server for this, if you can. This version offers the most secure ciphers currently available, which many clients will negotiate if they can. If you're stuck with an older version of the web server that ships with your operating system, try putting something else in front, such as [nginx](http://nginx.org/), or a recent version of [stunnel](https://www.stunnel.org/).

* **Disable weak ciphers and old protocols**: yes, that means RC4, and any and all export ciphers. SSLv2 is obsolete, and SSLv3 should not be on either. If you still need to support Internet Explorer on Windows XP/2003 or similar legacy software, enable 3DES as the last cipher in your list.

* **Optimize your cipher order**: strongest ciphers at the top, weakest at the bottom. And make sure the server sets the preferred cipher order, not the client. That means, in terms of priority;
 * ECDHE AES GCM ciphers, if supported
 * ECDHE AES CBC ciphers, preferring SHA256+ over SHA1
 * DHE AES 128-bit for older clients, *if necessary* (DHE-RSA-AES128-SHA); use DH keys that are at least 2048 bits in size. [See the DH/DHE note below](#a-note-on-dhdhe).
 * Static AES SHA1 ciphers for older clients, *if necessary* (AES128-SHA, AES256-SHA)
 * 3DES for IE/Schannel on XP/2003, *if necessary* (DES-CBC3-SHA)
 * ~~RC4 (SHA > MD5), but *only* if you have clients that support absolutely *nothing* of the above.~~ [See the note on RC4, below](#a-note-on-rc4).

This is what we use in production, depending on compatibility requirements, test with `openssl ciphers -v`:
```
# 1) RSA/ECDSA: recommended for modern browsers/clients
EECDH+AES128+AESGCM:EECDH+AES:+SHA:!DSS

# 2) RSA: recommended with backwards compatibility for older, supported clients
EECDH+AES128+AESGCM:EECDH+AES:EDH+AES128+SHA:AES128-SHA:+SHA:!DSS

# 3) RSA: as #2 above, but including support for 3DES
EECDH+AES128+AESGCM:EECDH+AES:EDH+AES128+SHA:AES128-SHA:DES-CBC3-SHA:+SHA:!DSS

# 4) RSA: extended compatibility with clients that don't do ECDHE, like for APIs
EECDH+AES128+AESGCM:EECDH+AES256+AESGCM:EDH+AESGCM:EECDH+AES:+SHA:EDH+AES:+SHA:RSA+AES+SHA:!DSS
```
*NOTE: These ciper selections prefer 256-bit AES over 128-bit AES for CBC and DHE ciphers, due in part to updated post-Suite B NSA recommendations. The 128-bit AES-GCM cipher remains at the top due to it's preferred support in modern browsers such as Chrome and Firefox, which currently do not support the 256-bit version.*

*Requires OpenSSL 1.0 or higher.*

You should be able to achieve decent results even on older systems that only support TLSv1 and lack support for ECDHE ciphers. But again, if you're in that situation, try putting something more recent in front.

#### A note on RC4

Short version: *TURN OFF RC4; it's vulnerable, and you do not need it.*

RC4 is becoming increasingly vulnerable, and you do not need it any longer to mitigate other vulnerabilities. There are still some clients out there that support nothing else, but the group of people that actually *needs* this is very small, and you won't be in it if your visitors are browser-based, or on fairly recent mobile devices. Check your web statistics, and make sure that the outliers aren't actually bots.

If you aren't sure, *err on the side of caution and disable RC4*. Here's some of the reasons why;

* Google is deprecating RC4 (2015/09/17); http://googleonlinesecurity.blogspot.com/2015/09/disabling-sslv3-and-rc4.html
* RC4 NOMORE attack (2015/07/15); http://www.rc4nomore.com/
* SSL Server Test will deprecate from B to C to F in 2015; https://community.qualys.com/blogs/securitylabs/2015/04/23/ssl-labs-rc4-deprecation-plan
* Practical password attack against RC4; http://www.isg.rhul.ac.uk/tls/RC4mustdie.html
* Tornado attack on RC4 (WEP/WPA); https://eprint.iacr.org/2015/254
* Bar Mitzvah attack on RC4; http://www.darkreading.com/attacks-breaches/ssl-tls-suffers-bar-mitzvah-attack-/d/d-id/1319633
* Prohibiting RC4 Cipher Suites; https://tools.ietf.org/html/rfc7465

#### A note on DH/DHE

If you need to DHE ciphers, for older clients or because your SSL implementation does not support ECDHE, make sure you are using DH keys that are at least 2048 bits in size. With the release of the details of the Logjam attack, 1024-bit keys are considered to be within the reach of state-level adversaries, and therefore no longer safe;

* Logjam Attack: https://weakdh.org/
* Logjam DH deployment guide: https://weakdh.org/sysadmin.html
* Logjam article at Ars: http://arstechnica.com/security/2015/05/https-crippling-attack-threatens-tens-of-thousands-of-web-and-mail-servers/
* Detailed notes on DH parameters: https://github.com/isvsecwatch/httpstracker/blob/master/dhparam-notes.md

You should no longer be using DHE with versions of Apache (2.2.x) that support a maximum DH key size of 1024 bits. Disable DH completely, using only ECDHE, or upgrade to something that supports stronger DH keys; Apache 2.4.x, nginx, stunnel.

#### Further Reading

Start with the [documentation provided by Qualys for the SSL Server Test](https://www.ssllabs.com/projects/documentation/index.html), and follow the recommendations from the test itself. The items that are flagged for improvement will usually have a 'more info' link that explains the why and how. Here's a list of useful documentation and tools;

* 10 Reasons To Use HTTPS: https://medium.com/@guypod/10-reasons-to-go-https-a2cba5734bb6
* SSL Server Test documentation: https://www.ssllabs.com/projects/documentation/index.html
* The OpenSSL Cookbook: https://www.feistyduck.com/library/openssl-cookbook/
* On optimizing TLS for performance: https://istlsfastyet.com/
* Mozilla's recommendations for servers: https://wiki.mozilla.org/Security/Server_Side_TLS
* The 'Applied Crypto Hardening' guide: https://bettercrypto.org/
* Nartac Software's IISCrypto: https://www.nartac.com/Products/IISCrypto/Default.aspx
* SSL Labs list of user agent capabilities; https://www.ssllabs.com/ssltest/clients.html

**Testing/Verification;**

* SSL Server Test; https://www.ssllabs.com/ssltest/index.html
* Cipherscan; https://github.com/jvehent/cipherscan
* testssl.sh; https://testssl.sh/
* SSLyze; https://github.com/nabla-c0d3/sslyze
* SSL Server Test CLI client; https://github.com/ssllabs/ssllabs-scan/

**Relevant RFCs;**

* Summarizing Known Attacks on TLS/DTLS: https://datatracker.ietf.org/doc/rfc7457/
* Prohibiting RC4 Cipher Suites: https://tools.ietf.org/html/rfc7465
* Recommendations for Secure Use of TLS and DTLS: https://tools.ietf.org/html/rfc7525

**Various articles from around the web;**

* https://scotthelme.co.uk/getting-an-a-on-the-qualys-ssl-test-windows-edition/ (IIS)
* https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12 (IIS)
* https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/ (OpenSSL)
