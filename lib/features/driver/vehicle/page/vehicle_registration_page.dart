import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_button.dart';
import '../../../../app/widgets/app_text_field.dart';
import '../../../../core/storage/app_storage.dart';
import '../model/vehicle_model.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({super.key});

  @override
  State<VehicleRegistrationPage> createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final vehicle = VehicleModel(
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      plateNumber: _plateCtrl.text.trim(),
    );

    await AppStorage.updateUser(vehicle.toJson());
    setState(() => _isSaving = false);
    Get.offAllNamed(Routes.driverDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = GoogleFonts.inter(
      color: AppColors.textSub(context).withValues(alpha: 0.45),
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Véhicule chauffeur'),
        actions: [
          TextButton(
            onPressed: () async {
              await AppStorage.clearAuth();
              Get.offAllNamed(Routes.login);
            },
            child:
                const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enregistrer votre véhicule',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ces informations sont nécessaires avant de recevoir des courses.',
                  style: GoogleFonts.inter(
                    color: AppColors.textSub(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  hint: 'Marque',
                  icon: Icons.two_wheeler_rounded,
                  controller: _brandCtrl,
                  hintStyle: hintStyle,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: 'Modèle',
                  icon: Icons.badge_outlined,
                  controller: _modelCtrl,
                  hintStyle: hintStyle,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: 'Couleur',
                  icon: Icons.palette_outlined,
                  controller: _colorCtrl,
                  hintStyle: hintStyle,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: 'Plaque d’immatriculation',
                  icon: Icons.confirmation_number_outlined,
                  controller: _plateCtrl,
                  hintStyle: hintStyle,
                  validator: _required,
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Enregistrer',
                  loading: _isSaving,
                  onTap: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Champ obligatoire' : null;
  }
}
