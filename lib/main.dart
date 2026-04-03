import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

// THEME COLORS FROM YOUR FLEET TRACKER DESIGN
const Color primaryOrange = Color(0xFFFF6D4D);
const Color backgroundBlack = Color(0xFF121212);
const Color surfaceGrey = Color(0xFF1E1E1E);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FleetTrackerApp());
}

class FleetTrackerApp extends StatelessWidget {
  const FleetTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundBlack,
        primaryColor: primaryOrange,
        appBarTheme:
            const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
        cardTheme: CardThemeData(
            color: surfaceGrey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        colorScheme: ColorScheme.dark(
            primary: primaryOrange,
            secondary: primaryOrange,
            surface: surfaceGrey),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (c) => const MainNavigationShell()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Login Error: Ensure Email/Password is enabled in Firebase Console")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.black,
                backgroundBlack,
                primaryOrange.withOpacity(0.15)
              ]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 70, color: primaryOrange),
            const SizedBox(height: 20),
            const Text("Fleet Tracker",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
            const Text("Where technology meets the road",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            _buildInput(_emailController, "Email", Icons.email),
            const SizedBox(height: 15),
            _buildInput(_passController, "Password", Icons.lock, obscure: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text("SIGN IN",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            Center(
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const SignupScreen())),
                    child: const Text("Create Account",
                        style: TextStyle(color: primaryOrange)))),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            hintText: hint,
            prefixIcon: Icon(icon, color: primaryOrange),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)));
  }
}

// --- 2. SIGNUP SCREEN ---
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleSignup() async {
    try {
      UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
      // Save full_name in the 'users' node
      await FirebaseDatabase.instance.ref('users/${user.user!.uid}').set({
        "full_name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signup Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name")),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _handleSignup, child: const Text("REGISTER")),
          ],
        ),
      ),
    );
  }
}

// --- 3. MAIN NAVIGATION ---
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});
  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _idx = 0;
  final _screens = [
    const OwnerDashboard(),
    const LocationPage(),
    const LogsPage(),
    const SettingsPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        backgroundColor: Colors.black,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "GPS"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Logs"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

// --- 4. HOME PAGE (DASHBOARD) ---
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String _userName = "User";
  String _status = "SAFE";
  String _lastImg = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _listenToFirebase();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snap = await FirebaseDatabase.instance
          .ref('users/${user.uid}/full_name')
          .get();
      if (snap.exists) setState(() => _userName = snap.value.toString());
    }
  }

  void _listenToFirebase() {
    FirebaseDatabase.instance.ref('driver_status').onValue.listen((e) {
      if (e.snapshot.value != null) {
        final d = Map<dynamic, dynamic>.from(e.snapshot.value as Map);
        setState(() {
          _status = d['status'] ?? "SAFE";
          _lastImg = d['last_alert_image'] ?? "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome! $_userName")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Driver Updates",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Card(
                child: ListTile(
                    leading: Icon(Icons.warning,
                        color:
                            _status == "DANGER" ? Colors.red : primaryOrange),
                    title: Text("Status: $_status"))),
            const SizedBox(height: 20),
            const Text("Mileage Tracker",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
                height: 100,
                decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                    child: Text("530 KM",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 20),
            if (_lastImg.isNotEmpty)
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                      imageUrl: _lastImg,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover)),
          ],
        ),
      ),
    );
  }
}

// --- 5. LOGS PAGE (CLICKABLE) ---
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});
  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<Map<dynamic, dynamic>> _logs = [];
  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref('alerts_history').onValue.listen((e) {
      if (e.snapshot.value != null) {
        final d = e.snapshot.value as Map;
        List<Map<dynamic, dynamic>> tmp = [];
        d.forEach((k, v) => tmp.add(Map<dynamic, dynamic>.from(v)));
        tmp.sort((a, b) =>
            b['timestamp'].toString().compareTo(a['timestamp'].toString()));
        setState(() => _logs = tmp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alert Logs")),
      body: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (c, i) => Card(
            child: ListTile(
          onTap: () => launchUrl(Uri.parse(_logs[i]['image_url'] ?? "")),
          title: Text("Drowsiness Alert - EAR: ${_logs[i]['ear']}"),
          subtitle: Text("${_logs[i]['timestamp']}"),
          trailing: const Icon(Icons.remove_red_eye, color: primaryOrange),
        )),
      ),
    );
  }
}

// --- 6. LOCATION PAGE (MIT ADT) ---
class LocationPage extends StatelessWidget {
  const LocationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live GPS")),
      body: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.location_on, size: 80, color: primaryOrange),
        Text("MIT ADT School of Computing",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Loni Kalbhor, Pune"),
      ])),
    );
  }
}

// --- 7. SETTINGS PAGE ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
            onPressed: () => FirebaseAuth.instance.signOut().then((_) =>
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (c) => const LoginScreen()))),
            child: const Text("LOGOUT")));
  }
}
