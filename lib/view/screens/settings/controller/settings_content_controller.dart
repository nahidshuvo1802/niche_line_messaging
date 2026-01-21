import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/settings/model/settings_content_model.dart';

enum ContentType { aboutUs, privacyPolicy, terms }

class SettingsContentController extends GetxController {
  var isLoading = true.obs;
  var content = "".obs;

  Future<void> fetchContent(ContentType type) async {
    isLoading.value = true;
    String url = "";
    switch (type) {
      case ContentType.aboutUs:
        url = ApiUrl.aboutUs;
        break;
      case ContentType.privacyPolicy:
        url = ApiUrl.privacyPolicy;
        break;
      case ContentType.terms:
        url = ApiUrl.termsAndConditions;
        break;
    }

    try {
      var response = await ApiClient.getData(url);
      if (response.statusCode == 200) {
        var model = SettingsContentModel.fromJson(response.body);
        if (model.success == true) {
          content.value = model.data?.content ?? "No content available.";
        } else {
          _setFallbackContent(type);
        }
      } else {
        // Fallback content if API fails
        _setFallbackContent(type);
      }
    } catch (e) {
      debugPrint("Error fetching content: $e");
      // Fallback content on error
      _setFallbackContent(type);
    } finally {
      isLoading.value = false;
    }
  }

  void _setFallbackContent(ContentType type) {
    switch (type) {
      case ContentType.aboutUs:
        content.value = """
        <h1>About NichLine</h1>
        <p>Welcome to <b>NichLine</b>, a messaging app designed with your privacy and security as our top priority. Our mission is to provide a seamless, secure, and user-friendly communication platform that empowers you to connect with friends, family, and colleagues without compromising your personal data.</p>
        <h2>Our Mission</h2>
        <p>To redefine digital communication by integrating state-of-the-art encryption with an intuitive user experience. We believe that privacy is a fundamental right, not a luxury.</p>
        <h2>Why Choose Us?</h2>
        <ul>
          <li><b>End-to-End Encryption:</b> Your messages, calls, and media are encrypted, ensuring that only you and the recipient can access them.</li>
          <li><b>Secure Folder:</b> A dedicated encrypted space for your most private files.</li>
          <li><b>User-Centric Design:</b> A clean, modern interface that is easy to navigate.</li>
        </ul>
        <br>
        <p>Thank you for choosing NichLine. We are committed to continuously improving our services to meet your needs.</p>
        """;
        break;
      case ContentType.privacyPolicy:
        content.value = """
        <h1>Privacy Policy</h1>
        <p><b>Last Updated: Jan 2026</b></p>
        <p>At NichLine, we take your privacy seriously. This Privacy Policy describes how we collect, use, and protect your personal information.</p>
        <h2>1. Information We Collect</h2>
        <p><b>Account Information:</b> When you register, we collect your phone number and profile name to create your account.</p>
        <p><b>Usage Data:</b> We may collect anonymous usage statistics to improve app performance.</p>
        <h2>2. How We Use Your Information</h2>
        <p>We use your information to:</p>
        <ul>
          <li>Facilitate communication between you and other users.</li>
          <li>Provide customer support.</li>
          <li>Improve app functionality and security.</li>
        </ul>
        <h2>3. Data Security</h2>
        <p>We employ industry-standard encryption protocols to protect your data both in transit and at rest. Your messages are end-to-end encrypted.</p>
        <h2>4. Contact Us</h2>
        <p>If you have any questions about this Privacy Policy, please contact us at support@nichline.com.</p>
        """;
        break;
      case ContentType.terms:
        content.value = """
        <h1>Terms & Conditions</h1>
        <p><b>Effective Date: Jan 2026</b></p>
        <p>Please read these Terms and Conditions ("Terms") carefully before using the NichLine application operated by us.</p>
        <h2>1. Acceptance of Terms</h2>
        <p>By accessing or using the Service, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.</p>
        <h2>2. User Content</h2>
        <p>You are responsible for the content you send or share via NichLine. You agree not to use the service for any illegal or unauthorized purpose.</p>
        <h2>3. Intellectual Property</h2>
        <p>The Service and its original content, features, and functionality are and will remain the exclusive property of NichLine and its licensors.</p>
        <h2>4. Termination</h2>
        <p>We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.</p>
        <h2>5. Changes</h2>
        <p>We reserve the right, at our sole discretion, to modify or replace these Terms at any time.</p>
        """;
        break;
    }
  }
}
