import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // ✅ I cleaned your URL here.
  // NOTE: If your repo is Private, this link will fail (404).
  // Ideally, host version.json on a GitHub Gist (gist.github.com) which is public.
  static const String versionFileUrl =
      'https://raw.githubusercontent.com/aariznazirwani/VitalRise/main/version.json';

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      // 1. Get Current App Version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Version currentVersion = Version.parse(packageInfo.version);
      print("Current App Version: $currentVersion");

      // 2. Get Online Version Info
      final response = await http.get(Uri.parse(versionFileUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Version latestVersion = Version.parse(data['version']);
        bool isMandatory = data['mandatory'];
        String url = data['updateUrl'];

        print("Online Version: $latestVersion");

        // 3. Compare
        if (latestVersion > currentVersion) {
          if (!context.mounted) return;
          _showUpdateDialog(
            context,
            isMandatory,
            url,
            latestVersion.toString(),
          );
        } else {
          print("App is up to date.");
        }
      } else {
        print("Failed to get update info. Status Code: ${response.statusCode}");
        print("Check if repo is Private? If yes, use a Public Gist.");
      }
    } catch (e) {
      print("Error checking for updates: $e");
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    bool mandatory,
    String url,
    String newVersion,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !mandatory,
      builder: (context) {
        return PopScope(
          canPop: !mandatory,
          child: AlertDialog(
            title: const Text("Update Available"),
            content: Text(
              mandatory
                  ? "A critical update ($newVersion) is required."
                  : "A new version ($newVersion) is available. Would you like to update?",
            ),
            actions: [
              if (!mandatory)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Later"),
                ),
              ElevatedButton(
                onPressed: () {
                  _launchURL(url);
                  if (!mandatory) Navigator.pop(context);
                },
                child: const Text("Update Now"),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }
}
