import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/button_pop.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/google_apple_widget.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/image_tune_variante.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/my_textfield.dart';
import 'package:titan_tunes/presentation/views/auth/widgets/password_textfield.dart';
import 'package:titan_tunes/provider/auth_provider.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _signInUser() async {
    // Réinitialise l'erreur précédente
    FocusScope.of(context).unfocus();

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      // Navigation via go_router
      context.go('/home');
    } else {
      // Affiche l'erreur via SnackBar
      final error = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Erreur de connexion'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écoute l'état (loading / erreur)
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Row(
                children: [
                  const ButtonPop(),
                  Expanded(
                    child: Center(child: ImageTuneVariante()),
                  ),
                  SizedBox(width: 40.w), // équilibre visuel
                ],
              ),
              SizedBox(height: 40.h),
              Text(
                'Se Connecter',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'If You Need Any Support ',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/home'),
                    child: Text(
                      'Click Here',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),

              // Champs
              MyTextfield(
                hintText: 'Entrer Email',
                controller: _emailController,
                obscureText: false,
              ),
              SizedBox(height: 16.h),
              PasswordField(
                hint: 'Password',
                controller: _passwordController,
                icon: Icons.visibility_off_outlined,
              ),

              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recovery Password',
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 24.h),

              // Bouton de connexion
              SizedBox(
                height: 56.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signInUser,
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
                          'Se Connecter',
                          style: TextStyle(fontSize: 17.sp),
                        ),
                ),
              ),

              SizedBox(height: 30.h),

              // Divider "Or"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              SizedBox(height: 20.h),
              const GoogleAppleWidget(),
              SizedBox(height: 30.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not A Member?', style: TextStyle(fontSize: 14.sp)),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Register Now',
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
    );
  }
}