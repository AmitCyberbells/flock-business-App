import 'dart:convert';
import 'dart:io';
import 'package:flock/constants.dart';
import 'package:flock/location.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Design {
  static const Color primaryColorOrange = Color.fromRGBO(255, 152, 0, 1);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color lightPurple = Color(0xFFF0F0F5);
  static const Color blue = Colors.blue;
  static const Color errorRed = Colors.red;
  static const double font14 = 14;
  static const double font15 = 15;
  static const double font16 = 16;
  static const double font18 = 18;
  static const double font20 = 20;
}

class GlobalImages {
  static const String camera = 'assets/camera.png';
  static const String closeBtn = 'assets/closebtn.png';
  static const String dropDown = 'assets/drop_down.png';
  static const String dropUp = 'assets/drop_up.png';
  static const String requestSent = 'assets/request.png';
  static const String photoGallery = 'assets/gallery.png';
  static const String openCamera = 'assets/camera.png';
}

class Server {
  static const String venues = "https://api.getflock.io/api/vendor/venues";
  static const String tags = "https://api.getflock.io/api/vendor/tags";
  static const String categoryList =
      "https://api.getflock.io/api/vendor/categories";
  static const String amenities =
      "https://api.getflock.io/api/vendor/amenities";
}

class AddEggScreen extends StatefulWidget {
  final dynamic allDetail;
  final List<dynamic>? allCategory;
  final List<dynamic>? allAmenities;

  const AddEggScreen({
    Key? key,
    this.allDetail,
    this.allCategory,
    this.allAmenities,
  }) : super(key: key);

  @override
  State<AddEggScreen> createState() => _AddEggScreenState();
}

class _AddEggScreenState extends State<AddEggScreen> {
  String tagSearchQuery = '';
  final GlobalKey _categoryFieldKey = GlobalKey();
  final GlobalKey _amenityFieldKey = GlobalKey();
  bool showCategoryDropdown = false;
  bool loader = false;
  bool dialogAlert = false;
  bool confirmPopup = false;
  bool showVenueDialog = false;
  final GlobalKey _tagsFieldKey = GlobalKey();
  bool showAmenityDropdown = false;
  bool showTagsDropdown = false;
  bool showDietaryDropdown = false;
  final GlobalKey _dietaryFieldKey = GlobalKey();

  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController suburbController;
  late TextEditingController noticeController;
  late TextEditingController descriptionController;

  // Form state
  bool nameofeggStatus = false;
  String catId = '';
  String nameofegg = '';
  String location = '';
  double lat = 0.0;
  double lng = 0.0;
  bool reportStatus = false;
  List<dynamic> allAmenities = [];
  List<String> arrOfAmenities = [];
  List<dynamic> allCategory = [];
  List<dynamic> tags = [];
  List<String> selectedTags = [];
  final ImagePicker _picker = ImagePicker();
  List<XFile> photos = [];
  String userId = "";
  List<dynamic> allDietaryTags = [];
  List<String> arrOfDietaryTags = [];

  // Validation constants
  static const int minVenueNameLength = 3;
  static const int minSuburbLength = 3;
  static const int minDescriptionLength = 10;
  static const int maxNoticeLength = 500;
  static const int maxPhotos = 10;
  static const int maxPhotoSizeMB = 5;
  static const int maxTags = 5;

  // Error state variables
  String? nameError;
  String? categoryError;
  String? suburbError;
  String? locationError;
  String? amenitiesError;
  String? descriptionError;
  String? photosError;
  String? noticeError;
  String? tagsError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    suburbController = TextEditingController();
    noticeController = TextEditingController();
    descriptionController = TextEditingController();

    // Add listeners for immediate validation
    nameController.addListener(() => validateName());
    suburbController.addListener(() => validateSuburb());
    noticeController.addListener(() => validateNotice());
    descriptionController.addListener(() => validateDescription());

    if (widget.allCategory != null) {
      allCategory = widget.allCategory!;
    }
    if (widget.allAmenities != null) {
      allAmenities = widget.allAmenities!;
    }
    if (widget.allDetail != null) {
      populateExistingVenue(widget.allDetail);
    }

