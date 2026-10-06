import os
import zipfile
from docx_helpers import (
    make_p, make_runs_p, make_code_block, make_callout, make_header_box,
    make_section_title, make_table_2col, make_table_header, escape
)

def build_new_document():
    body_elements = []

    # Title Box
    body_elements.append(make_header_box(
        title="The Design Pattern Refactor Lab (Set 2)",
        subtitle="Applied Refactor of E-Parada Smart Parking System using 5 Alternative Gang-of-Four Patterns",
        metadata="Capstone Project: E-Parada Mobile (ph.eparada.mobile) | Tech Stack: Flutter / Dart 3.x"
    ))

    body_elements.append(make_p("1. Activity Overview & Objectives", bold=True, size=24, color="1E3A8A", space_before=160, space_after=80))
    body_elements.append(make_p(
        "This document provides five completely different GoF design pattern refactorings for the E-Parada Smart Parking System, "
        "addressing five new code areas in our codebase: Decorator (Pricing/Fees), Template Method (API Resource Operations), "
        "Adapter (Payment Gateway Integration), Builder (Complex Route Construction), and Command (Offline Action Queueing).",
        size=20, color="334155"
    ))

    # =========================================================================
    # PATTERN 1: DECORATOR PATTERN (Structural)
    # =========================================================================
    body_elements.append(make_section_title("PATTERN 1:", "Decorator Pattern (Structural) — Parking Fee & Surcharge Calculation"))

    worksheet_rows_1 = [
        ("Symptom we found in our own code:",
         "Monolithic Fee String Concatenation & Inflexible Pricing\n\n"
         "• Exact File: lib/widgets/digital_receipt_dialog.dart & lib/widgets/live_overstay_tracker_card.dart\n"
         "• Method: _buildOfficialInvoiceText(), lines 105–155; _calculateOverstayFee(), lines 127–132\n"
         "• Code Smell: Hardcoded, monolithic fee string concatenation and manual inline calculations for base parking fee, EVAT 12%, and overstay surcharge. If E-Parada adds new pricing modifiers (e.g., peak-hour surge, EV charging surcharge, or senior citizen discounts), developers must modify multiple conditional blocks and string templates, leading to pricing inconsistencies across the app."),
        ("Pattern we chose (sample list or full catalog):",
         "Decorator Pattern (Covered in class & full GoF catalog)"),
        ("Category (Creational / Structural / Behavioral):",
         "Structural"),
        ("Non-software analogy:",
         "Stamping Additional Fee & Discount Seals on a Physical Parking Pass:\n\n"
         "When a motorist enters a multi-level parking facility, they receive a plain base parking ticket. If the motorist parks past their scheduled time, the exit cashier stamps a red 'Overstay Surcharge' seal onto the pass. If they charge an electric vehicle at a bay, the attendant stamps a blue 'EV Power Surcharge' seal. If they present a senior citizen card, a green '20% Discount' seal is applied. The physical ticket pass dynamically accumulates additional financial responsibilities on the fly without issuing a completely new class of physical ticket for every possible combination.")
    ]
    body_elements.append(make_p("6. Pattern Selection Worksheet (Decorator Pattern)", bold=True, size=20, color="1E3A8A", space_before=100, space_after=60))
    body_elements.append(make_table_2col(worksheet_rows_1))

    body_elements.append(make_p("7. Refactor Worksheet", bold=True, size=22, color="1E3A8A", space_before=140, space_after=60))

    before_code_1 = """// lib/widgets/digital_receipt_dialog.dart (BEFORE - lines 105-148)
// SMELL: Hardcoded tax calculations and manual string concatenation for fee items
double get _baseNetVat => totalAmount > 0 ? (totalAmount / 1.12) : 0.0;
double get _evat12 => totalAmount > 0 ? (totalAmount - _baseNetVat) : 0.0;

String _buildOfficialInvoiceText() {
  return '''
[ITEMIZED TAX BREAKDOWN]
1. Base Parking Fare (VAT-Excl):    PHP ${_baseNetVat.toStringAsFixed(2)}
2. 12% Value Added Tax (EVAT):     PHP ${_evat12.toStringAsFixed(2)}
${overstayMinutes > 0 ? '3. Overstay Surcharge ($overstayMinutes mins):  PHP ${overstayAmount.toStringAsFixed(2)}\\n' : ''}--------------------------------------------------
TOTAL AMOUNT PAID:                 PHP ${totalAmount.toStringAsFixed(2)}''';
}"""
    body_elements.append(make_p("BEFORE — paste your team's real, current code:", bold=True, size=20, color="1E3A8A", space_before=60, space_after=40))
    body_elements.append(make_code_block(before_code_1))

    after_code_1 = """// lib/models/parking_fee_decorator.dart (AFTER - Decorator Pattern)

/// The Component Interface
abstract class ParkingFeeComponent {
  double get totalAmount;
  List<String> getLineItems();
}

/// The Concrete Component: Core base hourly rate
class BaseParkingFee implements ParkingFeeComponent {
  const BaseParkingFee({required this.hourlyRate, required this.hours});
  final double hourlyRate;
  final double hours;

  @override
  double get totalAmount => hourlyRate * hours;

  @override
  List<String> getLineItems() => [
    'Base Parking Fare (${hours.toStringAsFixed(1)} hrs @ ₱${hourlyRate.toStringAsFixed(2)}/hr): ₱${totalAmount.toStringAsFixed(2)}'
  ];
}

/// The Base Decorator
abstract class ParkingFeeDecorator implements ParkingFeeComponent {
  const ParkingFeeDecorator(this.wrapped);
  final ParkingFeeComponent wrapped;

  @override
  double get totalAmount => wrapped.totalAmount;

  @override
  List<String> getLineItems() => wrapped.getLineItems();
}

/// Concrete Decorator 1: Overstay Surcharge
class OverstaySurchargeDecorator extends ParkingFeeDecorator {
  const OverstaySurchargeDecorator(super.wrapped, {required this.overstayMinutes, required this.ratePerHour});
  final int overstayMinutes;
  final double ratePerHour;

  double get overstayFee => (overstayMinutes / 60.0).ceil() * ratePerHour;

  @override
  double get totalAmount => wrapped.totalAmount + overstayFee;

  @override
  List<String> getLineItems() {
    return [
      ...wrapped.getLineItems(),
      'Overstay Surcharge ($overstayMinutes mins): +₱${overstayFee.toStringAsFixed(2)}',
    ];
  }
}

/// Concrete Decorator 2: 12% EVAT Breakdown
class EvatTaxDecorator extends ParkingFeeDecorator {
  const EvatTaxDecorator(super.wrapped);

  double get vatAmount => wrapped.totalAmount * 0.12;

  @override
  double get totalAmount => wrapped.totalAmount + vatAmount;

  @override
  List<String> getLineItems() {
    return [
      ...wrapped.getLineItems(),
      '12% Government EVAT: +₱${vatAmount.toStringAsFixed(2)}',
    ];
  }
}

/// Concrete Decorator 3: Senior / PWD / Promo Discount
class DiscountDecorator extends ParkingFeeDecorator {
  const DiscountDecorator(super.wrapped, {required this.discountPercent, required this.label});
  final double discountPercent; // e.g. 0.20 for 20%
  final String label;

  double get discountAmount => wrapped.totalAmount * discountPercent;

  @override
  double get totalAmount => wrapped.totalAmount - discountAmount;

  @override
  List<String> getLineItems() {
    return [
      ...wrapped.getLineItems(),
      '$label (-${(discountPercent * 100).toInt()}%): -₱${discountAmount.toStringAsFixed(2)}',
    ];
  }
}

// Client Usage: Dynamically compose fee modifiers at checkout:
ParkingFeeComponent fee = BaseParkingFee(hourlyRate: 30.0, hours: 2.0);
if (reservation.overstayMinutes > 0) {
  fee = OverstaySurchargeDecorator(fee, overstayMinutes: reservation.overstayMinutes, ratePerHour: 30.0);
}
fee = EvatTaxDecorator(fee); // Attach 12% VAT
if (hasSeniorDiscount) {
  fee = DiscountDecorator(fee, discountPercent: 0.20, label: 'Senior Citizen Discount');
}
print(fee.totalAmount); // Dynamically calculated total!"""
    body_elements.append(make_p("AFTER — your refactored version implementing the pattern:", bold=True, size=20, color="1E3A8A", space_before=100, space_after=40))
    body_elements.append(make_code_block(after_code_1))

    explanation_1 = (
        "• What structurally changed: Replaced hardcoded string templates and manual arithmetic with a composable ParkingFeeComponent hierarchy. Modifiers (overstay, EVAT, discounts, EV charging) wrap the base fee dynamically.\n"
        "• Why Decorator beats Subclassing: Subclassing would lead to a combinatorial explosion of rigid classes (e.g., BaseFeeWithOverstay, BaseFeeWithOverstayAndPromo, BaseFeeWithVatAndDiscount). Decorator allows arbitrary runtime composition with zero class bloat."
    )
    body_elements.append(make_callout(explanation_1, title="Structural Architecture & Trade-Off Defense"))

    # =========================================================================
    # PATTERN 2: TEMPLATE METHOD PATTERN (Behavioral)
    # =========================================================================
    body_elements.append(make_section_title("PATTERN 2:", "Template Method Pattern (Behavioral) — API Resource Operations"))

    worksheet_rows_2 = [
        ("Symptom we found in our own code:",
         "Repeated Service Request Boilerplate with Minor Variation\n\n"
         "• Exact File: lib/services/owner_operations_service.dart & lib/services/notification_service.dart\n"
         "• Method: fetchSpaces(), fetchSpace(), fetchInbox(), lines 42–65\n"
         "• Code Smell: Every single service method repeats the exact same 5 invariant steps: (1) acquire auth token, (2) format bearer headers, (3) execute HTTP call, (4) validate 200 OK status codes, and (5) catch and format API exceptions. Only two steps vary: the relative endpoint URI and the JSON deserializer."),
        ("Pattern we chose (sample list or full catalog):",
         "Template Method Pattern (Covered in class & full GoF catalog)"),
        ("Category (Creational / Structural / Behavioral):",
         "Behavioral"),
        ("Non-software analogy:",
         "A Standardized Vehicle Registration & Inspection Pipeline:\n\n"
         "When registering a motor vehicle at the Land Transportation Office (LTO), every vehicle must follow the exact same fixed sequential inspection pipeline: Step 1: Verify Ownership Papers $\rightarrow$ Step 2: Chassis & Engine Stenciling $\rightarrow$ Step 3: Smoke Emission Test $\rightarrow$ Step 4: Pay Processing Fee $\rightarrow$ Step 5: Issue Official Registration. The overall skeleton is 100% fixed, but Step 3 (the smoke test) defers its specific pass/fail threshold to subclasses depending on whether the vehicle is an electric scooter, a gasoline sedan, or a diesel delivery truck.")
    ]
    body_elements.append(make_p("6. Pattern Selection Worksheet (Template Method Pattern)", bold=True, size=20, color="1E3A8A", space_before=100, space_after=60))
    body_elements.append(make_table_2col(worksheet_rows_2))

    body_elements.append(make_p("7. Refactor Worksheet", bold=True, size=22, color="1E3A8A", space_before=140, space_after=60))

    before_code_2 = """// lib/services/owner_operations_service.dart (BEFORE - lines 42-62)
// SMELL: Every service repeats identical token extraction, headers, validation, and error decoding
static Future<List<OwnerParkingSpace>> fetchSpaces() async {
  final token = await AuthService.requireToken();
  final headers = AuthService.bearerHeaders(token);
  final response = await ApiClient.get('owner/parking-spaces', headers: headers);
  ApiClient.requireStatus(response, const {200});
  final body = ApiClient.decodeObject(response);
  return (body['parking_spaces'] as List).map(OwnerParkingSpace.fromJson).toList();
}

static Future<OwnerParkingSpace> fetchSpace(int parkingSpaceId) async {
  final token = await AuthService.requireToken();
  final headers = AuthService.bearerHeaders(token);
  final response = await ApiClient.get('owner/parking-spaces/$parkingSpaceId', headers: headers);
  ApiClient.requireStatus(response, const {200});
  final body = ApiClient.decodeObject(response);
  return OwnerParkingSpace.fromJson(body['parking_space']);
}"""
    body_elements.append(make_p("BEFORE — paste your team's real, current code:", bold=True, size=20, color="1E3A8A", space_before=60, space_after=40))
    body_elements.append(make_code_block(before_code_2))

    after_code_2 = """// lib/services/base_api_operation.dart (AFTER - Template Method Pattern)

/// Abstract base class defining the invariant algorithm skeleton
abstract class ApiOperation<T> {
  // === The Template Method (defines fixed skeleton) ===
  Future<T> execute() async {
    // Step 1: Invariant token retrieval
    final token = await AuthService.requireToken();
    // Step 2: Invariant header assembly
    final headers = AuthService.bearerHeaders(token);
    // Step 3: Defer endpoint URL to subclass
    final endpoint = getEndpoint();
    // Step 4: Execute HTTP call
    final response = await ApiClient.get(endpoint, headers: headers);
    // Step 5: Invariant status validation
    ApiClient.requireStatus(response, const {200});
    // Step 6: Decode JSON
    final body = ApiClient.decodeObject(response);
    // Step 7: Defer model parsing to subclass
    return parseResponse(body);
  }

  // Primitive operations deferred to subclasses:
  String getEndpoint();
  T parseResponse(Map<String, dynamic> json);
}

/// Concrete Subclass 1: Fetch list of owner parking spaces
class FetchOwnerSpacesOperation extends ApiOperation<List<OwnerParkingSpace>> {
  @override
  String getEndpoint() => 'owner/parking-spaces';

  @override
  List<OwnerParkingSpace> parseResponse(Map<String, dynamic> json) {
    return (json['parking_spaces'] as List)
        .map((e) => OwnerParkingSpace.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Concrete Subclass 2: Fetch single space details
class FetchSingleSpaceOperation extends ApiOperation<OwnerParkingSpace> {
  FetchSingleSpaceOperation(this.spaceId);
  final int spaceId;

  @override
  String getEndpoint() => 'owner/parking-spaces/$spaceId';

  @override
  OwnerParkingSpace parseResponse(Map<String, dynamic> json) {
    return OwnerParkingSpace.fromJson(json['parking_space'] as Map<String, dynamic>);
  }
}

// Client Usage:
final spaces = await FetchOwnerSpacesOperation().execute();"""
    body_elements.append(make_p("AFTER — your refactored version implementing the pattern:", bold=True, size=20, color="1E3A8A", space_before=100, space_after=40))
    body_elements.append(make_code_block(after_code_2))

    explanation_2 = (
        "• What structurally changed: Extracted the invariant authentication, header formatting, network transmission, and HTTP status checking into an abstract ApiOperation.execute() template method. Subclasses only supply the endpoint path and model deserializer.\n"
        "• Why Template Method beats Strategy: In Strategy, the client swaps completely different algorithms. In API operations, the algorithm skeleton (auth -> headers -> HTTP -> validate -> decode) is strictly fixed; only specific sub-steps vary."
    )
    body_elements.append(make_callout(explanation_2, title="Structural Architecture & Trade-Off Defense"))

    # =========================================================================
    # PATTERN 3: ADAPTER PATTERN (Structural)
    # =========================================================================
    body_elements.append(make_section_title("PATTERN 3:", "Adapter Pattern (Structural) — Third-Party Payment Gateway Integration"))

    worksheet_rows_3 = [
        ("Symptom we found in our own code:",
         "Incompatible Third-Party Interface & Data Structure Mismatch\n\n"
         "• Exact File: lib/services/paymongo_service.dart & lib/widgets/gcash_payment_gateway_dialog.dart\n"
         "• Method: createGcashSource(), lines 158–225; GcashPaymentResult, lines 9–25\n"
         "• Code Smell: PayMongo returns third-party JSON data containing integer centavos (amountCentavos), external webhook attributes, and raw redirect links. E-Parada's internal wallet and checkout systems expect standard amounts in Philippine Pesos (PHP), standardized internal transaction receipts, and boolean success flags. The UI is tightly coupled to PayMongo-specific models, making it impossible to add other gateways (e.g. Maya or Stripe) without rewriting checkout screens."),
        ("Pattern we chose (sample list or full catalog):",
         "Adapter Pattern (Full GoF catalog)"),
        ("Category (Creational / Structural / Behavioral):",
         "Structural"),
        ("Non-software analogy:",
         "An International Three-Prong Power Plug Adapter:\n\n"
         "When an international traveler brings an electronic laptop charger with two round European pins to the Philippines, they cannot plug it directly into a standard flat-prong Type A/B wall outlet. Rather than tearing down the building's wiring or manufacturing a brand-new laptop power supply, the traveler uses a small physical plug adapter. The adapter converts the physical pin configuration on the outside while delivering the exact same 220V electrical current to the laptop on the inside.")
    ]
    body_elements.append(make_p("6. Pattern Selection Worksheet (Adapter Pattern)", bold=True, size=20, color="1E3A8A", space_before=100, space_after=60))
    body_elements.append(make_table_2col(worksheet_rows_3))

    body_elements.append(make_p("7. Refactor Worksheet", bold=True, size=22, color="1E3A8A", space_before=140, space_after=60))

    before_code_3 = """// lib/services/paymongo_service.dart (BEFORE - lines 158-220)
// SMELL: External gateway API expects centavos and produces gateway-specific PayMongoSourceResult
static Future<PayMongoSourceResult> createGcashSource({
  required double amountPhp,
  required String description,
  // ...
}) async {
  final amountCentavos = (amountPhp * 100).round(); // Manual centavo conversion
  final payload = {
    'data': {
      'attributes': {
        'amount': amountCentavos,
        'currency': 'PHP',
        'type': 'gcash',
        // nested redirect & metadata structures
      }
    }
  };
  final response = await http.post(Uri.parse('https://api.paymongo.com/v1/sources'), ...);
  return PayMongoSourceResult.fromJson(jsonDecode(response.body));
}"""
    body_elements.append(make_p("BEFORE — paste your team's real, current code:", bold=True, size=20, color="1E3A8A", space_before=60, space_after=40))
    body_elements.append(make_code_block(before_code_3))

    after_code_3 = """// lib/services/payment_gateway_adapter.dart (AFTER - Adapter Pattern)

/// Target Interface: E-Parada's standardized internal payment contract
abstract class PaymentGatewayAdapter {
  Future<InternalPaymentReceipt> charge({
    required double amountPhp,
    required String referenceNumber,
    required String customerPhone,
  });
}

/// Standardized Internal Domain Model
class InternalPaymentReceipt {
  const InternalPaymentReceipt({
    required this.isSuccess,
    required this.transactionRef,
    required this.amountPhp,
    required this.gatewayName,
    this.checkoutUrl,
  });
  final bool isSuccess;
  final String transactionRef;
  final double amountPhp;
  final String gatewayName;
  final String? checkoutUrl;
}

/// The Adapter: Adapts PayMongo's centavo API to E-Parada's internal contract
class PayMongoGcashAdapter implements PaymentGatewayAdapter {
  @override
  Future<InternalPaymentReceipt> charge({
    required double amountPhp,
    required String referenceNumber,
    required String customerPhone,
  }) async {
    // Adapter converts domain PHP to gateway centavos
    final sourceResult = await PayMongoService.createGcashSource(
      amountPhp: amountPhp,
      description: 'E-Parada Parking Reservation $referenceNumber',
      customerPhone: customerPhone,
    );

    // Adapter translates PayMongoSourceResult into InternalPaymentReceipt
    return InternalPaymentReceipt(
      isSuccess: sourceResult.isChargeable || sourceResult.status == 'pending',
      transactionRef: sourceResult.id,
      amountPhp: sourceResult.amountPhp,
      gatewayName: 'PayMongo GCash',
      checkoutUrl: sourceResult.checkoutUrl,
    );
  }
}

/// Extensibility Proof: Adding Maya/Stripe requires only a new Adapter!
class MayaPaymentAdapter implements PaymentGatewayAdapter {
  @override
  Future<InternalPaymentReceipt> charge({required double amountPhp, required String referenceNumber, required String customerPhone}) async {
    // Adapts Maya API without changing UI screens!
    return InternalPaymentReceipt(isSuccess: true, transactionRef: 'MAYA-998', amountPhp: amountPhp, gatewayName: 'Maya');
  }
}"""
    body_elements.append(make_p("AFTER — your refactored version implementing the pattern:", bold=True, size=20, color="1E3A8A", space_before=100, space_after=40))
    body_elements.append(make_code_block(after_code_3))

    explanation_3 = (
        "• What structurally changed: Isolated the third-party PayMongo SDK behind a clean PaymentGatewayAdapter interface. The UI now only interacts with InternalPaymentReceipt.\n"
        "• Why Adapter beats Facade: Facade defines a new simplified interface for a complex subsystem. Adapter maps between two existing incompatible interfaces (PayMongo API vs E-Parada payment models) without changing the gateway's source code."
    )
    body_elements.append(make_callout(explanation_3, title="Structural Architecture & Trade-Off Defense"))

    # =========================================================================
    # PATTERN 4: BUILDER PATTERN (Creational)
    # =========================================================================
    body_elements.append(make_section_title("PATTERN 4:", "Builder Pattern (Creational) — Navigation Route Construction"))

    worksheet_rows_4 = [
        ("Symptom we found in our own code:",
         "Telescoping Constructor with 14 Parameter Arguments\n\n"
         "• Exact File: lib/services/route_navigation_service.dart\n"
         "• Class / Method: NavigationRouteData, lines 30–64; fetchRoute(), lines 157–173\n"
         "• Code Smell: The NavigationRouteData class has a massive 14-parameter constructor. Instantiating a route requires coordinating primary coordinates, alternative coordinates, distance in km, duration in minutes, ETA strings, step lists, midpoint coordinates, and 4 multi-modal ETA strings. In fetchRoute() and generateFallbackRoute(), creating this object takes 20+ lines of fragile parameter mapping."),
        ("Pattern we chose (sample list or full catalog):",
         "Builder Pattern (Full GoF catalog)"),
        ("Category (Creational / Structural / Behavioral):",
         "Creational"),
        ("Non-software analogy:",
         "Configuring a Custom Vehicle at a Dealership Showroom:\n\n"
         "When ordering a customized vehicle at a dealership, the factory does not maintain thousands of pre-built cars on the lot for every possible combination of 14 trim options. Instead, the buyer sits at an interactive configuration kiosk (the Builder): Step 1: Select chassis $\rightarrow$ Step 2: Choose engine $\rightarrow$ Step 3: Add GPS navigation $\rightarrow$ Step 4: Add all-weather tires $\rightarrow$ Step 5: Press 'Assemble Vehicle' (build()). The complex product is constructed progressively with validation before delivery.")
    ]
    body_elements.append(make_p("6. Pattern Selection Worksheet (Builder Pattern)", bold=True, size=20, color="1E3A8A", space_before=100, space_after=60))
    body_elements.append(make_table_2col(worksheet_rows_4))

    body_elements.append(make_p("7. Refactor Worksheet", bold=True, size=22, color="1E3A8A", space_before=140, space_after=60))

    before_code_4 = """// lib/services/route_navigation_service.dart (BEFORE - lines 30-47, 157-173)
// SMELL: Fragile telescoping constructor with 14 parameters
class NavigationRouteData {
  const NavigationRouteData({
    required this.primaryCoordinates,
    this.alternativeCoordinates,
    required this.distanceKm,
    required this.durationMinutes,
    required this.etaText,
    required this.steps,
    required this.primaryMidpoint,
    this.alternativeMidpoint,
    this.alternativeEtaText,
    this.alternativeDistanceKm,
    this.mode = NavigationTransportMode.car,
    this.carEta = '',
    this.motorcycleEta = '',
    this.walkingEta = '',
    this.bicycleEta = '',
  });
  // 14 final fields...
}

// Construction in fetchRoute() requires 20 lines of positional/named mapping:
return NavigationRouteData(
  primaryCoordinates: primaryCoords,
  alternativeCoordinates: altCoords,
  distanceKm: distanceKm,
  durationMinutes: durationMinutes,
  etaText: etaText,
  steps: steps,
  primaryMidpoint: primaryMidpoint,
  alternativeMidpoint: altMidpoint,
  alternativeEtaText: altEtaText,
  alternativeDistanceKm: altDistanceKm,
  mode: mode,
  carEta: formatModeEta(distanceKm, NavigationTransportMode.car),
  motorcycleEta: formatModeEta(distanceKm, NavigationTransportMode.motorcycle),
  walkingEta: formatModeEta(distanceKm, NavigationTransportMode.walking),
  bicycleEta: formatModeEta(distanceKm, NavigationTransportMode.bicycle),
);"""
    body_elements.append(make_p("BEFORE — paste your team's real, current code:", bold=True, size=20, color="1E3A8A", space_before=60, space_after=40))
    body_elements.append(make_code_block(before_code_4))

    after_code_4 = """// lib/services/route_data_builder.dart (AFTER - Builder Pattern)

class NavigationRouteDataBuilder {
  List<LatLng> _primaryCoords = const [];
  List<LatLng>? _altCoords;
  double _distanceKm = 0.0;
  int _durationMinutes = 0;
  String _etaText = '';
  List<RouteStepItem> _steps = const [];
  NavigationTransportMode _mode = NavigationTransportMode.car;

  NavigationRouteDataBuilder setPrimaryCoordinates(List<LatLng> coords) {
    _primaryCoords = coords;
    return this;
  }

  NavigationRouteDataBuilder setAlternativeCoordinates(List<LatLng>? coords) {
    _altCoords = coords;
    return this;
  }

  NavigationRouteDataBuilder setMetrics({required double distanceKm, required int durationMinutes, required String etaText}) {
    _distanceKm = distanceKm;
    _durationMinutes = durationMinutes;
    _etaText = etaText;
    return this;
  }

  NavigationRouteDataBuilder setSteps(List<RouteStepItem> steps) {
    _steps = steps;
    return this;
  }

  NavigationRouteDataBuilder setTransportMode(NavigationTransportMode mode) {
    _mode = mode;
    return this;
  }

  /// Final assembly: automatically calculates midpoints & multi-modal ETAs!
  NavigationRouteData build() {
    assert(_primaryCoords.isNotEmpty, 'Primary route coordinates cannot be empty');
    final primaryMidpoint = _primaryCoords[_primaryCoords.length ~/ 2];
    final altMidpoint = (_altCoords != null && _altCoords!.isNotEmpty)
        ? _altCoords![_altCoords!.length ~/ 2]
        : null;

    return NavigationRouteData(
      primaryCoordinates: _primaryCoords,
      alternativeCoordinates: _altCoords,
      distanceKm: _distanceKm,
      durationMinutes: _durationMinutes,
      etaText: _etaText,
      steps: _steps,
      primaryMidpoint: primaryMidpoint,
      alternativeMidpoint: altMidpoint,
      mode: _mode,
      carEta: RouteNavigationService.formatModeEta(_distanceKm, NavigationTransportMode.car),
      motorcycleEta: RouteNavigationService.formatModeEta(_distanceKm, NavigationTransportMode.motorcycle),
      walkingEta: RouteNavigationService.formatModeEta(_distanceKm, NavigationTransportMode.walking),
      bicycleEta: RouteNavigationService.formatModeEta(_distanceKm, NavigationTransportMode.bicycle),
    );
  }
}

// Client Usage in fetchRoute():
return NavigationRouteDataBuilder()
    .setPrimaryCoordinates(primaryCoords)
    .setAlternativeCoordinates(altCoords)
    .setMetrics(distanceKm: distanceKm, durationMinutes: durationMinutes, etaText: etaText)
    .setSteps(steps)
    .setTransportMode(mode)
    .build();"""
    body_elements.append(make_p("AFTER — your refactored version implementing the pattern:", bold=True, size=20, color="1E3A8A", space_before=100, space_after=40))
    body_elements.append(make_code_block(after_code_4))

    explanation_4 = (
        "• What structurally changed: Replaced the 14-parameter telescoping constructor with a fluent builder. The builder encapsulates derived properties (midpoints and multi-modal ETAs) automatically during assembly.\n"
        "• Why Builder beats Factory Method: Factory Method creates families of products in a single shot. Builder constructs a complex product step-by-step with intermediate configuration stages."
    )
    body_elements.append(make_callout(explanation_4, title="Structural Architecture & Trade-Off Defense"))

    # =========================================================================
    # PATTERN 5: COMMAND PATTERN (Behavioral)
    # =========================================================================
    body_elements.append(make_section_title("PATTERN 5:", "Command Pattern (Behavioral) — Reservation Actions & Offline Queueing"))

    worksheet_rows_5 = [
        ("Symptom we found in our own code:",
         "Direct Action Invocation Without Queueing or Undo\n\n"
         "• Exact File: lib/widgets/reservation_action_dialogs.dart & lib/screens/reservations_screen.dart\n"
         "• Method: _extendReservation(), _cancelReservation(), lines 250–310\n"
         "• Code Smell: User actions (extending reservation duration, checking in at a barrier gate, canceling a booking) are triggered directly as ad-hoc async calls inside UI button handlers. In underground parking garages with spotty cellular reception, dropped connections cause immediate failure dialogs. Actions cannot be queued, retried automatically upon reconnection, logged into an audit trail, or undone."),
        ("Pattern we chose (sample list or full catalog):",
         "Command Pattern (Full GoF catalog)"),
        ("Category (Creational / Structural / Behavioral):",
         "Behavioral"),
        ("Non-software analogy:",
         "A Restaurant Waiter's Physical Order Ticket Pad:\n\n"
         "When a restaurant patron orders food, requests extra parking validation, or cancels a side dish, the waiter does not scream directly into the noisy kitchen on the spot. Instead, the waiter writes each request onto an individual physical order ticket (the Command). Tickets can be placed in an ordered queue, time-stamped for audit, retried if the stove is busy, or torn up (undone) before the chef begins cooking.")
    ]
    body_elements.append(make_p("6. Pattern Selection Worksheet (Command Pattern)", bold=True, size=20, color="1E3A8A", space_before=100, space_after=60))
    body_elements.append(make_table_2col(worksheet_rows_5))

    body_elements.append(make_p("7. Refactor Worksheet", bold=True, size=22, color="1E3A8A", space_before=140, space_after=60))

    before_code_5 = """// lib/widgets/reservation_action_dialogs.dart (BEFORE - lines 250-280)
// SMELL: UI buttons directly invoke backend network requests; failure is unrecoverable
FilledButton(
  onPressed: () async {
    try {
      final message = await ReservationService.extendReservation(
        reservationId: reservation.id,
        extensionMinutes: selectedMinutes,
      );
      showSuccess(message);
    } catch (err) {
      showError(err.toString()); // If offline in a basement, action is lost forever!
    }
  },
  child: const Text('Confirm Extension'),
)"""
    body_elements.append(make_p("BEFORE — paste your team's real, current code:", bold=True, size=20, color="1E3A8A", space_before=60, space_after=40))
    body_elements.append(make_code_block(before_code_5))

    after_code_5 = """// lib/commands/reservation_command.dart (AFTER - Command Pattern)

/// The Command Interface
abstract class ReservationCommand {
  String get description;
  DateTime get timestamp;
  Future<bool> execute();
  Future<void> undo();
}

/// Concrete Command 1: Extend parking time
class ExtendReservationCommand implements ReservationCommand {
  ExtendReservationCommand({required this.reservationId, required this.extensionMinutes});
  final int reservationId;
  final int extensionMinutes;
  @override final DateTime timestamp = DateTime.now();
  @override String get description => 'Extend reservation #$reservationId by $extensionMinutes mins';

  @override
  Future<bool> execute() async {
    await ReservationService.extendReservation(reservationId: reservationId, extensionMinutes: extensionMinutes);
    return true;
  }

  @override
  Future<void> undo() async {
    // Revert reservation end time if supported
  }
}

/// Concrete Command 2: Cancel reservation
class CancelReservationCommand implements ReservationCommand {
  CancelReservationCommand({required this.reservationId, required this.reason});
  final int reservationId;
  final String reason;
  @override final DateTime timestamp = DateTime.now();
  @override String get description => 'Cancel reservation #$reservationId';

  @override
  Future<bool> execute() async {
    await ReservationService.cancelReservation(reservationId: reservationId, reason: reason);
    return true;
  }

  @override
  Future<void> undo() async {
    // Restore reservation status
  }
}

/// The Invoker: Queues commands, retries when offline, and maintains transaction history
class ReservationActionInvoker {
  final List<ReservationCommand> _history = [];
  final List<ReservationCommand> _offlineQueue = [];

  Future<void> executeCommand(ReservationCommand command) async {
    try {
      final success = await command.execute();
      if (success) _history.add(command);
    } catch (_) {
      // Offline fallback: Queue command to replay when connectivity returns!
      _offlineQueue.add(command);
    }
  }

  void undoLast() {
    if (_history.isNotEmpty) {
      final last = _history.removeLast();
      last.undo();
    }
  }
}

// Client UI button simply delegates to Invoker:
invoker.executeCommand(ExtendReservationCommand(
  reservationId: reservation.id,
  extensionMinutes: selectedMinutes,
));"""
    body_elements.append(make_p("AFTER — your refactored version implementing the pattern:", bold=True, size=20, color="1E3A8A", space_before=100, space_after=40))
    body_elements.append(make_code_block(after_code_5))

    explanation_5 = (
        "• What structurally changed: Encapsulated UI requests as standalone Command objects. The UI no longer knows how ReservationService works; it delegates execution to the ReservationActionInvoker.\n"
        "• Why Command beats Direct Function Calls: Direct function calls cannot be serialized, queued for offline execution in basements, logged for security auditing, or reversed with undo."
    )
    body_elements.append(make_callout(explanation_5, title="Structural Architecture & Trade-Off Defense"))

    # Assembly into docx
    full_body = "".join(body_elements)
    document_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    {full_body}
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>"""

    content_types_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>"""

    rels_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>"""

    doc_rels_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>"""

    styles_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
        <w:sz w:val="21"/>
        <w:szCs w:val="21"/>
        <w:color w:val="222222"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:spacing w:after="120" w:line="260" w:lineRule="auto"/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
</w:styles>"""

    output_path = r"c:\Users\kimch\e_parada_mobile\Design_Pattern_Refactor_Lab_EParada_New_Patterns.docx"
    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", content_types_xml)
        z.writestr("_rels/.rels", rels_xml)
        z.writestr("word/_rels/document.xml.rels", doc_rels_xml)
        z.writestr("word/styles.xml", styles_xml)
        z.writestr("word/document.xml", document_xml)

    print(f"Successfully generated {output_path}")

if __name__ == "__main__":
    build_new_document()
