# SOFTWARE DESIGN
## The Architecture Decision
**CPSOFT30**  
**Course:** Software Engineering — Architectural Design  
**Grouping:** Existing Capstone Teams  
**Duration:** 90–120 minutes  
**Mode:** Applied case work on the team's own capstone system  

---

### 1. Learning Objective
By the end of this activity, each team will have made and justified eight real architectural decisions for their own capstone project, translated one of those decisions into a working code snippet, and defended the trade-offs to peers.

| # | Decision Question |
| :-: | :--- |
| **1** | Is there a generic application architecture that can act as a template? |
| **2** | How will the system be distributed across hardware cores/processors? |
| **3** | What architectural patterns or styles might be used? |
| **4** | What strategy will be used to control the operation of the components? |
| **5** | What will be the fundamental approach used to structure the system? |
| **6** | How will structural components be decomposed into sub-components? |
| **7** | What architectural organization best delivers the non-functional requirements? |
| **8** | How should the architecture be documented? |

---

### 2. Activity Guide & Framing
**Phase 1 — System Framing Problem Statement:**  
> *"E-Parada is an integrated smart parking reservation and management system that connects drivers seeking parking with space providers and facility administrators; under peak load, the system processes concurrent slot availability queries, instant checkouts with PayMongo payments, and real-time GPS map queries, while mobile clients handle QR checkpoint validations, live calling, and offline parking pass caching."*

---

## 5. Architecture Decision Canvas (fill per team)

**TEAM:** E-Parada Capstone Team  
**CAPSTONE PROJECT:** E-Parada Smart Parking Management System (`e_parada_mobile`)  

---

### [1] GENERIC ARCHITECTURE / TEMPLATE
| Field | Response |
| :--- | :--- |
| **Decision:** | **Multi-Tier Client-Server Architecture with Centralized RESTful Cloud API & SaaS Gateway Integration** |
| **Evidence from our project:** | Flutter mobile app (`e_parada_mobile`) acts as the client tier communicating via JSON/HTTPS endpoints in `ApiConfig` with a centralized backend API (`/api/driver/*`, `/api/owner/*`, `/api/admin/*`) and third-party gateways (PayMongo for payments, OpenStreetMap / Google Maps for geolocation). |
| **Rejected alternative:** | **Peer-to-Peer (P2P) Architecture.** Rejected because parking slot availability, pricing schedules, and financial transactions require an authoritative single source of truth to prevent concurrency collisions (double-booking). |

---

### [2] DISTRIBUTION ACROSS HARDWARE / PROCESSES
| Field | Response |
| :--- | :--- |
| **Decision:** | **Distributed Hybrid Processing: Client-Side Edge Execution + Central Application Server + Cloud Gateways** |
| **Evidence from our project:** | Compute is distributed between the mobile device (Flutter VM handling map rendering, QR pass generation via `qr_flutter`, camera scanning via `mobile_scanner`, local encrypted pass storage via `SharedPreferences`), backend server (scheduling, auth), and PayMongo webhooks. |
| **Rejected alternative:** | **Pure Thin-Client / Web-Only Streaming (Server-Side Rendering).** Rejected because drivers entering low-connectivity underground parking garages must retain offline access to cached QR parking passes and native hardware features (camera/GPS) without constant server roundtrips. |

---

### [3] ARCHITECTURAL PATTERN / STYLE
| Field | Response |
| :--- | :--- |
| **Decision:** | **Layered Architectural Pattern (Presentation Layer $\rightarrow$ Service / Business Logic Layer $\rightarrow$ Data / API Transport Layer)** |
| **Evidence from our project:** | Mobile app enforces strict layer separation: UI screens (`ReserveParkingScreen`, `MapScreen`, `VehicleGarageScreen`) never touch HTTP/DB directly; they delegate to isolated service classes (`ReservationService`, `PaymongoService`), which format DTOs and call `ApiClient`. |
| **Rejected alternative:** | **Microkernel / Plugin Architecture.** Rejected because parking reservation, vehicle garage, and payment workflows are tightly integrated core domains rather than independent third-party plugins; layered design yields clean separation with minimal orchestration cost. |

