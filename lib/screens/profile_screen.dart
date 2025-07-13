import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/user/profile_interface.dart';
import '../services/ProfileService.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final fetchedProfile = await ProfileService.getProfile();

    setState(() {
      profile = fetchedProfile;
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Error cargando perfil')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profile!.photoUrl != null
                      ? NetworkImage(profile!.photoUrl!)
                      : null,
                  backgroundColor: Colors.grey[400],
                  child: profile!.photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    profile!.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    profile!.phone ?? '',
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _InfoBox(
                          icon: Icons.male,
                          label: 'Género',
                          value: profile!.gender == 'M'
                              ? 'Masculino'
                              : profile!.gender == 'F'
                                  ? 'Femenino'
                                  : profile!.gender,
                        ),
                        _InfoBox(
                          icon: Icons.calendar_month,
                          label: 'Nacimiento',
                          value: profile!.birthDate,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const _OptionItem(
                    title: 'Subscripción',
                    icon: Icons.credit_card,
                    iconColor: Color(0xFF7012DA),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final qrCode = await ProfileService.fetchQrCode();
                        if (qrCode != null && qrCode.qrImageBase64.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Tu código QR'),
                              content: SizedBox(
                                width: 220,
                                child: Image.memory(
                                  base64Decode(
                                    qrCode.qrImageBase64.split(',').last,
                                  ),
                                  width: 220,
                                  height: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo generar el QR')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const _OptionItem(
                      title: 'QR',
                      icon: Icons.qr_code_2_rounded,
                      iconColor: Color(0xFF7012DA),
                    ),
                  ),
                ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      children: [
                        _EditableField(label: 'Nombre completo', value: profile!.fullName),
                        const SizedBox(height: 12),
                        _EditableField(label: 'Contraseña', value: '********'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 300,
                          child: UpdatePasswordButton(),
                        ),
                        const SizedBox(height: 12),
                        _EditableField(label: 'Teléfono', value: profile!.phone ?? ''),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              child: EditProfileButton(
                                profile: profile!,
                                onProfileUpdated: (updatedProfile) {
                                  setState(() {
                                    profile = updatedProfile;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 300,
                              child: _ClearPreferencesButton(),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color.fromRGBO(103, 58, 183, 1), size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const _OptionItem({required this.title, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              icon != null
                  ? Icon(icon, size: 24, color: iconColor ?? Colors.grey[600])
                  : Container(width: 24, height: 24, color: Colors.grey[300]),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String value;

  const _EditableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          ],
      ),
    );
  }
}

class _ClearPreferencesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: 200, // Ajusta el ancho aquí (puedes cambiar el valor)
      child: ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('first-init-app');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferencias borradas. Reinicia la app para ver el efecto.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_forever, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            const Text(
              'Borrar Preferencias',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // Texto más pequeño
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón y diálogo para editar perfil
class EditProfileButton extends StatelessWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileUpdated;

  const EditProfileButton({required this.profile, required this.onProfileUpdated, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
      label: const Text(
        'Editar Perfil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A5AF9),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () async {
        final updatedProfile = await showDialog<Profile>(
          context: context,
          builder: (context) => EditProfileDialog(profile: profile),
        );
        if (updatedProfile != null) {
          onProfileUpdated(updatedProfile);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
          );
        }
      },
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final Profile profile;
  const EditProfileDialog({required this.profile, Key? key}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController birthController;
  DateTime? birthDate;
  late TextEditingController genderController;
  late TextEditingController photoController;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.fullName);
    phoneController = TextEditingController(text: widget.profile.phone);
    birthController = TextEditingController(text: widget.profile.birthDate);
    if (widget.profile.birthDate.isNotEmpty) {
      try {
        birthDate = DateTime.parse(widget.profile.birthDate);
      } catch (_) {
        birthDate = null;
      }
    }
    genderController = TextEditingController(text: widget.profile.gender);
    photoController = TextEditingController(text: widget.profile.photoUrl ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    birthController.dispose();
    genderController.dispose();
    photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDBE0E5)),
    );
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Editar Perfil'),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF2F2FE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFDBE0E5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      birthDate == null
                          ? 'Fecha de nacimiento'
                          : 'Nacimiento: ${birthDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: birthDate ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          birthDate = picked;
                          birthController.text = picked.toIso8601String().split('T')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: genderController.text.isNotEmpty ? genderController.text : null,
              decoration: InputDecoration(
                labelText: 'Género',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Masculino')),
                DropdownMenuItem(value: 'F', child: Text('Femenino')),
              ],
              onChanged: (value) {
                setState(() {
                  genderController.text = value ?? '';
                });
              },
              hint: const Text('Selecciona género'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: photoController,
              decoration: InputDecoration(
                labelText: 'URL de foto (opcional)',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);
                  try {
                    final updated = await ProfileService.updateProfile(
                      widget.profile,
                      fullName: nameController.text,
                      phone: phoneController.text,
                      birthDate: birthController.text.isNotEmpty
                          ? birthController.text
                          : (birthDate != null ? birthDate!.toIso8601String().split('T')[0] : ''),
                      gender: genderController.text,
                      photoUrl: photoController.text.isNotEmpty ? photoController.text : null,
                    );
                    if (updated != null) {
                      // Setea el perfil en local para reflejar el cambio en toda la app
                      await ProfileService.setProfile(updated);
                      Navigator.of(context).pop(updated);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo actualizar el perfil'), backgroundColor: Colors.red),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  } finally {
                    setState(() => loading = false);
                  }
                },
          child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

// Botón y diálogo para actualizar contraseña
class UpdatePasswordButton extends StatelessWidget {
  const UpdatePasswordButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lock, color: Colors.white, size: 20),
      label: const Text(
        'Actualizar Contraseña',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A5AF9),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => const UpdatePasswordDialog(),
        );
      },
    );
  }
}

class UpdatePasswordDialog extends StatefulWidget {
  const UpdatePasswordDialog({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordDialog> createState() => _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends State<UpdatePasswordDialog> {
  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDBE0E5)),
    );
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Actualizar Contraseña'),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newController,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                border: border,
                fillColor: Color(0xFFF2F2FE),
                filled: true,
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  if (newController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  setState(() => loading = true);
                  try {
                    await ProfileService.updatePassword(
                      currentController.text,
                      newController.text,
                      confirmController.text,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  } finally {
                    setState(() => loading = false);
                  }
                },
          child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}