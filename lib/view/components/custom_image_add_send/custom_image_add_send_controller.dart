import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CustomImageAddSendController extends GetxController {
  RxList<XFile> images = <XFile>[].obs; 
  
   // Rx List for image files
 

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      images.add(pickedFile);   
      images.refresh();
      refresh(); 
      
      debugPrint('============Image Length=================>> ${images.length}');// Add image to the Rx List
    }
  } 


 //final TextEditingController messageController = TextEditingController();
  void removeImage(int index) {
    images.removeAt(index); // Remove image from the Rx List
  }

  // void sendMessage() {
  //   // Handle send message logic
  //   if (kDebugMode) {
  //     print("Images: ${images.length}");
  //   }
  //   messageController.clear();
  //   images.clear(); // Clear images after sending
  // } 

    
                 
}
