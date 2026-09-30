import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:titan_tunes/presentation/notifiers/playlist_notifier.dart';
import 'package:titan_tunes/provider/auth_provider.dart';

class CreatePlaylistPage extends ConsumerStatefulWidget {
  const CreatePlaylistPage({super.key});

  @override
  ConsumerState<CreatePlaylistPage> createState() =>
      _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends ConsumerState<CreatePlaylistPage> {
  static const Color primaryOrange = Color(0xFFFF8A00);

  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String? _previewImageUrl;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final clientId = ref.read(authNotifierProvider).user?.id ?? '';
    if (clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour créer une playlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final ok = await ref.read(playlistNotifierProvider.notifier).createPlaylist(
          titre: _titreCtrl.text.trim(),
          clientTrackingId: clientId,
          imageUrl:
              _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playlist créée ✅'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(playlistNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Erreur'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/playlists');
            }
          },
        ),
        title: Text(
          'Créer une playlist',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            // Aperçu image
            _buildImagePreview(),
            SizedBox(height: 24.h),

            // Titre
            _buildField(
              controller: _titreCtrl,
              label: 'Titre de la playlist',
              hint: 'Ma playlist',
              icon: Icons.playlist_play,
              isRequired: true,
            ),

            // URL de l'image
            _buildField(
              controller: _imageCtrl,
              label: 'Image de couverture (URL)',
              hint: 'https://...jpg',
              icon: Icons.image_outlined,
              keyboard: TextInputType.url,
              onChanged: (v) {
                setState(() => _previewImageUrl = v.isEmpty ? null : v);
              },
            ),

            SizedBox(height: 30.h),

            // Bouton créer
            SizedBox(
              height: 54.h,
              child: ElevatedButton.icon(
                onPressed: state.isLoading ? null : _submit,
                icon: state.isLoading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add, size: 20),
                label: Text(
                  state.isLoading
                      ? 'Création...'
                      : 'Créer la playlist',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final hasPreview =
        _previewImageUrl != null && _previewImageUrl!.isNotEmpty;

    return Center(
      child: Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: hasPreview
              ? Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderIcon(),
                )
              : _placeholderIcon(),
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 60.sp, color: Colors.grey.shade400),
          SizedBox(height: 8.h),
          Text(
            'Aperçu',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboard,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            onChanged: onChanged,
            validator: isRequired
                ? (v) => v == null || v.trim().isEmpty
                    ? 'Champ obligatoire'
                    : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon:
                  Icon(icon, color: primaryOrange, size: 20.sp),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: primaryOrange, width: 2.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}