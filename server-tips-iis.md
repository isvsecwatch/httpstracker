# Tuning IIS/Schannel for best SSL/TLS results

Tuning Schannel, the SSL/TLS component that powers pretty much all of Microsoft's products, requires poking around in the registry or running PowerShell scripts, which can be daunting to some.

Nartac Software's IIS Crypto tool makes that a lot easier, fortunately;

https://www.nartac.com/Products/IISCrypto/Default.aspx

Launch that, click 'Best Practices', and 'Apply'. Reboot the server, and you *should* be good to go. As always, your mileage may vary, and the risk is yours.

Here's some additional information;

* https://scotthelme.co.uk/getting-an-a-on-the-qualys-ssl-test-windows-edition/
* https://www.hass.de/content/setup-your-iis-ssl-perfect-forward-secrecy-and-tls-12

Do note that the method for setting up HSTS as detailed in the first article works, but isn't according to the spec, which requires that the HSTS header be set *only* for HTTPS requests. An IIS module that will do this properly is available here;

https://hstsiis.codeplex.com/

There are also some gotchas to be aware of for Schannel outside of IIS, such as the fact that Exchange will not support TLSv1.2 for POP3/IMAP or SMTP;

http://support.microsoft.com/kb/2709167
