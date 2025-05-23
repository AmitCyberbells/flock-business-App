import 'dart:convert';
import 'package:flock/constants.dart';
import 'package:flock/offer_details.dart';
import 'package:flock/venue.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> offersList = [];

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> fetchOffers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String? token = await getToken();
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = Uri.parse('https://api.getflock.io/api/vendor/offers');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            offersList = List.from(data['data']);
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'No offers found.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error ${response.statusCode}: Unable to fetch offers.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeOffer(int offerId) async {
    String? token = await getToken();
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = Uri.parse('https://api.getflock.io/api/vendor/offers/$offerId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          offersList.removeWhere((offer) => offer['id'] == offerId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove offer. Code: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppConstants.customAppBar(context: context, title: 'Offers'),
      body: isLoading
          ? Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.14),
                ),
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
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : offersList.isEmpty
                  ? const Center(child: Text('No offers found.'))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount: offersList.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) {
                          final offer = offersList[index];
                          final int offerId = offer['id'];
                          final String discount = offer['name']?.toString() ?? '0';
                          final String desc = (offer['description']?.toString().trim().isNotEmpty ?? false)
                              ? offer['description'].toString()
                              : 'No Description';
                          final String venueName = offer['venue']?['name']?.toString() ?? 'No Venue';
                          final String imageUrl = (offer['images'] is List &&
                                  offer['images'].isNotEmpty &&
                                  offer['images'][0]['medium_image'] != null)
                              ? offer['images'][0]['medium_image']
                              : '';
                          bool isExpired = offer['expire_at'] != null;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Offer Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  height: 100,
                                                  width: double.infinity,
                                                  color: Colors.grey.shade200,
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/Bird_Full_Eye_Blinking.gif',
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 100,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              height: 100,
                                              width: double.infinity,
                                              color: Colors.grey.shade200,
                                              child: const FittedBox(
                                                fit: BoxFit.contain,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                    ),
                                    // Offer details
                                    Padding

(
                                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            discount,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: double.infinity,
                                            child: Text(
                                              desc,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/orange_hotel.png',
                                                width: 14,
                                                height: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  venueName,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Spacer to push buttons to the bottom
                                    const Spacer(),
                                    // Bottom button row
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Delete button
                                          Container(
                                            decoration: const BoxDecoration(),
                                            child: SizedBox(
                                              height: 30,
                                              width: 66,
                                              child: cardWrapper(
                                                borderRadius: 5,
                                                elevation: 2,
                                                color: Colors.red,
                                                child: InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: const Text('Confirm Deletion'),
                                                          content: const Text(
                                                              'Are you sure you want to delete this offer?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: const Text(
                                                                'CANCEL',
                                                                style: TextStyle(color: Colors.grey),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                removeOffer(offerId);
                                                              },
                                                              child: const Text(
                                                                'OK',
                                                                style: TextStyle(
                                                                  color: Color.fromRGBO(255, 130, 16, 1.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.delete,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // See Details button
                                          Container(
                                            height: 30,
                                            width: 66,
                                            child: cardWrapper(
                                              borderRadius: 5,
                                              elevation: 2,
                                              color: const Color.fromRGBO(255, 130, 16, 1),
                                              child: InkWell(
                                                onTap: () {
                                                  print('Details button tapped for offer ID: $offerId');
                                                  try {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => OfferDetails(allDetail: offer),
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    print('Navigation error: $e');
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to navigate to details: $e')),
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Image.asset(
                                                        'assets/view.png',
                                                        height: 14,
                                                        width: 12,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Text(
                                                        'Details',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.white,
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
                                    ),
                                  ],
                                ),
                                // Expired text in top left corner
                                if (isExpired)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      color: Colors.red.withOpacity(0.8),
                                      child: const Text(
                                        'Expired',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
    );
  }
}

// Placeholder for cardWrapper
Widget cardWrapper({
  required double borderRadius,
  required double elevation,
  required Color color,
  required Widget child,
}) {
  return Material(
    elevation: elevation,
    borderRadius: BorderRadius.circular(borderRadius),
    color: color,
    child: child,
  );
}