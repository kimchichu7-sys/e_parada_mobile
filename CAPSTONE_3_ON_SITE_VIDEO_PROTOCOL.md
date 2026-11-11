# E-Parada: Capstone 3 On-Site Video Evidence & Field Testing Protocol

**Project:** *E-Parada: A Digital Marketplace for Parking Spaces*  
**Document Type:** Field Deployment Guide, Video Production Storyboard & Demonstration Script  
**Proponents:** Bustria, Christian Jake C. | Gamad, Leticia C. | Ovilla, Shan Jenis C. | Valiña, Resha Lorraine P.  
**Institution:** College of Engineering and Architecture, National University (NU) Laguna  
**Evaluation Scope:** Capstone 3 Defense Compliance (Panel Directive: On-Site Video Demonstration)  

---

## 1. Executive Directive & Panel Compliance

During the proposal defense evaluation (`E-Parada.m4a`), the lead thesis panelist issued an unambiguous mandate:
> 🎙️ **Lead Panelist:** *"Kumuha kayo ng VIDEO, hindi lang picture! Kailangan videohan ninyo na ginagamit nila yung system sa actual parking space. Pagbalik niyo sa Capstone 3 at walang video, papaulitin ko kayo ng defense!"*

### Core Objectives:
1. **Prove Physical Operational Feasibility:** Demonstrate that E-Parada functions in real-world, high-density parking environments in Calamba City, Laguna.
2. **Validate Two-Way Handshake & QR Scanning:** Capture continuous, uncut footage of physical vehicles arriving at a gate, the attendant scanning the driver's dynamic entry QR code, and instantaneous automated check-in.
3. **Demonstrate Part 2 System Engineering Revisions:**
   - 1-Hour Downpayment via GCash PayMongo and automated gate pass unlocking.
   - 60-Minute No-Show Cancellation and fee forfeiture protection for space owners.
   - Exit check-out showing duration calculation, deduction of the 1-hour downpayment, and net balance settlement.
   - Batch slot configuration ("Select All") for parking space providers.
   - Two-factor KYC asset verification (OR/CR + Barangay Clearance).

---

## 2. Equipment, Assets & Production Logistics

### A. Hardware & Camera Equipment
| Item | Recommended Specification | Purpose |
| :--- | :--- | :--- |
| **Primary Camera** | Smartphone (1080p @ 60fps or 4K) with optical stabilization or gimbal | Capturing establishing wide shots, vehicle approach, and gate interactions. |
| **Secondary Camera / Close-up** | Smartphone mounted on a mini tripod | Recording close-up over-the-shoulder screen interactions (QR scanning, GCash payment). |
| **Direct Screen Recorders** | Built-in Android / iOS Screen Recorder (1080p @ 60fps) | High-definition digital video capture on both Provider and Driver devices. |
| **Audio Setup** | Wireless lavalier microphone (Type-C / Lightning) | Clear vocal dialogue from the Driver and Provider despite road and engine noise. |
| **Vehicles** | 1 Private Car / SUV (e.g., Toyota Vios or Fortuner) + 1 Motorcycle (e.g., Honda Click) | Demonstrating multi-vehicle support with valid LTO plates. |
| **Physical Collateral** | Printed QR Signage, LTO OR/CR paper copy, Barangay Clearance document | Authentic physical documents for KYC and gate verification. |

### B. Field Locations in Calamba City, Laguna
Select at least **two authentic locations** from the approved operational perimeter:
1. **Location 1 (Commercial / Multi-Slot Lot):** Commercial plaza or parking compound near SM City Calamba / Brgy. Real (Demonstrating multi-slot batch configuration and attendant gate scanning).
2. **Location 2 (Residential / Driveway Lot):** Private gated driveway or vacant commercial lot in Brgy. Halang or Brgy. Bucal (Demonstrating peer-to-peer residential parking and off-street parking discovery).

### C. Proponent Role Allocation
- **Driver (Motorist Actor):** Christian Jake C. Bustria (Operating Driver Mobile App on Android Device B).
- **Parking Space Provider (Attendant Actor):** Resha Lorraine P. Valiña / Roberto Santos (Operating Provider Mobile App on Android Device A).
- **System Administrator (Auditor):** Shan Jenis C. Ovilla (Operating Admin Web Portal on Laptop).
- **Director & Lead Videographer:** Leticia C. Gamad (Directing camera angles, audio levels, and scene continuity).

---

## 3. Comprehensive Scene-by-Scene Storyboard & Script

### Scene 1: Parking Space Provider Onboarding & Batch Slot Setup
* **Location:** Provider office desk or lot entrance table in Calamba City.
* **Duration:** 25 seconds.
* **Camera Angle:** Medium close-up of Provider holding smartphone, transitioning to over-the-shoulder shot.
* **App State:** Provider Mobile App (`owner_space_form_screen.dart`).

