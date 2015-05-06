# httpstracker
Our [main issue tracker for ISV security issues](https://github.com/isvsecwatch/httpstracker/issues), such as the SSL/TLS configuration of their online stores. Please check if an issue already exists before filing a new one.

If you are listed in a ticket and not sure how to resolve the issue, please let us know with a ticket comment; we're happy to point you in the right direction, give you pointers on what to look for and such!

#### What to aim for when updating

We're well aware that it's not always possible to walk the cutting edge when it comes to your SSL/TLS deployment, due to limitations in software and/or hardware you have no control over, but in general; aim high! For current best practice, see [RFC 7525](https://tools.ietf.org/html/rfc7525).

Anything you get done now will mean you don't have to get back to it later, and you should be good for a while. Or until the next vulnerability hits, anyway. Scroll down for some reading material. Here are some basics;

* **If it's online, maintain it**: 'we are going to replace it soon' is never an excuse to leave a vulnerable setup online. Maintain it, updating and tuning it as needed. Even if you're going to replace it in a month or so.

* **Compare configuration to documentation**: More often than we'd like to admit, things like this are installed or upgraded without verifying that the configuration is set up correctly. Apache and IIS have embarrassingly insecure defaults, for example, so try tuning what you have first.

* **Aim for TLSv1.2**: upgrade your web server for this, if you can. This version offers the most secure ciphers currently available, which many clients will negotiate if they can. If you're stuck with an older version of the web server that ships with your operating system, try putting something else in front, such as [nginx](http://nginx.org/), or a recent version of [stunnel](https://www.stunnel.org/).

* **Disable weak ciphers and old protocols**: yes, that means RC4, and any and all export ciphers. SSLv2 is obsolete, and SSLv3 should not be on either. If you still need to support Internet Explorer on Windows XP/2003 or similar legacy software, enable 3DES as the last cipher in your list.

* **Optimize your cipher order**: strongest ciphers at the top, weakest at the bottom. And make sure the server sets the preferred cipher order, not the client. That means, in terms of priority;
 * ECDHE AES GCM ciphers, if supported
 * ECDHE AES CBC ciphers, preferring SHA256+ over SHA1
 * DHE AES 128-bit for older clients, if necessary (DHE-RSA-AES128-SHA)
 * Static AES SHA1 ciphers for older clients, if necessary (AES128-SHA, AES256-SHA)
 * 3DES for IE/Schannel on XP/2003, if necessary (DES-CBC3-SHA)
 * RC4 (SHA > MD5), but *only* if you have clients that support absolutely *nothing* of the above. See the note on RC4, below.

This is what we use in production where 3DES is still needed, test with `openssl ciphers -v`:
```
EECDH+AES128:EECDH+AES256:EDH+AES128+SHA:RSA+AES+SHA:RSA+3DES:+SHA:!DSS
```
*(Requires OpenSSL 1.0)*

With the above, you should be able to achieve decent results even on older systems that only support TLSv1 and lack support for ECDHE ciphers. But again, if you're in that situation, try putting something more recent in front.

#### A note on RC4

Short version: *TURN OFF RC4, you do not need it.*

RC4 is becoming increasingly vulnerable, and you do not need it any longer to mitigate other vulnerabilities. There are still some clients out there that support nothing else, but the group of people that actually *needs* this is very small, and you won't be in it if your visitors are browser-based, or on fairly recent mobile devices. Check your web statistics, and make sure that the outliers aren't actually bots.

If you aren't sure, *err on the side of caution and disable RC4*. Here's some of the reasons why;

* SSL Server Test will deprecate from B to C to F in 2015; https://community.qualys.com/blogs/securitylabs/2015/04/23/ssl-labs-rc4-deprecation-plan
* Practical password attack against RC4; http://www.isg.rhul.ac.uk/tls/RC4mustdie.html
* Tornado attack on RC4 (WEP/WPA); https://eprint.iacr.org/2015/254
* Bar Mitzvah attack on RC4; http://www.darkreading.com/attacks-breaches/ssl-tls-suffers-bar-mitzvah-attack-/d/d-id/1319633
* Prohibiting RC4 Cipher Suites; https://tools.ietf.org/html/rfc7465

#### Further Reading

Start with the [documentation provided by Qualys for the SSL Server Test](https://www.ssllabs.com/projects/documentation/index.html), and follow the recommendations from the test itself. The items that are flagged for improvement will usually have a 'more info' link that explains the why and how. Here's a list of useful documentation and tools;

* SSL Server Test documentation: https://www.ssllabs.com/projects/documentation/index.html
* The OpenSSL Cookbook: https://www.feistyduck.com/library/openssl-cookbook/
* On optimizing TLS for performance: https://istlsfastyet.com/
* Mozilla's recommendations for servers: https://wiki.mozilla.org/Security/Server_Side_TLS
* The 'Applied Crypto Hardening' guide: https://bettercrypto.org/
* Nartac Software's IISCrypto: https://www.nartac.com/Products/IISCrypto/Default.aspx

Relevant RFCs;

* Summarizing Known Attacks on TLS/DTLS: https://datatracker.ietf.org/doc/rfc7457/
* Prohibiting RC4 Cipher Suites: https://tools.ietf.org/html/rfc7465
* Recommendations for Secure Use of TLS and DTLS: https://tools.ietf.org/html/rfc7525

Various articles from around the web;

* https://scotthelme.co.uk/getting-an-a-on-the-qualys-ssl-test-windows-edition/ (IIS)
* https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12 (IIS)
* https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/ (OpenSSL)
