import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../utils/registration_validation.dart';
import '../widgets/email_verification_dialog.dart';
import '../widgets/terms_and_conditions_dialog.dart';
import '../widgets/vehicle_catalog_fields.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _plateController = TextEditingController();
  final _registeredOwnerController = TextEditingController();

  String _userSubtype = 'owner_driver';
  String _vehicleType = 'Car';
  String _vehicleMake = '';
  String _vehicleModel = '';
  String _vehicleColor = '';
  XFile? _identityFront;
  XFile? _identityBack;
  XFile? _vehicleFront;
  XFile? _vehicleBack;
  XFile? _orPhoto;
  XFile? _crPhoto;
  bool _consent = false;
  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _isLoading = false;
  String? _errorMessage;

  String get _role =>
      _userSubtype == 'parking_provider' ? 'parking_owner' : 'driver';

  bool get _requiresDriversLicense =>
      _userSubtype == 'driver_only' || _userSubtype == 'owner_driver';

  bool get _requiresOrCr =>
      _userSubtype == 'vehicle_owner_only' || _userSubtype == 'owner_driver';

  Future<void> _pickImage(ValueSetter<XFile> onPicked) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (image != null && mounted) {
      setState(() {
        onPicked(image);
        _errorMessage = null;
      });
    }
  }

  Future<UploadFileData?> _uploadData(XFile? image) async {
    if (image == null) return null;
    return UploadFileData(
      bytes: await image.readAsBytes(),
      filename: image.name,
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_role == 'driver') {
      _plateController.text = RegistrationValidation.normalizePlate(
        _plateController.text,
        _vehicleType,
      );
    }

    final missingMessage = _missingDocumentMessage();
    if (missingMessage != null) {
      setState(() => _errorMessage = missingMessage);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var user = await AuthService.registerAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmationController.text,
        role: _role,
        userSubtype: _userSubtype,
        isOwnerDriving: _userSubtype != 'driver_only',
        registeredOwnerName: _userSubtype == 'driver_only'
            ? _registeredOwnerController.text.trim()
            : null,
        identityImage: (await _uploadData(_identityFront))!,
        identityImageBack: _requiresDriversLicense
            ? await _uploadData(_identityBack)
            : null,
        plateNumber: _role == 'driver' ? _plateController.text : null,
        vehicleType: _role == 'driver' ? _vehicleType : null,
        vehicleMake: _role == 'driver' ? _vehicleMake : null,
        vehicleColor: _role == 'driver' ? _vehicleColor : null,
        vehicleModel: _role == 'driver' ? _vehicleModel : null,
        vehiclePhoto: await _uploadData(_vehicleFront),
        vehiclePhotoBack: await _uploadData(_vehicleBack),
        orPhoto: await _uploadData(_orPhoto),
        crPhoto: await _uploadData(_crPhoto),
      );

      if (!mounted) return;

      if (!user.emailVerified) {
        final verifiedUser = await EmailVerificationDialog.show(
          context,
          email: user.email,
        );
        if (verifiedUser != null) {
          user = verifiedUser;
        }
      }

      if (!mounted) return;

      if (user.emailVerified && !user.termsAccepted) {
        final acceptedUser = await TermsAndConditionsDialog.show(context);
        if (acceptedUser != null) {
          user = acceptedUser;
        }
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainNavigationScreen(user: user)),
        (_) => false,
      );
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _missingDocumentMessage() {
    if (_identityFront == null) {
      return _requiresDriversLicense
          ? 'Upload the front of your driver\'s license.'
          : 'Upload a clear government-issued valid ID.';
    }
    if (_requiresDriversLicense && _identityBack == null) {
      return 'Upload the back of your driver\'s license.';
    }
    if (_role != 'driver') return null;
    if (_vehicleFront == null) {
      return 'Upload a front photo of the vehicle showing its plate.';
    }
    if (_vehicleBack == null) {
      return 'Upload a back photo of the vehicle showing its plate.';
    }
    if (_requiresOrCr && _orPhoto == null) {
      return 'Upload your vehicle\'s Official Receipt (OR) or OR/CR document.';
    }
    if (!_consent) return 'Accept the vehicle-photo consent statement.';
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _plateController.dispose();
    _registeredOwnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const _RegistrationIntro(),
              const SizedBox(height: 24),
              _sectionHeading(
                context,
                icon: Icons.manage_accounts_outlined,
                title: 'Registration Options',
                caption:
                    'Choose your registration type to determine the required documents.',
              ),
              const SizedBox(height: 12),
              _registrationOptionCard(
                context,
                value: 'driver_only',
                title: '1. Driver Only',
                subtitle: 'Submits a valid Driver\'s License.',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 10),
              _registrationOptionCard(
                context,
                value: 'vehicle_owner_only',
                title: '2. Vehicle Owner Only',
                subtitle: 'Submits Government ID + OR/CR in their name.',
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 10),
              _registrationOptionCard(
                context,
                value: 'owner_driver',
                title: '3. Owner & Driver (Both)',
                subtitle: 'Submits both Driver\'s License and OR/CR.',
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 10),
              _registrationOptionCard(
                context,
                value: 'parking_provider',
                title: '4. Parking Space Provider',
                subtitle: 'Routes to property onboarding.',
                icon: Icons.local_parking_outlined,
              ),
              const SizedBox(height: 24),
              _sectionHeading(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Account information',
                caption: 'Use your real name and an email you can verify.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: RegistrationValidation.name,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: RegistrationValidation.email,
              ),
              const SizedBox(height: 14),
              _passwordField(
                controller: _passwordController,
                label: 'Password',
                visible: _showPassword,
                onToggle: () => setState(() => _showPassword = !_showPassword),
                validator: (value) => (value?.length ?? 0) >= 8
                    ? null
                    : 'Use at least 8 characters.',
              ),
              const SizedBox(height: 14),
              _passwordField(
                controller: _confirmationController,
                label: 'Confirm password',
                visible: _showConfirmation,
                onToggle: () =>
                    setState(() => _showConfirmation = !_showConfirmation),
                validator: (value) => value == _passwordController.text
                    ? null
                    : 'Passwords do not match.',
              ),
              const SizedBox(height: 28),
              _sectionHeading(
                context,
                icon: Icons.badge_outlined,
                title: _requiresDriversLicense
                    ? 'Driver\'s license'
                    : 'Government ID verification',
                caption: _requiresDriversLicense
                    ? 'Upload clear, uncropped photos of both sides of your valid Driver\'s License.'
                    : 'Upload one clear government-issued valid ID.',
              ),
              const SizedBox(height: 12),
              if (_requiresDriversLicense)
                _uploadPair(
                  first: _uploadCard(
                    context,
                    title: 'License front',
                    hint: 'Photo and license details visible',
                    image: _identityFront,
                    icon: Icons.badge_outlined,
                    onTap: () => _pickImage((file) => _identityFront = file),
                  ),
                  second: _uploadCard(
                    context,
                    title: 'License back',
                    hint: 'Back details fully readable',
                    image: _identityBack,
                    icon: Icons.flip_to_back_outlined,
                    onTap: () => _pickImage((file) => _identityBack = file),
                  ),
                )
              else
                _uploadCard(
                  context,
                  title: 'Government-issued valid ID',
                  hint: 'JPG or PNG, clear and uncropped',
                  image: _identityFront,
                  icon: Icons.badge_outlined,
                  onTap: () => _pickImage((file) => _identityFront = file),
                ),
              if (_userSubtype == 'parking_provider') ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.storefront_outlined, color: colors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Parking Space Provider Onboarding: After creating your account, you will be routed to property onboarding to list your parking bays and upload property documents.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_role == 'driver') ...[
                const SizedBox(height: 28),
                _sectionHeading(
                  context,
                  icon: Icons.directions_car_outlined,
                  title: 'First vehicle',
                  caption: 'Details are locked after submission for review.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Plate number',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    hintText:
                        _vehicleType == RegistrationValidation.motorcycleType
                        ? 'A 123 BC'
                        : 'ABC 1234',
                    helperText: RegistrationValidation.plateHint(_vehicleType),
                  ),
                  validator: (value) =>
                      RegistrationValidation.plate(value, _vehicleType),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _vehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle type',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  items: VehicleService.vehicleTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _vehicleType = value;
                            _vehicleMake = '';
                            _vehicleModel = '';
                            _vehicleColor = '';
                            _plateController.clear();
                          });
                        },
                ),
                const SizedBox(height: 14),
                VehicleCatalogFields(
                  key: ValueKey(_vehicleType),
                  vehicleType: _vehicleType,
                  enabled: !_isLoading,
                  onChanged: (make, model, color) {
                    _vehicleMake = make;
                    _vehicleModel = model;
                    _vehicleColor = color;
                  },
                ),
                if (_userSubtype == 'driver_only') ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _registeredOwnerController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Registered owner\'s full name (optional)',
                      prefixIcon: Icon(Icons.person_pin_outlined),
                      helperText:
                          'Driver Only mode: OR/CR is not required if you are driving someone else\'s vehicle.',
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _sectionHeading(
                  context,
                  icon: Icons.photo_camera_outlined,
                  title: 'Vehicle verification photos',
                  caption:
                      'Show the full vehicle and make the plate readable in both views.',
                ),
                const SizedBox(height: 12),
                _uploadPair(
                  first: _uploadCard(
                    context,
                    title: 'Vehicle front',
                    hint: 'Front view with plate visible',
                    image: _vehicleFront,
                    icon: Icons.directions_car_filled_outlined,
                    onTap: () => _pickImage((file) => _vehicleFront = file),
                  ),
                  second: _uploadCard(
                    context,
                    title: 'Vehicle back',
                    hint: 'Rear view with plate visible',
                    image: _vehicleBack,
                    icon: Icons.local_parking_outlined,
                    onTap: () => _pickImage((file) => _vehicleBack = file),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  color: colors.secondaryContainer,
                  child: CheckboxListTile(
                    value: _consent,
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() => _consent = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'Vehicle photo consent',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Users must upload clear front and back photos of their vehicle showing the plate number for vehicle verification. The photos will only be used to confirm that the registered vehicle matches the vehicle used during the parking reservation.',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionHeading(
                  context,
                  icon: Icons.description_outlined,
                  title: _requiresOrCr
                      ? 'LTO registration documents (OR / CR)'
                      : 'LTO registration documents (OR / CR) — Optional',
                  caption: _requiresOrCr
                      ? 'Upload your vehicle\'s Official Receipt (OR) and Certificate of Registration (CR) in your name. If both are on one document, upload it in the OR card.'
                      : 'Optional for Driver Only registrations. Upload OR/CR if available.',
                ),
                const SizedBox(height: 12),
                _uploadPair(
                  first: _uploadCard(
                    context,
                    title: 'Official Receipt (OR)',
                    hint: 'Latest registration receipt',
                    image: _orPhoto,
                    icon: Icons.receipt_long_outlined,
                    isOptional: !_requiresOrCr,
                    onTap: () => _pickImage((file) => _orPhoto = file),
                  ),
                  second: _uploadCard(
                    context,
                    title: 'Cert. of Registration (CR)',
                    hint: 'Certificate of registration',
                    image: _crPhoto,
                    icon: Icons.badge_outlined,
                    isOptional: true,
                    onTap: () => _pickImage((file) => _crPhoto = file),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: colors.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _register,
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  _isLoading ? 'Creating account...' : 'Create account',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _registrationOptionCard(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = _userSubtype == value;

    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _userSubtype = value;
                _errorMessage = null;
              });
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer.withValues(alpha: 0.65)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: selected ? colors.primary : colors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selected ? colors.primary : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String caption,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(caption, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: visible ? 'Hide password' : 'Show password',
          onPressed: onToggle,
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _uploadPair({required Widget first, required Widget second}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Widget _uploadCard(
    BuildContext context, {
    required String title,
    required String hint,
    required XFile? image,
    required IconData icon,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final complete = image != null;

    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 132),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: complete
              ? colors.primaryContainer.withValues(alpha: 0.55)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: complete ? colors.primary : colors.outlineVariant,
            width: complete ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  complete ? Icons.check_circle : icon,
                  color: colors.primary,
                ),
                const Spacer(),
                Text(
                  complete ? 'Ready' : (isOptional ? 'Optional' : 'Required'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: complete ? colors.primary : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              image?.name ?? hint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (complete) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 12, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Secured: E-Parada Verification Only',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RegistrationIntro extends StatelessWidget {
  const _RegistrationIntro();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_parking_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join E-Parada',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const Text('Find Parking. Made Local.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Create a verified account in three clear steps.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StepChip(number: '1', label: 'Account'),
              _StepChip(number: '2', label: 'Documents'),
              _StepChip(number: '3', label: 'Admin review'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 11, child: Text(number)),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
