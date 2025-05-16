import 'package:flutter/material.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) onImagePick;

  const UserImagePicker({
    Key? key,
    required this.onImagePick,
  }) : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
        )
        TextButton(
          onPressed: () {},
         child: Row(
          children: [
            Icon(
              
              Icons.image,
              color: Theme.of(context).primaryColor,
            
            
            ),

          ],
         ),
        ),
      ],
    );
  }
}