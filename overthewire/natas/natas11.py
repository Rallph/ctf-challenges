import base64
import binascii

stuff = 'ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw='

decoded_stuff = base64.b64decode(stuff)
original = '{"showpassword":"no","bgcolor":"#ffffff"}'

print(decoded_stuff.decode())

key = ""

for i in range(len(decoded_stuff)):
    key += chr(decoded_stuff[i] ^ ord(original[i]))

key = key[0:4]

print(f"key is {key}")

print("encoding cookie with showpassword set to yes")
modded_value = '{"showpassword":"yes","bgcolor":"#ffffff"}'

xored_modded = bytearray()

for i in range(len(modded_value)):
    xored_modded.append(ord(modded_value[i]) ^ ord(key[i % len(key)]))

encoded_modded = binascii.b2a_base64(xored_modded)

print(encoded_modded)




