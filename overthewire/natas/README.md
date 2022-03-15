# Natas

[Natas](https://overthewire.org/wargames/natas/) is a wargame series covering server-side web security.

The following are my solutions and notes from some of the Natas challenges.

## natas0
Flag: gtVrDuiDfck831PqWsLEZy5gyDz1clto

Flag in HTML comment

## natas1
Flag: ZluruAthQk7Q2MqmDeTiUij2ZvWy2mBi

Flag in HTML comment again, but can't right click to inspect element. Open dev tools some other way instead.

## natas2
Flag: sJIJNW6ucpu6HPZ1ZAchaDtwd7oGrD14

Page has an img tag which links to files/pixel.png
Navigating to the files/ directory of the site reveals another accesible file: users.txt
In users.txt the flag is next to natas3

## natas3
Flag: Z9tkRkWmpt9Qr7XrR5jWRkgOU901swEZ

The comment “No more information leaks!! Not even Google will find it this time... ” in the HTML indicates that there's something that would keep search engines from crawling or indexing the page we're looking for. If you do some digging, you'll find out about robots.txt, which is a file that most websites have to specify which pages or directories search engines can index. Going to /robots.txt shows us that the directory /s3cr3t is disallowed. If we go to /s3cret, we find a users.txt file with the flag

## natas4
Flag: iX6IOfmpN7AYOQGPwtn3fXpbaJVJcHfq

The text indicates the page should be visited from natas5.natas.labs.overthewire.org, which is currently inaccesible. Going to the network tab of dev tools and editing the inital request by adding the Referer header with the required URL and resending it will provide the flag in the response

## natas5
Flag: aGoY4q2Dc6MgDq4oL4YtoKtyAg9PeHa1

There is a cookie called loggedin which has a value of 0. Changing it to 1 and refreshing the page grants access to the flag

## natas6
Flag: 7z3hEENjQtflzgnT29q7wAvMNfZdh0i9

View source code, see the secret needed to get the flag is in “includes/secret.inc”. Navigate to /includes/secret.inc in browser, view source and get the secret. Go back to form and submit secret to get flag.

## natas7
Flag: DBfUBfqQG69KvJvJ1iAbMoIpwSNQ9bWe

Notice that for each page we visit (home, about) the ?page= query string in the URL is changed. The comment in the HTML tells us that the flag is in /etc/natas_webpass/natas8. Changing the page query string to be /etc/natas_webpass/natas8 reveals the flag.

## natas8
Flag: W0mMhUcRRnG8dcghE4qvk3JA9lGt8nDl

Look at source

whatever you put into the input goes through

base64 encoding
string reversing
conversion from binary to hex

and then compared with the encoded secret. So to get the secret we have to go in the reverse order:

convert encoded string from hex to binary (can use bytes.fromhex in python)
reverse the string (string[::-1] in python)
then base64 decode it (base64 -d)

then take the result, submit it in the input and get the flag.

## natas9
Flag: nOpp1igQAkUzaI1GUUjzn1bFVj7xCNzu

Looking at source code, query is used in system command grep -i $key dictionary.txt. Can do command injection by inputting stuff;cat /etc/natas_webpass/natas10; To get the flag. the ; ends the statement, allowing us to put a new command, which we use to cat out the contents of /etc/natas_webpass/natas10

## natas10
Flag: U82q5TCMMQ9xuFoI3dYX61s7OZD9JKoK

Like natas9, but we can't end the command this time. What we can do though is enter our input such that the search term grep will look for will be empty (by entering ‘’) and including /etc/natas_webpass/natas11 as a file for grep to search in

so entering “ ‘’ /etc/natas_webpass/natas11” into the search box will show us the flag at the top of the results

## natas11
Flag: EDXp0pS26wLKHZy1rDBPUZk0RKfLGIR3

base64 decode the cookie ‘data’ value first, notice the default of  '{"showpassword":"no","bgcolor":"#ffffff"}' can use it to find key by XORing it with the base64 decoded data which is ‘qwJ8’ then XOR encode the default but with showpassword set to yes instead, base64 encode that and replace the data value in the cookie with it

desired cookie is ClVLIh4ASCsCBE8lAxMacFMOXTlTWxooFhRXJh4FGnBTVF4sFxFeLFMK

see natas11.py

