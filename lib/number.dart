import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video/otp.dart';
import 'package:video/widget/textBox.dart';

class NumberReq extends StatefulWidget {
  const NumberReq({super.key});

  @override
  State<NumberReq> createState() => _NumberReqState();
}

class _NumberReqState extends State<NumberReq> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCountryCode = '+91';
  final List<String> _countryCodes = [
    '+1',    // USA
    '+91',   // India
    '+44',   // UK
    '+61',   // Australia
    '+81',   // Japan
    '+49',   // Germany
    '+33',   // France
    '+39',   // Italy
    '+86',   // China
    '+7',    // Russia
    '+55',   // Brazil
    '+27',   // South Africa
    '+34',   // Spain
    '+62',   // Indonesia
    '+52',   // Mexico
    '+31',   // Netherlands
    '+47',   // Norway
    '+46',   // Sweden
    '+41',   // Switzerland
    '+90',   // Turkey
    '+971',  // UAE
    '+60',   // Malaysia
    '+65',   // Singapore
  ];
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 11,bottom:20),
              child: SizedBox(
                height: 110,
                width: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset("assets/image/logo.jpg"),

                ),
              ),
            ),
            const SizedBox(height: 30,),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountryCode = newValue!;
                      });
                    },
                    items: _countryCodes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10,),
                SizedBox(
                  width: 250,
                    child: TextBoxCustom(
                      inputType: TextInputType.number,
                      controller: _controller,
                      hint: "Enter Phone Number",
                    )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:19),
              child: ElevatedButton(onPressed: ()async{
                final String number = "$_selectedCountryCode${_controller.text}";
                await FirebaseAuth.instance.verifyPhoneNumber(
                    verificationCompleted: (PhoneAuthCredential credential){},
                    verificationFailed: (FirebaseAuthException ex){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to verify phone number: ${ex.message}')),
                      );
                    },
                    codeSent: (String verificationId, int? resendToken){
                      Navigator.pushReplacement(context,MaterialPageRoute(
                          builder: (context)=> OtpVerify(
                            verificationId: verificationId,
                            number: number,
                            resendToken: resendToken,

                            ) ));
                    },
                    codeAutoRetrievalTimeout: (String verificationID){},
                phoneNumber: number);
              }, child: const Text("Next")),
            )
          ],
        ),
      ),
    );
  }
}
