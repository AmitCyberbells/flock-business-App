import 'dart:convert';
import 'dart:io';
import 'package:flock/constants.dart';
import 'package:flock/venue.dart' show Design;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* ───────────────────────────── SCREEN ───────────────────────────── */

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({Key? key}) : super(key: key);
  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  /* ---------------- controllers & form ---------------- */
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venuePointsController = TextEditingController();
  final _appPointsController = TextEditingController();
  final _redemptionLimitController = TextEditingController();
  final _scrollController = ScrollController();
  bool _venueValidationError = false;
  bool _imageValidationError = false;
  bool _redeemTypeValidationError = false;
  bool _showValidationMessages = false;

  /* ---------------- page state ---------------- */
  List<Map<String, dynamic>> _venues = [
    {'id': null, 'name': 'Select Venue'},
  ];
  Map<String, dynamic>? _selectedVenue;

  bool _useVenuePoints = false;
  bool _useAppPoints = false;

  XFile? _pickedImage;

  bool _isVenuesLoading = false;
  bool _isSubmitting = false;

  /* ───────────────────────── lifecycle ───────────────────────── */
 
  void initState() {
    super.initState();
    _selectedVenue = _venues.first;
    _fetchVenues();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).addListener(_onFocusChange);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _venuePointsController.dispose();
    _appPointsController.dispose();
    _redemptionLimitController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /* ───────────────────────── helpers ───────────────────────── */

  Future<String?> _getToken() async =>
      (await SharedPreferences.getInstance()).getString('access_token');

  Future<void> _fetchVenues() async {
    setState(() {
      _isVenuesLoading = true;
    });

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('https://api.getflock.io/api/vendor/venues'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == 'success' && json['data'] != null) {
          final v = (json['data'] as List<dynamic>)
              .map((e) => {'id': e['id'], 'name': e['name'] ?? 'Unnamed'})
              .toList();
          _venues = [
            {'id': null, 'name': 'Select Venue'},
            ...v,
          ];
          _selectedVenue = _venues.first;
        }
      }
    } catch (e) {
      // Handle error silently
    }
    if (mounted) setState(() => _isVenuesLoading = false);
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _pickedImage = img;
        _imageValidationError = false;
      });
    }
  }

  void _onFocusChange() {
    if (FocusScope.of(context).hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /* ───────────────────────── submit ───────────────────────── */

  Future<void> _submitOffer() async {
    setState(() {
      _venueValidationError = _selectedVenue == null || _selectedVenue!['id'] == null;
      _imageValidationError = _pickedImage == null;
      _redeemTypeValidationError = !_useVenuePoints && !_useAppPoints;
      _showValidationMessages = true;
    });

    if (!_formKey.currentState!.validate() ||
        _venueValidationError ||
        _imageValidationError ||
        _redeemTypeValidationError) {
      _scrollToError();
      return;
    }

    var venuePts = _venuePointsController.text.trim();
    var appPts = _appPointsController.text.trim();
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();
    final limitRaw = _redemptionLimitController.text.trim();

    /* redemption-limit → int */
    int redemptionLimit = -1;
    if (limitRaw.isNotEmpty) {
      redemptionLimit = int.tryParse(limitRaw) ?? -2;
      if (redemptionLimit < -1) {
        _scrollToError();
        return;
      }
    }

    /* guarantee numeric strings for disabled fields */
    if (!_useVenuePoints) venuePts = '0';
    if (!_useAppPoints) appPts = '0';

    setState(() => _isSubmitting = true);

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.getflock.io/api/vendor/offers'),
    )..headers['Authorization'] = 'Bearer $token'
        ..fields.addAll({
          'name': name,
          'description': desc,
          'venue_id': _selectedVenue!['id'].toString(),
          'redeem_by': _useVenuePoints && _useAppPoints
              ? 'both'
              : _useVenuePoints
                  ? 'venue_points'
                  : 'feather_points',
          'venue_points': venuePts,
          'feather_points': appPts,
          'redemption_limit': redemptionLimit.toString(),
        });

    if (_pickedImage != null) {
      req.files.add(
        await http.MultipartFile.fromPath('images[]', _pickedImage!.path),
      );
    }

    try {
      final res = await http.Response.fromStream(await req.send());
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data['status'] == 'success' ||
            (data['message'] ?? '').toString().toLowerCase().contains('success')) {
          if (mounted) _showSuccessDialog();
        }
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Offer added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  void _scrollToError() {
    final ctx = _formKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
      );
    }
  }


  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppConstants.customAppBar(context: context, title: 'Add New Offer'),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title of Offer', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  AppConstants.customTextField(
                    controller: _nameController,
                    hintText: 'Title of Offer',
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        v == null || v.isEmpty ? '' : null,
                  ),
                  if (_showValidationMessages &&
                      _nameController.text.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        'Please Enter Title',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('Venue', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildVenueDropdown(),
                  if (_venueValidationError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        'Please select venue',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Redemption Requirements',
                    style: TextStyle(fontSize: 16),
                  ),
                  _buildRedeemTypeRow(),
                  if (_redeemTypeValidationError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        'Select at least one redeem type',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (_useVenuePoints || _useAppPoints) ...[
                    _buildPointsInputs(),
                    const SizedBox(height: 16),
                  ],
                  const Text('Description', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildDescriptionField(),
                  if (_showValidationMessages &&
                      _descriptionController.text.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        'Please enter the description',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildRedemptionLimit(),
                  if (_showValidationMessages &&
                      _redemptionLimitController.text.isNotEmpty &&
                      (int.tryParse(_redemptionLimitController.text) == null ||
                          int.parse(_redemptionLimitController.text) < -1))
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        'Invalid redemption limit',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  if (_imageValidationError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        'Please upload an image',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 130, 16, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitOffer,
                      child: _isSubmitting
                          ? Container(
                              color: Colors.white.withOpacity(0.19),
                              child: Center(
                                child: Image.asset(
                                  'assets/Bird_Full_Eye_Blinking.gif',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            )
                          : const Text(
                              'Save Offer',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildVenueDropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _scrollToBottom(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _venueValidationError ? Colors.red : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _isVenuesLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Loading venues...',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<Map<String, dynamic>>(
                          value: _selectedVenue,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Design.primaryColorOrange,
                          ),
                          items: _venues
                              .map(
                                (v) => DropdownMenuItem<Map<String, dynamic>>(
                                  value: v,
                                  child: Text(
                                    v['name'] ?? 'Unnamed',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedVenue = v;
                            _venueValidationError = false;
                            _scrollToBottom();
                          }),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );

  Widget _buildRedeemTypeRow() {
    Color _label(bool enabled) => enabled ? Colors.black : Colors.grey.shade500;

    return Wrap(
      spacing: 24,
      runSpacing: -15,
      children: [
        Transform.translate(
          offset: const Offset(-8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                activeColor: const Color.fromRGBO(255, 130, 16, 1),
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
                value: _useVenuePoints,
                onChanged: (value) {
                  setState(() {
                    _useVenuePoints = value ?? false;
                    _redeemTypeValidationError = !_useVenuePoints && !_useAppPoints;
                  });
                },
              ),
              Text('Venue Points', style: TextStyle(color: _label(true))),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(12, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                activeColor: const Color.fromRGBO(255, 130, 16, 1),
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
                value: _useAppPoints,
                onChanged: (value) {
                  setState(() {
                    _useAppPoints = value ?? false;
                    _redeemTypeValidationError = !_useVenuePoints && !_useAppPoints;
                  });
                },
              ),
              Text('Feathers', style: TextStyle(color: _label(true))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointsInputs() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_useVenuePoints)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _venuePointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration('Venue Points (min 5)'),
                    validator: (v) {
                      if (!_useVenuePoints) return null;
                      if (v == null || v.isEmpty) return 'Enter Venue Points';
                      final p = int.tryParse(v);
                      if (p == null || p < 5) return 'Min 5';
                      return null;
                    },
                  ),
                  if (_showValidationMessages &&
                      _useVenuePoints &&
                      (_venuePointsController.text.isEmpty ||
                          (int.tryParse(_venuePointsController.text) != null &&
                              int.parse(_venuePointsController.text) < 5)))
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        _venuePointsController.text.isEmpty
                            ? 'Please enter Venue Points'
                            : 'Minimum 5 points',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          if (_useVenuePoints && _useAppPoints) const SizedBox(width: 16),
          if (_useAppPoints)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _appPointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration('Feathers (min 5)'),
                    validator: (v) {
                      if (!_useAppPoints) return null;
                      if (v == null || v.isEmpty) return 'Enter Feathers';
                      final p = int.tryParse(v);
                      if (p == null || p < 5) return 'Min 5';
                      return null;
                    },
                  ),
                  if (_showValidationMessages &&
                      _useAppPoints &&
                      (_appPointsController.text.isEmpty ||
                          (int.tryParse(_appPointsController.text) != null &&
                              int.parse(_appPointsController.text) < 5)))
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 8),
                      child: Text(
                        _appPointsController.text.isEmpty
                            ? 'Please enter Feathers'
                            : 'Minimum 5 points',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
        ],
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _buildDescriptionField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Offer description',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter description' : null,
            ),
          ),
        ],
      );

  Widget _buildRedemptionLimit() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Redemption Limit  ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextSpan(
                  text: '(Leave blank for unlimited)',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppConstants.customTextField(
            controller: _redemptionLimitController,
            hintText: 'Redemption Limit',
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                final p = int.tryParse(v);
                if (p == null || p < -1) return 'Invalid';
              }
              return null;
            },
          ),
        ],
      );

  Widget _buildImagePicker() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Pictures', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          _pickedImage == null
              ? Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _imageValidationError
                            ? Colors.red
                            : Colors.grey.shade400),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 50),
                    onPressed: () {
                      _pickImage();
                      _scrollToBottom();
                    },
                  ),
                )
              : InkWell(
                  onTap: () {
                    _pickImage();
                    _scrollToBottom();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pickedImage!.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
        ],
      );
}