```
[VISUAL]
1. Provider opens E-Parada Owner Portal.
2. Taps "Add New Parking Space". Enters "Halang Commercial Plaza Parking", sets location pin in Brgy. Halang, Calamba City.
3. Uploads official Barangay Clearance and Government ID.
4. Enters "15 Slots". Instead of tapping slots individually, Provider taps the new "Select All Slots" toolbar button.
5. Provider selects "All Allowed Types" (Car, SUV, Motorcycle) with one tap. All 15 slot cards update synchronously.
6. Submits space for administrative KYC verification.

[AUDIO / DIALOGUE - Provider]
"Dati, mano-mano naming kiniclick ang bawat parking slot. Ngayon gamit ang bagong 'Select All' batch feature ng E-Parada, isang pindot lang, configured na agad ang lahat ng 15 parking slots kasama ang barangay clearance para sa KYC verification."
```

---

### Scene 2: Administrative Two-Factor KYC Audit
* **Location:** Office setup with laptop / tablet.
* **Duration:** 20 seconds.
* **Camera Angle:** Screen capture with picture-in-picture of Admin auditor.
* **App State:** Admin Web Portal (`AdminOperationsApiController.php` & 4-Way Audit Grid).

```
[VISUAL]
1. Admin receives real-time notification: "New Parking Space & Vehicle Pending Review".
2. Admin opens 4-Way Verification Grid:
   - Panel 1: Live Plate Photo with OCR text overlay.
   - Panel 2: Uploaded LTO Certificate of Registration (CR).
   - Panel 3: Uploaded LTO Official Receipt (OR) for current year.
   - Panel 4: Calamba Barangay Clearance and Driver's License.
3. Admin clicks green [Approve Space] and [Approve Vehicle] buttons. Instant green confirmation toast appears.

[AUDIO / DIALOGUE - Admin]
"Upang maiwasan ang carnapping at ilegal na compound, bawat sasakyan at parking space ay dumadaan sa mahigpit na two-factor KYC audit. Kapag nagtugma ang LTO OR/CR, plaka, at barangay clearance, maaari na itong ma-approve."
```

---

### Scene 3: Driver Discovery & Mandatory 1-Hour Downpayment Booking
* **Location:** Inside vehicle (parked curbside or at origin location in Calamba).
* **Duration:** 35 seconds.
* **Camera Angle:** Interior windshield mount showing Driver operating smartphone, with direct screen recording overlay.
* **App State:** Driver Mobile App (`reserve_parking_screen.dart` -> GCash Checkout).

```
[VISUAL]
1. Driver opens E-Parada map, searches "Parking near Real, Calamba".
2. Nearby parking spaces appear as interactive map pins with rates and available slots.
3. Driver selects "Halang Commercial Plaza", picks Slot 04 (Car / SUV), and sets reservation schedule.
4. Downpayment Policy Dialog appears:
   "Notice: 1-Hour Downpayment (₱45.00) required to secure slot. 60-minute arrival grace period applies."
5. Driver confirms and selects "Pay via GCash (PayMongo)".
6. Seamlessly redirects to PayMongo GCash checkout session. Driver completes payment.
7. Webhook fires instantly; status transitions to "Approved (Active)".
8. High-contrast dynamic HMAC-signed Entry QR Gate Pass unlocks and renders on screen.

[AUDIO / DIALOGUE - Driver]
"Para maiwasan ang no-show at masiguradong may slot pagdating ko, nagbabayad ako ng 1-hour downpayment gamit ang GCash via PayMongo. Pagka-confirm ng payment, automatic nang unlocked ang aking dynamic Entry QR Pass."
```

---

### Scene 4: Physical Arrival & Contactless Gate Check-In
* **Location:** Physical entrance of the parking facility in Calamba City.
* **Duration:** 35 seconds.
* **Camera Angle:** Dual-camera setup:
  - Camera A: Wide shot of vehicle pulling up to the gate.
  - Camera B: Tight close-up of Attendant holding phone with camera scanner pointed at Driver's phone screen through vehicle window.
* **App State:** Provider Checkpoint Scanner (`mobile_scanner` in `owner_checkpoint_screen.dart`).

```
[VISUAL]
1. Driver's car pulls up to parking gate barrier.
2. Driver holds up the illuminated Entry QR Code Pass on smartphone.
3. Parking Attendant aims E-Parada QR scanner.
4. Scanning beep / vibration fires instantaneously (< 400ms latency).
5. Provider screen flashes emerald green banner:
   "VALID ENTRY: Toyota Fortuner (NBI 9999) - Slot 04. Check-In Time: 14:15."
6. Physical gate / barrier opens; car smoothly drives into designated slot.
7. Driver's app immediately updates to "Currently Parked" with live duration timer.

[AUDIO / DIALOGUE - Provider]
"Pagdating ng driver sa gate, ini-scan lang namin ang Entry QR pass gamit ang smartphone camera. Walang manual logbook, automated ang time-in at nakikita agad ang plaka at slot number."
```