---

### [4] CONTROL STRATEGY (how components trigger/coordinate each other)
| Field | Response |
| :--- | :--- |
| **Decision:** | **Top-Down Asynchronous Call-and-Return with Reactive Local State & Periodic Polling** |
| **Evidence from our project:** | Primary transactions (booking a slot, initiating PayMongo payment) use explicit `Future/async-await` calls from UI to Service to `ApiClient`. Status updates (payment verification, background reservation reminders) use periodic polling and reactive listeners. |
| **Rejected alternative:** | **Pure Event-Driven Architecture (EDA) with Global WebSocket Message Bus.** Rejected due to unstable mobile cellular handoffs that cause socket drops; standard REST request-reply with idempotent retry mechanisms provides superior transaction reliability. |

---

### [5] FUNDAMENTAL STRUCTURING APPROACH
| Field | Response |
| :--- | :--- |
| **Decision:** | **Feature-Driven Layered Modularity with Role-Based Domain Segregation** |
| **Evidence from our project:** | Codebase is organized into structural layers (`screens/`, `widgets/`, `services/`, `models/`, `config/`, `utils/`) segregated by user roles (Driver, Owner/Provider, Administrator). |
| **Rejected alternative:** | **Monolithic Screen-Centric Coupling (combining UI layout, network calls, and business logic inside single `StatefulWidget` classes).** Rejected because it prevents automated unit testing, duplicates authentication logic, and causes severe merge conflicts. |

---

### [6] DECOMPOSITION INTO SUB-COMPONENTS
| Field | Response |
| :--- | :--- |
| **Decision:** | **Specialized Service & Repository Decomposition with Dedicated Data Transfer Objects (DTOs)** |
| **Evidence from our project:** | Business capabilities are partitioned into isolated services: `ReservationService`, `PaymongoService`, `OfflineParkingPassService`, `VehicleService`, and `ApiClient`, each consuming structured DTO models (`DriverReservation`, `ReservationAvailability`, `OfflinePassData`). |
| **Rejected alternative:** | **God-Object / Universal AppManager Service.** Rejected because coupling authentication, mapping, WebRTC calling, and payment processing into one class causes tight coupling, memory overhead, and high regression risks. |

---

### [7] ARCHITECTURE FOR NON-FUNCTIONAL REQUIREMENTS (rank top 10 NFRs)
| Field | Response |
| :--- | :--- |
| **Decision:** | **Prioritize Data Consistency, Security, and Offline Resilience over Distributed Complexity** |
| **Evidence from our project:** | 1. **Data Consistency** (atomic slot locking) <br>2. **Security** (Bearer tokens, PayMongo secrets) <br>3. **Offline Resilience** (`OfflineParkingPassService` cached passes) <br>4. **Response Time** (< 1.5s slot query) <br>5. **Maintainability** <br>6. **Fault Tolerance** <br>7. **Portability** (Android/iOS/Web) <br>8. **Scalability** <br>9. **Usability** <br>10. **Testability** |
| **Rejected alternative:** | **Optimistic Client-Side Booking without Pre-Reservation Locks.** Rejected because physical parking spots are strictly finite; optimistic booking creates double-booking disputes. |

---

### [8] DOCUMENTATION APPROACH (e.g., UML diagram, Version Controls)
| Field | Response |
| :--- | :--- |
| **Decision:** | **Multi-View Architectural Documentation via C4 Model, Flowcharts, ADRs, & Version Control** |
| **Evidence from our project:** | Architecture is documented using version-controlled diagrams in the repository (`e_parada_activity_diagram.drawio`, `e_parada_system_flowchart.drawio`, drawio scripts) and modular markdown specification documents. |
| **Rejected alternative:** | **Informal / Tribal Knowledge Documentation.** Rejected because capstone defense, role-based security audits, and multi-developer handoffs require explicit, reviewable models. |

---

## 6. Decision Matrix

Score each candidate 1–5 against the team's own top NFRs (pulled from Canvas Box 7). Weight = how much that NFR matters to this capstone (1–10). Use the Document Convention for easy traversal.

