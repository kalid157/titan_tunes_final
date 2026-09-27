import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/button_pop.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/google_apple_widget.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/image_tune_variante.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/my_textfield.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/password_textfield.dart';
import 'package:titan_tunes/provider/register_providers.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  //  Clé du formulaire — pilote toute la validation
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  //  Mode auto-validation après la 1re tentative
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    FocusScope.of(context).unfocus();

    //  1. Activer la validation automatique dès le 1er clic
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);

    //  2. Vérifier que TOUS les champs sont valides
    if (!_formKey.currentState!.validate()) {
      return; // Affiche les erreurs sous chaque champ
    }

    //  3. Appel du Notifier
    final success = await ref.read(registerNotifierProvider.notifier).register(
          firstName: _firstnameController.text,
          lastName: _lastnameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Connectez-vous.'),
          backgroundColor: Colors.green,
        ),
      );
      ref.read(registerNotifierProvider.notifier).reset();
      context.go('/sign_in');
    } else {
      final error = ref.read(registerNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Erreur d\'inscription'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ─── VALIDATORS ─────────────────────────────────────────
  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le prénom est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Minimum 2 caractères';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Minimum 2 caractères';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est obligatoire';
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8) {
      return 'Numéro trop court (min. 8 chiffres)';
    }
    if (digits.length > 15) {
      return 'Numéro trop long (max. 15 chiffres)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerNotifierProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: SafeArea(
        //  Form englobe tout le contenu
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    const ButtonPop(),
                    Expanded(child: Center(child: ImageTuneVariante())),
                    SizedBox(width: 40.w),
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  "S'enregistrer",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('If You Need Any Support ',
                        style: TextStyle(fontSize: 13.sp)),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Click Here',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ─── CHAMPS ─────────────────────────────────
                MyTextfield(
                  hintText: 'Enter Firstname *',
                  controller: _firstnameController,
                  obscureText: false,
                  validator: _validateFirstName,
                ),
                MyTextfield(
                  hintText: 'Enter Lastname',
                  controller: _lastnameController,
                  obscureText: false,
                  validator: _validateLastName,
                ),
                MyTextfield(
                  hintText: 'Enter Email *',
                  controller: _emailController,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                PasswordField(
                  hint: 'Password *',
                  controller: _passwordController,
                  icon: Icons.visibility_off_outlined,
                  validator: _validatePassword,
                ),
                MyTextfield(
                  hintText: 'Enter Phone *',
                  controller: _phoneController,
                  obscureText: false,
                  isPhone: true,
                  validator: _validatePhone,
                ),

                SizedBox(height: 24.h),

                // ─── BOUTON ─────────────────────────────────
                SizedBox(
                  height: 56.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _registerUser,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 22.w,
                            height: 22.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "S'enregistrer",
                            style: TextStyle(fontSize: 17.sp),
                          ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ─── DIVIDER ────────────────────────────────
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'Or',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                SizedBox(height: 20.h),
                const GoogleAppleWidget(),
                SizedBox(height: 20.h),

                // ─── LIEN SIGN IN ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Do You Have An Account?',
                        style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => context.go('/sign_in'),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}