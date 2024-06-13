import 'dart:ffi';

import 'package:flutter/material.dart';

class TextBoxCustom extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? inputType;
  final int? maxLine;
  final String? errorText;
  const TextBoxCustom({
    super.key,
    required this.controller,
    required this.hint,
    this.inputType,
    this.maxLine,
    this.errorText
  });


  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: inputType,
      controller: controller,
      maxLines: maxLine,
      autofocus: true,
      decoration: InputDecoration(
        errorText: errorText ,
        contentPadding: const EdgeInsets.all(15),
        hintText: hint,
        border:OutlineInputBorder(
          borderRadius:const BorderRadius.all(Radius.circular(14)),
          borderSide:BorderSide(
            color:Theme.of(context).colorScheme.secondary,
          ),
        ),
        focusedBorder:OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary )
        )
      ),

    );
  }
}
