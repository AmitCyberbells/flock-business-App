import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

// Reusable Dropdown for assigning venues.
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AppConstants {
  // Base method for password fields.

  static Widget customPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required String hintText,
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: toggleObscure,
          ),
        ),
      ),
    );
  }

  // Reusable Current Password Field widget.
  static Widget currentPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return customPasswordField(
      controller: controller,
      obscureText: obscureText,
      toggleObscure: toggleObscure,
      hintText: 'Enter current password',
    );
  }

  // Reusable New Password Field widget.
  static Widget newPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return customPasswordField(
      controller: controller,
      obscureText: obscureText,
      toggleObscure: toggleObscure,
      hintText: 'Enter new password',
    );
  }

  // Reusable Confirm New Password Field widget.
  static Widget confirmPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return customPasswordField(
      controller: controller,
      obscureText: obscureText,
      toggleObscure: toggleObscure,
      hintText: 'Confirm new password',
    );
  }

  // Custom AppBar method.
  static PreferredSizeWidget customAppBar({
    required BuildContext context,
    required String title,
    String backIconAsset = 'assets/back_updated.png', // Default asset.
    TextStyle? titleTextStyle,
    Color backgroundColor = Colors.white,

    double elevation = 0,
  }) {
    return AppBar(
      leading: SizedBox(
        width: 94, // Set desired width
        height: 74, // Set desired height
        child: IconButton(
          icon: Container(
            width: 94,
            height: 74,
            // color: Colors.black, // Background color
            child: Image.asset(
              backIconAsset,
              height: 74,
              width: 94,
              fit: BoxFit.contain,
              // color: const Color.fromRGBO(255, 130, 16, 1), // Tint the image
            ),
          ),

     onPressed: () {
 
 Navigator.pushNamed(context, '/dashboard');
 },
        ),
      ),
      title: Text(
        title,
        style:
            titleTextStyle ??
            const TextStyle(
              color: Colors.black,
              fontFamily: 'YourRegularFont', // Replace with your regular font.
              fontSize: 20,
              fontWeight: FontWeight.w500, // Adjust weight as needed.
            ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  // Reusable InputDecoration for TextFields
  static final InputDecoration textFieldDecoration = InputDecoration(
    hintText: 'Enter Email Address',
    hintStyle: TextStyle(
      color: Colors.grey.withOpacity(
        1.0,
      ), // Placeholder color with full opacity.
      fontSize: 14.0, // Exact font size match.
      fontFamily: 'YourFontFamily', // Replace with your actual font family.
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    // Default border
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)), // Radius of 10.0.
      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    // Border when focused
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(color: Color.fromRGBO(255, 106, 16, 1), width: 1),
    ),
    // Border when there's an error
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    // Border when focused and error occurs
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
  );

  // Disabled Reusable InputDecoration for TextFields
  static final InputDecoration textFieldDecorationDisabled = InputDecoration(
    hintText: 'Enter Email Address',
    hintStyle: TextStyle(
      color: Colors.grey,
      fontSize: 14.0,
      fontFamily: 'YourFontFamily',
    ),
    filled: true,
    fillColor: Colors.grey.shade100, // Light grey background

    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide.none, // No border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide.none, // Prevent black border on focus
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
  );

  // BoxDecoration with BoxShadow to be used in a Container wrapping the TextField
  static final BoxDecoration textFieldBoxDecoration = BoxDecoration(
    color: Colors.white, // Ensure background is white.
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // Subtle shadow.
        spreadRadius: 1,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  );
  // for disabled:

  static final BoxDecoration textFieldBoxDecorationDisabled = BoxDecoration(
    color: Colors.white, // Ensure background is white.
    // boxShadow: [
    //   BoxShadow(
    //     color: Colors.black.withOpacity(0.1), // Subtle shadow.
    //     spreadRadius: 1,
    //     blurRadius: 5,
    //     offset: Offset(0, 3),
    //   ),
    // ],
  );

  // Reusable full-width button.
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromRGBO(255, 130, 16, 1),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static Widget fullWidthButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: elevatedButtonStyle,
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Reusable Email Field widget.
  static Widget emailField({
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Enter Email Address',
        ),
      ),
    );
  }

  static Widget disabledemailField({
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      decoration: textFieldBoxDecorationDisabled,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecorationDisabled.copyWith(
          hintText: 'Enter Email Address',
        ),
      ),
    );
  }

  // Reusable Password Field widget.
  static Widget passwordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Enter password',
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off
                  : Icons.visibility, // ✅ Reversed logic
              color: Colors.grey,
            ),
            onPressed: toggleObscure,
          ),
        ),
      ),
    );
  }

  // Reusable First Name Field widget.
  static Widget firstNameField({required TextEditingController controller}) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(hintText: 'First Name'),
      ),
    );
  }

  // Reusable Last Name Field widget.
  static Widget lastNameField({required TextEditingController controller}) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(hintText: 'Last Name'),
      ),
    );
  }

  // Reusable Phone Number Field widget.
  static Widget phoneField({
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Enter phone number',
        ),
      ),
    );
  }

  // disabled phone field
  static Widget disbaledphoneField({
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      decoration: textFieldBoxDecorationDisabled,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecorationDisabled.copyWith(
          hintText: 'Enter phone number',
        ),
      ),
    );
  }

  // Reusable Date of Birth Field widget.
  // If an onTap callback is provided, the field becomes read-only with a calendar icon.
  static Widget dobField({
    required TextEditingController controller,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Date of Birth',
          suffixIcon:
              onTap != null
                  ? IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: onTap,
                  )
                  : null,
        ),
      ),
    );
  }

  // Reusable Location Field widget.
  static Widget locationField({
    required TextEditingController controller,
    required VoidCallback
    onLocationIconPressed, // Callback function for location icon
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Location',
          suffixIcon: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.blue),
            onPressed:
                onLocationIconPressed, // Call the function to get location
          ),
        ),
      ),
    );
  }

  static Widget assignVenuesDropdown({
    
    required List<dynamic> venueList,
    required List<String> selectedVenues,
    required ValueChanged<List<String>> onConfirm,
  }) {
    final orange = const Color.fromRGBO(255, 130, 16, 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: MultiSelectDialogField<String>(
        items:
            venueList
                .map(
                  (v) => MultiSelectItem<String>(
                    v["id"].toString(),
                    v["name"].toString(),
                  ),
                )
                .toList(),
        initialValue: selectedVenues,
        onConfirm: onConfirm,
        chipDisplay: MultiSelectChipDisplay<String>(
          chipColor: orange,
          textStyle: TextStyle(color: Colors.white),
        ),
        selectedColor: orange,
        buttonText: Text("Assign venues", style: TextStyle(color: Colors.grey)),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
      ),
    );
  }