---

### Scene 5: 60-Minute No-Show Grace Period & Auto-Cancellation Rule
* **Location:** Parking slot area showing empty slot with digital countdown graphic.
* **Duration:** 20 seconds.
* **Camera Angle:** Split-screen showing empty slot and the Admin/Provider Telemetry dashboard.
* **App State:** Backend Cron Scheduler (`CancelNoShowReservations.php` telemetry).

```
[VISUAL]
1. Animated graphic depicting the 60-minute arrival countdown after scheduled start time.
2. Graphic demonstrates what happens if driver fails to scan within 60 minutes:
   - System auto-triggers NoShowService command.
   - Reservation status transitions to [Cancelled (No-Show)].
   - Slot is instantly unlocked and returned to public search pool.
   - 1-hour downpayment is forfeited and credited to owner's accumulated payout wallet.

[AUDIO / VOICE-OVER]
"Kapag hindi nakarating ang driver sa loob ng 60 minuto matapos ang takdang oras, awtomatikong kinakansela ng system ang booking. Muling mabubuksan ang slot para sa ibang motorista, at ang 1-hour downpayment ay mapupunta sa may-ari ng parking bilang kabayaran sa oras."
```

---

### Scene 6: Vehicle Exit, Net Balance Settlement & Digital Receipt
* **Location:** Exit gate of the parking lot.
* **Duration:** 35 seconds.
* **Camera Angle:** Medium close-up of Driver and Provider at exit barrier.
* **App State:** Exit Dialog (`reservation_action_dialogs.dart` & `QrValidationController.php`).

```
[VISUAL]
1. Vehicle pulls up to exit gate. Driver presents Exit QR Pass.
2. Attendant scans Exit QR Code.
3. Exit Settlement Dialog displays clear financial breakdown:
   - Gross Parking Duration: 3 Hours (₱135.00)
   - Less 1-Hour Downpayment Paid: -₱45.00 (in emerald green)
   - Net Balance Payable: ₱90.00
4. Driver settles net balance via Cash (Attendant taps [Confirm Cash Received]) or scan-to-pay GCash QR.
5. Exit validated; barrier opens.
6. Driver's app displays digital payment receipt and 5-star rating feedback prompt.
7. Driver submits 5-star review: "Very secure and fast checkout!"

[AUDIO / DIALOGUE - Driver & Provider]
Provider: "Sir, 3 hours total po kayo. Minus na po ang inyong ₱45 downpayment, kaya ₱90 na lang po ang balance."
Driver: "Salamat po! Bayaran ko po ng cash."
Provider: "Payment confirmed, thank you for parking with E-Parada!"
```

---

## 4. Post-Production & Video Editing Standards

To ensure maximum credibility and technical polish during the Capstone 3 defense:

1. **Resolution & Framing:** Full HD (1920x1080) at 60 fps, 16:9 widescreen format.
2. **Audio Mixing:** Dialogue must be normalized between -6dB and -3dB. Background ambient noise should be suppressed using audio noise gates.
3. **Screen Inserts (Picture-in-Picture):** When physical actions occur (e.g. scanning QR at car window), overlay the crisp, digital screen recording in the top-right or lower-third corner so panelists see both physical reality and mobile UI synchronously.
4. **On-Screen Graphic Badges:**
   - Add clean animated lower-thirds indicating:
     - `FEATURE: Batch Slot Configuration (Select All)`
     - `SECURITY: Two-Factor KYC (OR/CR & Barangay Clearance)`
     - `FINANCIAL ENGINE: 1-Hour Downpayment & 60-Min No-Show Rule`
     - `CHECK-IN: Contactless QR Gate Pass Validation`
5. **Target Duration:** Exactly **2 minutes and 30 seconds to 3 minutes** (concise, high-energy, and free of long awkward pauses).

---

## 5. Defense Presentation Protocol (Live Cue Sheet)

When presenting the video to Doctora and the Capstone 3 panel:

| Presentation Time | Action / Slide | Talking Point for Presenters |
| :--- | :--- | :--- |
| **00:00 - 00:30** | Slide: Response to Panel Critiques | *"During our proposal defense, the panel mandated strict on-site video verification and structural engineering revisions. We are pleased to present our field-tested implementation in Calamba City."* |
| **00:30 - 03:00** | Play 1080p Video Evidence | Presenters remain attentive while video audio plays clearly over defense speakers. |
| **03:00 - 04:00** | Transition to 3-Device Live Demo | *"Now that you have seen the on-site physical deployment, we will demonstrate the live, synchronous multi-device handshake using our 3-device evaluation setup."* |

---
*Protocol ratified for E-Parada Capstone 3 Field Execution | NU Laguna College of Engineering and Architecture*
