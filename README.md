# BloodLink 🩸

A minimal iOS blood donation app built with SwiftUI that connects blood donors
with seekers in real time based on location, blood type, and availability.

---

## Features

### Donor
- Register with passport name, blood group, sex, age (18+ enforced), height, weight, and BMI
- Sign in with Apple ID or Google only — no passwords
- Online / offline availability toggle
- Automatically goes offline for 90 days after a confirmed donation
- Upload government ID or passport for verification
- Upload and share blood test reports

### Seeker
- Search for donors by blood type and custom radius
- See only donor name, location, and blood type (privacy protected)
- Set notification radius — alert nearby donors instantly
- View navigation route to donor

### Communication
- Anonymous in-app chat — no phone numbers shared
- Anonymous in-app calling via relay service
- Push notifications for blood requests

### Platforms
- iOS 17+
- iPadOS 17+
- watchOS 10+ *(planned)*
- CarPlay *(planned)*

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Auth | Sign in with Apple · Google Sign-In SDK |
| Database | Firebase Firestore |
| Storage | Firebase Storage |
| Push notifications | Firebase Cloud Messaging (FCM) |
| Location | CoreLocation (background mode) |
| Maps & routing | MapKit |
| Anonymous comms | Twilio Programmable Voice & Chat |

---

## Project Structure