static Widget assignPermissionsDropdown({
    required BuildContext context, // Added context parameter
    required List<dynamic> permissionList,
    required List<String> selectedPermissions,
    required ValueChanged<List<String>> onConfirm,
    String? mandatoryPermissionId = '2',
  }) {
    // Ensure mandatoryPermissionId is included in initial selection
    List<String> initialSelection = List.from(selectedPermissions);
    if (mandatoryPermissionId != null && !initialSelection.contains(mandatoryPermissionId)) {
      initialSelection.add(mandatoryPermissionId);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showPermissionsDialog(
            context: context,
            permissionList: permissionList,
            selectedPermissions: initialSelection,
            mandatoryPermissionId: mandatoryPermissionId,
            onConfirm: (values) {
              // Ensure mandatoryPermissionId is included in the confirmed list
              List<String> confirmedValues = List.from(values);
              if (mandatoryPermissionId != null && !confirmedValues.contains(mandatoryPermissionId)) {
                confirmedValues.add(mandatoryPermissionId);
              }
              onConfirm(confirmedValues);
            },
          );
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    initialSelection.isEmpty
                        ? 'Assign permissions'
                        : '${initialSelection.length} selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
            MultiSelectChipDisplay<String>(
              items: initialSelection.map((id) {
                final permission = permissionList.firstWhere(
                  (p) => p['id'].toString() == id,
                  orElse: () => {'id': id, 'name': 'Unknown'},
                );
                return MultiSelectItem<String>(id, permission['name'].toString());
              }).toList(),
              chipColor: const Color.fromRGBO(255, 130, 16, 1),
              textStyle: const TextStyle(color: Colors.white),
              onTap: (value) {
                if (value != mandatoryPermissionId) {
                  initialSelection.remove(value);
                  onConfirm(initialSelection);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showPermissionsDialog({
    required BuildContext context,
    required List<dynamic> permissionList,
    required List<String> selectedPermissions,
    required ValueChanged<List<String>> onConfirm,
    String? mandatoryPermissionId,
  }) {
    List<String> tempSelected = List.from(selectedPermissions);
    bool selectAll = permissionList.every((p) => tempSelected.contains(p['id'].toString()));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateSelectAll() {
              selectAll = permissionList.every((p) => tempSelected.contains(p['id'].toString()));
              setState(() {});
            }

            return AlertDialog(
              title: Text(
                'Select Permissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: Text('Select All'),
                      value: selectAll,
                      activeColor: const Color.fromRGBO(255, 130, 16, 1),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            tempSelected = permissionList.map((p) => p['id'].toString()).toList();
                          } else {
                            tempSelected = mandatoryPermissionId != null
                                ? [mandatoryPermissionId]
                                : [];
                          }
                          selectAll = value ?? false;
                        });
                      },
                    ),
                    Divider(),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: permissionList.length,
                        itemBuilder: (context, index) {
                          final permission = permissionList[index];
                          final permissionId = permission['id'].toString();
                          final isMandatory = permissionId == mandatoryPermissionId;

                          return CheckboxListTile(
                            title: Text(permission['name'] ?? 'Permission $permissionId'),
                            value: tempSelected.contains(permissionId),
                            activeColor: const Color.fromRGBO(255, 130, 16, 1),
                            onChanged: isMandatory
                                ? null // Disable checkbox for mandatory permission
                                : (value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!tempSelected.contains(permissionId)) {
                                          tempSelected.add(permissionId);
                                        }
                                      } else {
                                        tempSelected.remove(permissionId);
                                      }
                                      updateSelectAll();
                                    });
                                  },
                            enabled: !isMandatory,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 130, 16, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Reusable "Enter Venue Name" field
 static Widget customTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputAction textInputAction,
    String? Function(String?)? validator,
    InputDecoration? decoration, // Made decoration optional
    VoidCallback? onTap, // Optional onTap callback
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: decoration?.copyWith(hintText: hintText) ??
            textFieldDecoration.copyWith(hintText: hintText),
        textInputAction: textInputAction,
        validator: validator,
        onTap: onTap,
      ),
    );
  }
  // Reusable "Enter Category" field
  // (If you need a dropdown, you can adapt this or wrap it in an InkWell.)
  static Widget categoryField({required TextEditingController controller}) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        readOnly: true, // For a dropdown, typically readOnly
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Select category',
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      ),
    );
  }

  // Reusable "Enter Suburb" field
  static Widget suburbField({
    required TextEditingController controller,
    InputDecoration? decoration, // Added optional decoration for consistency
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: decoration?.copyWith(hintText: "Enter Suburb") ??
            textFieldDecoration.copyWith(hintText: "Enter Suburb"),
      ),
    );
  }


  // Reusable "Enter Notice" field
  static Widget noticeField({
    required TextEditingController controller,
    InputDecoration? decoration, // Added optional decoration for consistency
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: decoration?.copyWith(hintText: "Important Notice") ??
            textFieldDecoration.copyWith(hintText: "Important Notice"),
      ),
    );
  }

  // Reusable "Enter Description" field
  // Allows multiple lines if needed (e.g., for venue descriptions).
  static Widget descriptionField({
    required TextEditingController controller,
    int maxLines = 5,
  }) {
    return Container(
      decoration: textFieldBoxDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontFamily: 'YourFontFamily',
        ),
        decoration: textFieldDecoration.copyWith(
          hintText: 'Enter description',
          // The base textFieldDecoration might have padding,
          // so we can optionally remove contentPadding here if needed.
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // static Widget dropdownField({
  //   required List<String> items,
  //   required String selectedValue,
  //   required ValueChanged<String> onChanged,
  //   required String placeholder,
  // }) {
  //   return Container(
  //     decoration: textFieldBoxDecoration,
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         isExpanded: true,
  //         // If nothing is selected, we pass null to 'value' so the placeholder shows
  //         value: selectedValue.isEmpty ? null : selectedValue,
  //         hint: Text(
  //           placeholder,
  //           style: const TextStyle(
  //             color: Colors.grey,
  //             fontSize: 14.0,
  //             fontFamily: 'YourFontFamily', // Replace with your actual font family
  //           ),
  //         ),
  //         icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
  //         style: const TextStyle(
  //           color: Colors.black,
  //           fontSize: 14.0,
  //           fontFamily: 'YourFontFamily', // Replace with your actual font family
  //         ),
  //         items: items.map((String item) {
  //           return DropdownMenuItem<String>(
  //             value: item,
  //             child: Text(item),
  //           );
  //         }).toList(),
  //         onChanged: (value) {
  //           if (value != null) {
  //             onChanged(value);
  //           }
  //         },
  //       ),
  //     ),
  //   );
}
