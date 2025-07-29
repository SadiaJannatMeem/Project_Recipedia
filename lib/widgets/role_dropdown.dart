import 'package:flutter/material.dart';

class RoleDropdown extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String?> onChanged;

  const RoleDropdown({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: "Select Role",
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: "user", child: Text("User")),
        DropdownMenuItem(value: "admin", child: Text("Admin")),
      ],
      onChanged: onChanged,
    );
  }
}