    getUserId();
    getVenueTags();
    getCategoriesAmenties();
    getDietaryTags();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showVenueDialog = true;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    suburbController.dispose();
    noticeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Validation methods
  void validateName() {
    setState(() {
      if (nameController.text.trim().isEmpty) {
        nameError = "Venue name is required";
      } else if (nameController.text.trim().length < minVenueNameLength) {
        nameError =
            "Venue name must be at least $minVenueNameLength characters";
      } else {
        nameError = null;
      }
    });
  }

  void validateCategory() {
    setState(() {
      if (nameofegg.isEmpty || catId.isEmpty) {
        categoryError = "Please select a category";
      } else {
        categoryError = null;
      }
    });
  }

  void validateSuburb() {
    setState(() {
      if (suburbController.text.trim().isEmpty) {
        suburbError = "Suburb is required";
      } else if (suburbController.text.trim().length < minSuburbLength) {
        suburbError = "Suburb must be at least $minSuburbLength characters";
      } else {
        suburbError = null;
      }
    });
  }

  void validateLocation() {
    setState(() {
      if (location.isEmpty || lat == 0.0 || lng == 0.0) {
        locationError = "Please select a valid location";
      } else if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        locationError = "Invalid location coordinates";
      } else {
        locationError = null;
      }
    });
  }

  void validateAmenities() {
    setState(() {
      if (arrOfAmenities.isEmpty) {
        amenitiesError = "Please select at least one amenity";
      } else {
        amenitiesError = null;
      }
    });
  }

  void validateDescription() {
    setState(() {
      if (descriptionController.text.trim().isEmpty) {
        descriptionError = "Description is required";
      } else if (descriptionController.text.trim().length <
          minDescriptionLength) {
        descriptionError =
            "Description must be at least $minDescriptionLength characters";
      } else {
        descriptionError = null;
      }
    });
  }

  void validatePhotos() {
    setState(() {
      if (photos.isEmpty) {
        photosError = "Please upload at least one photo";
      } else {
        photosError = null;
      }
    });
  }

  void validateNotice() {
    setState(() {
      if (noticeController.text.length > maxNoticeLength) {
        noticeError = "Notice must be less than $maxNoticeLength characters";
      } else {
        noticeError = null;
      }
    });
  }

  void validateTags() {
    setState(() {
      if (selectedTags.length > maxTags) {
        tagsError = "Maximum $maxTags tags allowed";
      } else {
        tagsError = null;
      }
    });
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userid') ?? "";
    });
  }

  Future<void> getVenueTags() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(Server.tags),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final tagsJson = jsonDecode(response.body);
        setState(() {
          tags = tagsJson['data'] ?? [];
        });
      } else {
        // Fluttertoast.showToast(msg: "Failed to load tags: ${response.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load tags");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching tags: $e");
    }
  }

  Future<void> getDietaryTags() async {
    try {
      final token = await getToken();
      final dietaryResponse = await http.get(
        Uri.parse("https://api.getflock.io/api/vendor/dietary-tags"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (dietaryResponse.statusCode == 200) {
        final dietaryJson = jsonDecode(dietaryResponse.body);
        setState(() {
          allDietaryTags = dietaryJson['data'] ?? [];
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load dietary tags: ${dietaryResponse.statusCode}",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching dietary tags: $e");
    }
  }

  Future<void> getCategoriesAmenties() async {
    try {
      final token = await getToken();
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      final categoriesResponse = await http.get(
        Uri.parse(Server.categoryList),
        headers: headers,
      );
      final amenitiesResponse = await http.get(
        Uri.parse(Server.amenities),
        headers: headers,
      );
      if (categoriesResponse.statusCode == 200) {
        final categoriesJson = jsonDecode(categoriesResponse.body);
        setState(() {
          allCategory = categoriesJson['data'] ?? [];
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load categories: ${categoriesResponse.statusCode}",
        );
      }
      if (amenitiesResponse.statusCode == 200) {
        final amenitiesJson = jsonDecode(amenitiesResponse.body);
        setState(() {
          allAmenities = amenitiesJson['data'] ?? [];
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load amenities: ${amenitiesResponse.statusCode}",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching categories/amenities: $e");
    }
  }

  void populateExistingVenue(dynamic detail) {
    final existingName = detail['venue_name'] ?? '';
    final existingSuburb = detail['suburb'] ?? '';
    final existingLocation = detail['location'] ?? '';
    final existingNotice = detail['important_notice'] ?? '';
    final existingDescription = detail['description'] ?? '';

    nameController.text = existingName;
    suburbController.text = existingSuburb;
    noticeController.text = existingNotice;
    descriptionController.text = existingDescription;

    catId = detail['cat_id']?.toString() ?? '';
    nameofegg = '';
    lat = double.tryParse('${detail['lat']}') ?? 0.0;
    lng = double.tryParse('${detail['lon']}') ?? 0.0;
    location = existingLocation;

    final aList = detail['amenties'] as List<dynamic>? ?? [];
    arrOfAmenities = aList.map((e) => e['id'].toString()).toList();

    // Validate initial values
    validateName();
    validateSuburb();
    validateNotice();
    validateDescription();
    validateCategory();
    validateLocation();
    validateAmenities();
    validatePhotos();
    validateTags();
  }

  void handleTagChange(List<int?> selectedValues) {
    final validValues = selectedValues.whereType<int>().toList();
    setState(() {
      selectedTags = validValues.map((e) => e.toString()).toList();
    });
    validateTags();
  }

  void toggleNameOfEggStatus() {
    setState(() {
      nameofeggStatus = !nameofeggStatus;
    });
    validateCategory();
  }

  void selectCategory(Map<String, dynamic> item) {
    setState(() {
      nameofegg = item['name'];
      catId = item['id'].toString();
      nameofeggStatus = false;
    });
    validateCategory();
  }

  void toggleReportStatus() {
    setState(() {
      reportStatus = !reportStatus;
    });
    validateAmenities();
  }

  void selectAmenity(Map<String, dynamic> item) {
    final id = item['id'].toString();
    if (!arrOfAmenities.contains(id)) {
      setState(() {
        arrOfAmenities.add(id);
      });
    }
    validateAmenities();
  }

  void removeAmenity(String item) {
    setState(() {
      arrOfAmenities.remove(item);
    });
    validateAmenities();
  }

  void showImageDialog() {
    setState(() {
      dialogAlert = true;
    });
  }

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null && await validatePhoto(image)) {
      setState(() {
        photos.add(image);
      });
      validatePhotos();
    }
    setState(() {
      dialogAlert = false;
    });
  }

  Future<void> pickFromGallery() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      List<XFile> validImages = [];
      for (var image in selectedImages) {
        if (await validatePhoto(image)) {
          validImages.add(image);
        }
      }
      setState(() {
        if (photos.length + validImages.length <= maxPhotos) {
          photos.addAll(validImages);
        } else {
          photosError = "Maximum $maxPhotos photos allowed";
        }
      });
      validatePhotos();
    }
    setState(() {
      dialogAlert = false;
    });
  }

  Future<bool> validatePhoto(XFile photo) async {
    final fileSize = await photo.length();
    final sizeInMB = fileSize / (1024 * 1024);
    if (sizeInMB > maxPhotoSizeMB) {
      setState(() {
        photosError = "Photo size must be less than $maxPhotoSizeMB MB";
      });
      return false;
    }
    return true;
  }

  void removePhoto(int index) {
    setState(() {
      photos.removeAt(index);
    });
    validatePhotos();
  }

  void pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPicker()),
    );
    if (result != null && result is Map) {
      setState(() {
        location = result['address'] ?? "";
        lat = result['lat'] ?? 0.0;
        lng = result['lng'] ?? 0.0;
      });
      validateLocation();
    }
  }

  Future<void> useCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission permanently denied");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      location = "Current Location ($lat, $lng)";
    });
    validateLocation();
  }

  void showManualLocationDialog() {
    final locController = TextEditingController(text: location);
    final latController = TextEditingController(text: lat.toString());
    final lonController = TextEditingController(text: lng.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Location Details"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(
                    labelText: "Location Name or Address",
                  ),
                ),
                TextField(
                  controller: latController,
                  decoration: const InputDecoration(labelText: "Latitude"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: lonController,
                  decoration: const InputDecoration(labelText: "Longitude"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newLat = double.tryParse(latController.text);
                final newLng = double.tryParse(lonController.text);
                if (newLat == null || newLat < -90 || newLat > 90) {
                  Fluttertoast.showToast(msg: "Invalid latitude (-90 to 90)");
                  return;
                }
                if (newLng == null || newLng < -180 || newLng > 180) {
                  Fluttertoast.showToast(
                    msg: "Invalid longitude (-180 to 180)",
                  );
                  return;
                }
                setState(() {
                  location = locController.text;
                  lat = newLat;
                  lng = newLng;
                });
                validateLocation();
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool validateForm() {
    validateName();
    validateCategory();
    validateSuburb();
    validateLocation();
    validateAmenities();
    validateDescription();
    validatePhotos();
    validateNotice();
    validateTags();

    return nameError == null &&
        categoryError == null &&
        suburbError == null &&
        locationError == null &&
        amenitiesError == null &&
        descriptionError == null &&
        photosError == null &&
        noticeError == null &&
        tagsError == null;
  }

  void updateBtn() {
    if (validateForm()) {
      addVenueApi();
    } else {
      Fluttertoast.showToast(msg: "Please fix the errors in the form");
    }
  }

  Future<void> addVenueApi() async {
    setState(() => loader = true);
    try {
      final token = await getToken();
      final uri = Uri.parse(Server.venues);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['name'] = nameController.text.trim();
      request.fields['category_id'] = catId;
      request.fields['suburb'] = suburbController.text.trim();
      request.fields['location'] = location;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lng.toString();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['important_notice'] = noticeController.text.trim();

      for (var i = 0; i < selectedTags.length; i++) {
        request.fields["tag_ids[$i]"] = selectedTags[i];
      }
      for (var i = 0; i < arrOfAmenities.length; i++) {
        request.fields["amenity_ids[$i]"] = arrOfAmenities[i];
      }
      for (var i = 0; i < arrOfDietaryTags.length; i++) {
        request.fields["dietary_ids[$i]"] = arrOfDietaryTags[i];
      }

      for (var photo in photos) {
        final fileStream = http.ByteStream(photo.openRead());
        final length = await photo.length();
        final multipartFile = http.MultipartFile(
          'images[]',
          fileStream,
          length,
          filename: photo.name,
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      _handleResponseStatus(response, responseString);
    } catch (e) {
      setState(() => loader = false);
      Fluttertoast.showToast(msg: "An error occurred: $e");
      print('Exception: $e');
    }
  }

  void _handleResponseStatus(
    http.StreamedResponse response,
    String responseString,
  ) {
    if (response.statusCode < 300) {
      final responseJson = jsonDecode(responseString);
      Fluttertoast.showToast(
        msg: responseJson['message'] ?? "Venue added successfully",
      );
      setState(() {
        loader = false;
        confirmPopup = true;
      });
    } else {
      final responseJson = jsonDecode(responseString);
      if (responseJson['status'] == 1) {
        Fluttertoast.showToast(
          msg: responseJson['message'] ?? "Venue status updated to success.",
        );
        setState(() {
          loader = false;
          confirmPopup = true;
        });
      } else {
        Fluttertoast.showToast(
          msg:
              "Error: ${response.statusCode} - ${responseJson['message'] ?? 'Something went wrong.'}",
        );
        print('Error Response: $responseString');
        setState(() => loader = false);
      }
    }
  }

  void onDonePressed() {
    setState(() {
      confirmPopup = false;
    });
    Navigator.pop(context, true);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(msg: "Could not launch $url");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error launching $url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/back_updated.png',
                          height: 40,
                          width: 34,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.allDetail != null
                                ? 'Edit Venue'
                                : 'Add New Venue',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Enter Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppConstants.customTextField(
                                controller: nameController,
                                hintText: 'Enter venue name',
                                textInputAction: TextInputAction.next,
                                decoration:
                                    nameError != null
                                        ? AppConstants.textFieldDecoration
                                            .copyWith(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Design.errorRed,
                                                ),
                                              ),
                                            )
                                        : AppConstants.textFieldDecoration,
                              ),
                              if (nameError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    nameError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Design.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      categoryError != null
                                          ? Border.all(color: Design.errorRed)
                                          : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      key: _categoryFieldKey,
                                      onTap: () {
                                        setState(() {
                                          showCategoryDropdown =
                                              !showCategoryDropdown;
                                        });
                                        validateCategory();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Design.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              nameofegg.isEmpty
                                                  ? "Select Category"
                                                  : nameofegg,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            Icon(
                                              showCategoryDropdown
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (showCategoryDropdown)
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: 38.0 * 5,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Design.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Scrollbar(
                                                thumbVisibility: true,
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: allCategory.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final category =
                                                        allCategory[index];
                                                    final isSelected =
                                                        catId ==
                                                        category['id']
                                                            .toString();
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          catId =
                                                              category['id']
                                                                  .toString();
                                                          nameofegg =
                                                              category['name'];
                                                          showCategoryDropdown =
                                                              false;
                                                        });
                                                        validateCategory();
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 6,
                                                            ),
                                                        color:
                                                            isSelected
                                                                ? Design
                                                                    .primaryColorOrange
                                                                    .withOpacity(
                                                                      0.1,
                                                                    )
                                                                : Colors
                                                                    .transparent,
                                                        child: Text(
                                                          category['name'],
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (categoryError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    categoryError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Design.lightPurple,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      tagsError != null
                                          ? Border.all(color: Design.errorRed)
                                          : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      key: _tagsFieldKey,
                                      onTap: () {
                                        setState(() {
                                          showTagsDropdown = !showTagsDropdown;
                                          tagSearchQuery = '';
                                        });
                                        validateTags();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Design.white,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                selectedTags.isEmpty
                                                    ? "Select Tags"
                                                    : selectedTags
                                                        .map(
                                                          (id) =>
                                                              tags.firstWhere(
                                                                (tag) =>
                                                                    tag['id']
                                                                        .toString() ==
                                                                    id,
                                                                orElse:
                                                                    () => {
                                                                      'name':
                                                                          'Unknown',
                                                                    },
                                                              )['name'],
                                                        )
                                                        .join(", "),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              showTagsDropdown
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (showTagsDropdown)
                                      Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 38.0 * 6 + 48,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Design.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 6,
                                                  ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.search,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                            hintText:
                                                                "Search tags...",
                                                            hintStyle:
                                                                TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  fontSize: 14,
                                                                ),
                                                            border:
                                                                InputBorder
                                                                    .none,
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          tagSearchQuery =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              child: Scrollbar(
                                                thumbVisibility: true,
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      tags
                                                          .where(
                                                            (tag) => tag['name']
                                                                .toLowerCase()
                                                                .contains(
                                                                  tagSearchQuery
                                                                      .toLowerCase(),
                                                                ),
                                                          )
                                                          .length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final filteredTags =
                                                        tags
                                                            .where(
                                                              (
                                                                tag,
                                                              ) => tag['name']
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    tagSearchQuery
                                                                        .toLowerCase(),
                                                                  ),
                                                            )
                                                            .toList();
                                                    final tag =
                                                        filteredTags[index];
                                                    final isSelected =
                                                        selectedTags.contains(
                                                          tag['id'].toString(),
                                                        );
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          final tagId =
                                                              tag['id']
                                                                  .toString();
                                                          if (selectedTags
                                                              .contains(
                                                                tagId,
                                                              )) {
                                                            selectedTags.remove(
                                                              tagId,
                                                            );
                                                          } else {
                                                            if (selectedTags
                                                                    .length >=
                                                                maxTags) {
                                                              tagsError =
                                                                  "You can select up to $maxTags tags!";
                                                              return;
                                                            }
                                                            selectedTags.add(
                                                              tagId,
                                                            );
                                                          }
                                                        });
                                                        validateTags();
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 6,
                                                            ),
                                                        color:
                                                            isSelected
                                                                ? Design
                                                                    .primaryColorOrange
                                                                    .withOpacity(
                                                                      0.1,
                                                                    )
                                                                : Colors
                                                                    .transparent,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              tag['name'],
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    isSelected
                                                                        ? Design
                                                                            .primaryColorOrange
                                                                        : Colors
                                                                            .black,
                                                                fontWeight:
                                                                    isSelected
                                                                        ? FontWeight
                                                                            .w500
                                                                        : FontWeight
                                                                            .normal,
                                                              ),
                                                            ),
                                                            if (isSelected)
                                                              Icon(
                                                                Icons.check,
                                                                size: 18,
                                                                color:
                                                                    Design
                                                                        .primaryColorOrange,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                6.0,
                                              ),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      showTagsDropdown = false;
                                                    });
                                                    validateTags();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Design
                                                            .primaryColorOrange,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "Done",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (tagsError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    tagsError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppConstants.suburbField(
                                controller: suburbController,
                                decoration:
                                    suburbError != null
                                        ? AppConstants.textFieldDecoration
                                            .copyWith(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Design.errorRed,
                                                ),
                                              ),
                                            )
                                        : AppConstants.textFieldDecoration,
                              ),
                              if (suburbError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    suburbError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: pickLocation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  decoration: AppConstants
                                      .textFieldBoxDecoration
                                      .copyWith(
                                        border:
                                            locationError != null
                                                ? Border.all(
                                                  color: Design.errorRed,
                                                )
                                                : null,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          location.isEmpty
                                              ? "Pick location"
                                              : location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'YourFontFamily',
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (locationError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    locationError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Design.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      amenitiesError != null
                                          ? Border.all(color: Design.errorRed)
                                          : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      key: _amenityFieldKey,
                                      onTap: () {
                                        setState(() {
                                          showAmenityDropdown =
                                              !showAmenityDropdown;
                                        });
                                        validateAmenities();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Design.white,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              arrOfAmenities.isEmpty
                                                  ? "Select Amenities"
                                                  : arrOfAmenities
                                                      .map(
                                                        (id) =>
                                                            allAmenities.firstWhere(
                                                              (amenity) =>
                                                                  amenity['id']
                                                                      .toString() ==
                                                                  id,
                                                            )['name'],
                                                      )
                                                      .join(", "),
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            Icon(
                                              showAmenityDropdown
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (showAmenityDropdown)
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: 32 * 6 + 48,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Design.white,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: allAmenities.length,
                                                itemBuilder: (context, index) {
                                                  final amenity =
                                                      allAmenities[index];
                                                  final isSelected =
                                                      arrOfAmenities.contains(
                                                        amenity['id']
                                                            .toString(),
                                                      );
                                                  return ListTile(
                                                    dense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                          vertical: 1,
                                                        ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    title: Text(
                                                      amenity['name'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            arrOfAmenities.contains(
                                                                  amenity['id']
                                                                      .toString(),
                                                                )
                                                                ? Design
                                                                    .primaryColorOrange
                                                                : Colors.black,
                                                        fontWeight:
                                                            arrOfAmenities.contains(
                                                                  amenity['id']
                                                                      .toString(),
                                                                )
                                                                ? FontWeight
                                                                    .w500
                                                                : FontWeight
                                                                    .normal,
                                                      ),
                                                    ),
                                                    trailing:
                                                        arrOfAmenities.contains(
                                                              amenity['id']
                                                                  .toString(),
                                                            )
                                                            ? Icon(
                                                              Icons.check,
                                                              color:
                                                                  Design
                                                                      .primaryColorOrange,
                                                              size: 18,
                                                            )
                                                            : null,
                                                    onTap: () {
                                                      setState(() {
                                                        if (arrOfAmenities
                                                            .contains(
                                                              amenity['id']
                                                                  .toString(),
                                                            )) {
                                                          arrOfAmenities.remove(
                                                            amenity['id']
                                                                .toString(),
                                                          );
                                                        } else {
                                                          arrOfAmenities.add(
                                                            amenity['id']
                                                                .toString(),
                                                          );
                                                        }
                                                      });
                                                      validateAmenities();
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 8,
                                                  ),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      showAmenityDropdown =
                                                          false;
                                                    });
                                                    validateAmenities();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Design
                                                            .primaryColorOrange,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "Done",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (amenitiesError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    amenitiesError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              color: Design.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  key: _dietaryFieldKey,
                                  onTap: () {
                                    setState(() {
                                      showDietaryDropdown =
                                          !showDietaryDropdown;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Design.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          arrOfDietaryTags.isEmpty
                                              ? "Select Dietary Tags"
                                              : arrOfDietaryTags
                                                  .map(
                                                    (id) =>
                                                        allDietaryTags.firstWhere(
                                                          (diet) =>
                                                              diet['id']
                                                                  .toString() ==
                                                              id,
                                                          orElse:
                                                              () => {
                                                                'name':
                                                                    'Unknown',
                                                              },
                                                        )['name'],
                                                  )
                                                  .join(", "),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        Icon(
                                          showDietaryDropdown
                                              ? Icons.arrow_drop_up
                                              : Icons.arrow_drop_down,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (showDietaryDropdown)
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 32 * 6 + 48,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Design.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: allDietaryTags.length,
                                            itemBuilder: (context, index) {
                                              final dietTag =
                                                  allDietaryTags[index];
                                              final tagId =
                                                  dietTag['id'].toString();
                                              final isSelected =
                                                  arrOfDietaryTags.contains(
                                                    tagId,
                                                  );
                                              return ListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 1,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                title: Text(
                                                  dietTag['name'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        isSelected
                                                            ? Design
                                                                .primaryColorOrange
                                                            : Colors.black,
                                                    fontWeight:
                                                        isSelected
                                                            ? FontWeight.w500
                                                            : FontWeight.normal,
                                                  ),
                                                ),
                                                trailing:
                                                    isSelected
                                                        ? Icon(
                                                          Icons.check,
                                                          color:
                                                              Design
                                                                  .primaryColorOrange,
                                                          size: 18,
                                                        )
                                                        : null,
                                                onTap: () {
                                                  setState(() {
                                                    if (arrOfDietaryTags
                                                        .contains(tagId)) {
                                                      arrOfDietaryTags.remove(
                                                        tagId,
                                                      );
                                                    } else {
                                                      arrOfDietaryTags.add(
                                                        tagId,
                                                      );
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 8,
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  showDietaryDropdown = false;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Design.primaryColorOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: const Text(
                                                "Done",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppConstants.noticeField(
                                controller: noticeController,
                                decoration:
                                    noticeError != null
                                        ? AppConstants.textFieldDecoration
                                            .copyWith(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Design.errorRed,
                                                ),
                                              ),
                                            )
                                        : AppConstants.textFieldDecoration,
                              ),
                              if (noticeError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    noticeError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: AppConstants.textFieldBoxDecoration
                                    .copyWith(
                                      border:
                                          descriptionError != null
                                              ? Border.all(
                                                color: Design.errorRed,
                                              )
                                              : null,
                                    ),
                                child: TextField(
                                  controller: descriptionController,
                                  maxLines: 5,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontFamily: 'YourFontFamily',
                                  ),
                                  decoration: AppConstants.textFieldDecoration
                                      .copyWith(
                                        hintText: "Description",
                                        border:
                                            descriptionError != null
                                                ? OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Design.errorRed,
                                                  ),
                                                )
                                                : null,
                                      ),
                                ),
                              ),
                              if (descriptionError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    descriptionError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Upload Pictures',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: showImageDialog,
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: Design.white,
                                        borderRadius: BorderRadius.circular(5),
                                        border:
                                            photosError != null
                                                ? Border.all(
                                                  color: Design.errorRed,
                                                )
                                                : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          GlobalImages.camera,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: photos.length,
                                        itemBuilder: (context, index) {
                                          final XFile photo = photos[index];
                                          return Container(
                                            width: 90,
                                            height: 90,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Design.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Image.file(
                                                    File(photo.path),
                                                    fit: BoxFit.cover,
                                                    width: 90,
                                                    height: 90,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 2,
                                                  right: 2,
                                                  child: InkWell(
                                                    onTap:
                                                        () =>
                                                            removePhoto(index),
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration:
                                                          const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (photosError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 12,
                                  ),
                                  child: Text(
                                    photosError!,
                                    style: TextStyle(
                                      color: Design.errorRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: updateBtn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Design.primaryColorOrange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Save Venue",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loader)
            Stack(
              children: [
                Container(color: Colors.black.withOpacity(0.14)),
                Container(
                  color: Colors.white10,
                  child: Center(
                    child: Image.asset(
                      'assets/Bird_Full_Eye_Blinking.gif',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
          if (dialogAlert)
            Center(
              child: Container(
                width: deviceWidth * 0.8,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Design.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: pickFromCamera,
                      child: Row(
                        children: const [
                          Icon(Icons.camera_alt, size: 24),
                          SizedBox(width: 10),
                          Text("Take a Photo"),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    InkWell(
                      onTap: pickFromGallery,
                      child: Row(
                        children: const [
                          Icon(Icons.photo_library, size: 24),
                          SizedBox(width: 10),
                          Text("Choose from Gallery"),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => dialogAlert = false),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (confirmPopup)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    width: deviceWidth * 0.85,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Design.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          GlobalImages.requestSent,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.allDetail != null
                              ? 'The venue has been updated successfully.'
                              : 'Venue request sent. Please check your email for further instructions.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: onDonePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Design.primaryColorOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Done"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (showVenueDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: deviceWidth - 30,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "How do I list a venue?",
                          style: TextStyle(
                            fontSize: Design.font18,
                            fontWeight: FontWeight.w500,
                            color: Design.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Users that subscribe their venues to Flock can manage them here in the app.",
                            style: TextStyle(
                              fontSize: Design.font14,
                              color: Design.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "For more information visit here",
                            style: TextStyle(
                              fontSize: Design.font14,
                              color: Design.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => launchUrl(
                                Uri.parse('https://getflock.io/business/'),
                              ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "https://getflock.io/business/",
                              style: TextStyle(
                                fontSize: Design.font14,
                                color: Design.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showVenueDialog = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Design.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "Got it!",
                              style: TextStyle(
                                color: Design.primaryColorOrange,
                                fontSize: Design.font15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const LocationPickerScreen({Key? key, required this.initialPosition})
    : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng pickedPosition = const LatLng(33.6844, 73.0479);

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition.latitude != 0.0 &&
        widget.initialPosition.longitude != 0.0) {
      pickedPosition = widget.initialPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        backgroundColor: Design.primaryColorOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (pickedPosition.latitude < -90 ||
                  pickedPosition.latitude > 90 ||
                  pickedPosition.longitude < -180 ||
                  pickedPosition.longitude > 180) {
                Fluttertoast.showToast(msg: "Invalid location coordinates");
                return;
              }
              Navigator.pop(context, {
                'address':
                    "Selected Location (${pickedPosition.latitude}, ${pickedPosition.longitude})",
                'lat': pickedPosition.latitude,
                'lng': pickedPosition.longitude,
              });
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: pickedPosition, zoom: 14),
        onMapCreated: (controller) => mapController = controller,
        onTap: (LatLng latLng) {
          setState(() {
            pickedPosition = latLng;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId("pickedLocation"),
            position: pickedPosition,
          ),
        },
      ),
    );
  }
}