| Non-Functional Requirement | Weight | Candidate A:<br>Layered Client-Server | Candidate A:<br>Weighted Score | Candidate B:<br>Microservices / EDA | Candidate B:<br>Weighted Score |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Data Consistency** | 10 | 5 | 50 | 3 | 30 |
| **Security & Payments** | 9 | 5 | 45 | 4 | 36 |
| **Offline Resilience** | 8 | 4 | 32 | 3 | 24 |
| **Response Time** | 8 | 4 | 32 | 4 | 32 |
| **Maintainability** | 9 | 5 | 45 | 2 | 18 |
| **Fault Tolerance** | 7 | 4 | 28 | 4 | 28 |
| **Development Velocity** | 9 | 5 | 45 | 2 | 18 |
| **Testability** | 8 | 5 | 40 | 3 | 24 |
| **Scalability** | 6 | 3 | 18 | 5 | 30 |
| **Resource Efficiency** | 7 | 5 | 35 | 2 | 14 |
| **Weighted Total** | **81** | — | **370** | — | **254** |

**Decision rule:** highest weighted total wins unless the team can justify overriding it (and must write that justification on the Canvas).  
**Justification:** **Candidate A wins (370 vs. 254).** Candidate A provides immediate transactional consistency to prevent double-booking, lower infrastructure complexity, and faster development velocity for the mobile capstone team.

---

## 7. Code Snippet (Proving the Architecture)

The following code snippet demonstrates the structural consequence of our **Box 3 (Layered Architecture)**, **Box 6 (Decomposition)**, and **Box 4 (Top-Down Asynchronous Control Strategy)** in E-Parada's actual Flutter/Dart tech stack:

```dart
// === Decision being demonstrated ===
// Box 3: Layered architecture (Presentation -> Service -> ApiClient)
// Box 4: Control strategy = top-down asynchronous invocation (Future / await)
// Box 6: Structural decomposition = UI delegates booking logic to ReservationService

// -- Presentation layer: lib/screens/reserve_parking_screen.dart --
class ReserveParkingScreenState {
  Future<void> onConfirmBooking(int spaceId, int vehicleId, int slotId) async {
    try {
      final message = await ReservationService.createReservation(
        parkingSpaceId: spaceId, vehicleId: vehicleId, parkingSlotId: slotId,
      );
      showSuccessBanner(message);
    } on ApiException catch (err) {
      showErrorBanner(err.message);
    }
  }
}

// -- Business logic layer: lib/services/reservation_service.dart --
class ReservationService {
  static Future<String> createReservation({
    required int parkingSpaceId, required int vehicleId, required int parkingSlotId,
  }) async {
    final response = await ApiClient.postJson(
      'driver/parking-spaces/$parkingSpaceId/reservations',
      body: {'vehicle_id': vehicleId, 'parking_slot_id': parkingSlotId},
    );
    ApiClient.requireStatus(response, const {201});
    return ApiClient.decodeObject(response)['message'] ?? 'Reservation submitted.';
  }
}

// -- Data layer: lib/services/api_client.dart --
class ApiClient {
  static Future<http.Response> postJson(String path, {Map<String, dynamic>? body}) =>
      http.post(ApiConfig.endpoint(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  static void requireStatus(http.Response res, Set<int> valid) {
    if (!valid.contains(res.statusCode)) throw ApiException(jsonDecode(res.body)['message'] ?? 'Request failed');
  }
}
```

**What makes this a demonstration of the decision, not just code:**  
The Presentation layer (`ReserveParkingScreenState`) never touches HTTP or database queries directly (enforcing Box 6 decomposition), and control flows top-down through explicit `async/await` function calls rather than uncoordinated global event buses (proving the Box 4 choice).

---

## 8. Checklist (Per Team)
- [x] Completed Architecture Decision Canvas (all 8 boxes, no blank "TBD")
- [x] Completed Decision Matrix with weighted scoring
- [x] Code snippet (10–25 lines) proving the chosen pattern + control strategy, in their actual capstone stack
- [x] Consolidated file (PDF / Markdown / HTML)
