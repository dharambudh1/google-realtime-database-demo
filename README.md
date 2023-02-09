# Firebase Realtime Database

## Features:
- Live Data Manipulation in UI (Live Data Stream),
- Local Storage (Persistent Storage - Sign-in & Sign-out functionality), 
- OTP auto-fill (Works on Android only),
- Google Analytics (User info, Demographic info, App info, Pages and screens info & Event info)
- Google Crashlytics (If caught an exception or If an error occurred) 
- App Check (Android: Play Integrity & SafetyNet)
- Material 3 UI element, along with the system-wide multi-theme support (I used Flutter 3.7.0 at this time)

## Scenarios:
1. While Sign-in
- Check if the email exists in DB
- Check if the phone number exists in DB
- Can log in with email & password (default) Or phone & password (if the user has verified phone number)
- AES (CBC) cryptographic function for password decryption

2. While Sign-up
- Check if the email already exists in DB
- Check if the phone number already exists in DB
- Ability to skip phone verification so they can verify afterwards
- AES (CBC) cryptographic function for password encryption

3. While Home Screen
- Users can verify the phone number if they skip at Sign-up screen.

## DB Structure (as JSON):
- https://www.jsonkeeper.com/b/2M39 

## Preview
![alt text](https://i.postimg.cc/G292grjz/imgonline-com-ua-twotoone-x-IK7-Xdm2-VZ.png "img")
