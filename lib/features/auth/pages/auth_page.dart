import 'package:event/features/home/page/home.dart';
import 'package:event/features/walkthrough/pages/intro.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  User? user;
  Future<void> getAuth()async{
    
    setState(() {
      user=supabase.auth.currentUser;
    });
    supabase.auth.onAuthStateChange.listen((event){
      setState(() {
        user=event.session?.user;
      });
    },) ;
  }
  @override
  Widget build(BuildContext context) {
    return user==null? Intro():Home(); 
  }
}