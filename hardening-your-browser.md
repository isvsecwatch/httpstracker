###### Based on this article;
http://blog.yjl.im/2013/12/disabling-tlsssl-rc4-in-firefox-and.html

##### Test your browser
https://www.ssllabs.com/ssltest/viewMyClient.html

#### Firefox via 'about:config'

![Screenshot of Firefox 'about:config'](https://pbs.twimg.com/media/B7youhBIQAAGiad.png:large)

#### Google Chrome on OS X

Chrome requires starting it via the terminal;
```
#!/bin/zsh
#
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --cipher-suite-blacklist=0x0004,0x0005,0xc011,0xc007 &
```
The above disables RC4 and 3DES. I have this wrapped in a little Platypus application, as detailed here; https://twitter.com/sindarina/status/561577239129911296
