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
  @override
  void dispose() {
    // TODO: implement dispose
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
            SizedBox(
              width: 350,
                child: TextBoxCustom(
                  inputType: TextInputType.number,
                  controller: _controller,
                  hint: "Enter Phone Number",
                )),
            Padding(
              padding: const EdgeInsets.only(top:19),
              child: ElevatedButton(onPressed: ()async{
                final String number = "+91${_controller.text}";
                await FirebaseAuth.instance.verifyPhoneNumber(
                    verificationCompleted: (PhoneAuthCredential credential){},
                    verificationFailed: (FirebaseAuthException ex){},
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
