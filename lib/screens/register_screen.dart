import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../utils/registration_validation.dart';
import '../widgets/email_verification_dialog.dart';
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

  String _role = 'driver';
  String _vehicleType = 'Car';
  String _vehicleMake = '';
  String _vehicleModel = '';
  String _vehicleColor = '';
  XFile? _identityFront;
  XFile? _identityBack;
  XFile? _vehicleFront;
  XFile? _vehicleBack;
  bool _consent = false;
  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _isLoading = false;
  String? _errorMessage;

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
      final user = await AuthService.registerAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmationController.text,
        role: _role,
        identityImage: (await _uploadData(_identityFront))!,
        identityImageBack: await _uploadData(_identityBack),
        plateNumber: _role == 'driver' ? _plateController.text : null,
        vehicleType: _role == 'driver' ? _vehicleType : null,
        vehicleMake: _role == 'driver' ? _vehicleMake : null,
        vehicleColor: _role == 'driver' ? _vehicleColor : null,
        vehicleModel: _role == 'driver' ? _vehicleModel : null,
        vehiclePhoto: await _uploadData(_vehicleFront),
        vehiclePhotoBack: await _uploadData(_vehicleBack),
      );

      if (!mounted) return;

      if (!user.emailVerified) {
        await EmailVerificationDialog.show(
          context,
          email: user.email,
        );
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
      return _role == 'driver'
          ? 'Upload the front of your driver\'s license.'
          : 'Upload a clear government-issued valid ID.';
    }
    if (_role != 'driver') return null;
    if (_identityBack == null) {
      return 'Upload the back of your driver\'s license.';
    }
    if (_vehicleFront == null) {
      return 'Upload a front photo of the vehicle showing its plate.';
    }
    if (_vehicleBack == null) {
      return 'Upload a back photo of the vehicle showing its plate.';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
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
                title: 'Choose your account',
                caption: 'Your role determines the documents we need.',
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'driver',
                    icon: Icon(Icons.directions_car_outlined),
                    label: Text('Driver'),
                  ),
                  ButtonSegment(
                    value: 'parking_owner',
                    icon: Icon(Icons.local_parking_outlined),
                    label: Text('Parking owner'),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: _isLoading
                    ? null
                    : (selection) {
                        setState(() {
                          _role = selection.first;
                          _errorMessage = null;
                        });
                      },
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
                title: _role == 'driver'
                    ? 'Driver\'s license'
                    : 'Identity verification',
                caption: _role == 'driver'
                    ? 'Upload clear, uncropped photos of both sides.'
                    : 'Upload one clear government-issued valid ID.',
              ),
              const SizedBox(height: 12),
              if (_role == 'driver')
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
                  complete ? 'Ready' : 'Required',
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
                        fontSize: 10,
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
