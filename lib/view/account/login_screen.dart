// company_login_view.dart (Modified LoginScreen)

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/routes/routes_name.dart';
import '../../core/services/navigation_service.dart';
import '../../view_models/AccountVM/company_login_view_model.dart';
import '../../view_models/DashboardVM/bloc/dashboard_bloc.dart';
import '../../view_models/DashboardVM/bloc/dashboard_event.dart';
import 'widgets/pill_input_field.dart';
import 'widgets/terms_privacy_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  final List<Map<String, String>> sliders = const [
    {'image': 'assets/images/img_3.png', 'text': 'Welcome to Medrpha Delivery'},
    {'image': 'assets/images/img_1.png', 'text': 'Deliver on time'},
    {'image': 'assets/images/img_2.png', 'text': 'Join Us for deliver'},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _autoScroll());

    final notificationService = NotificationService();

    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // handle if needed
    });

    // Background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Your UI is driven by bloc's state.currentIndex, so drive the bloc:
    context.read<DashboardBloc>().add( DashboardTabChanged(1));
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _pageController.hasClients) {
        _currentPage = (_currentPage + 1) % sliders.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _skipToHome(BuildContext context) {
    // Replace with your actual route name
    Navigator.pushReplacementNamed(context, RoutesName.dashboardScreen);
  }

  void _onLoginButtonPressed(BuildContext context) async{
    String? token = await FirebaseMessaging.instance.getToken();
    if (_formKey.currentState!.validate()) {
      context.read<CompanyLoginBloc>().add(
        CompanyLoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          deviceType: 'App',
          deviceToken: token ?? '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompanyLoginBloc(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: BlocListener<CompanyLoginBloc, CompanyLoginState>(
              listener: (context, state) {
                if (state is CompanyLoginSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login Success for ${state.user.userName}!')),
                  );
                  Navigator.pushReplacementNamed(context, RoutesName.dashboardScreen);
                } else if (state is CompanyLoginFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login Failed: ${state.error}')),
                  );
                }
              },
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 220,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: sliders.length,
                                  onPageChanged: (index) {
                                    setState(() => _currentPage = index);
                                  },
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Image.asset(
                                          sliders[index]['image']!,
                                          fit: BoxFit.contain,
                                          width: 200,
                                          height: 150,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          sliders[index]['text']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  sliders.length,
                                      (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == index ? 12 : 8,
                                    height: _currentPage == index ? 12 : 8,
                                    decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 30,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "Company Login",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        PillInputField(
                                          label: "Email Address",
                                          icon: Icons.email_outlined,
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return "Please enter your email address";
                                            }
                                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                              return "Enter a valid email address";
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 15),

                                        PillInputField(
                                          label: "Password",
                                          icon: Icons.lock_outline,
                                          controller: _passwordController,
                                          isPassword: true,
                                          keyboardType: TextInputType.visiblePassword,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Please enter your password";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        BlocBuilder<CompanyLoginBloc, CompanyLoginState>(
                                          builder: (context, state) {
                                            final bool isLoading = state is CompanyLoginLoading;
                                            return ElevatedButton(
                                              onPressed: isLoading ? null : () => _onLoginButtonPressed(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blueAccent,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: isLoading
                                                  ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.0,
                                                ),
                                              )
                                                  : Text(
                                                'LOGIN',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 20),
                                        const Spacer(),

                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(2, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/logo/google2.png',
                                                    height: 24,
                                                    width: 24,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.search, size: 24, color: Colors.red),
                                                  ),
                                                ),
                                                const SizedBox(width: 25),
                                                // Facebook Logo Placeholder
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(2, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/logo/facebook2.png',
                                                    height: 24,
                                                    width: 24,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.facebook, size: 24, color: Colors.blue),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const TermsPrivacyText(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 24,
                      child: InkWell(
                        onTap: () => _skipToHome(context),
                        child: Text(
                          'Skip >',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}