import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maydrama/ui/core.dart';
import 'package:maydrama/utils/server.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  HttpOverrides.global = HttpBypass();
  runApp(const App());
}

// bypass ssl cert
class HttpBypass extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context) // not safe
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  static const darkColor = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MayDrama",
      theme: ThemeData(
        useMaterial3: true,
        brightness: .light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: .dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: .dark
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: .dark,
        scaffoldBackgroundColor: darkColor,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColor,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: .light,
            systemNavigationBarColor: darkColor,
            systemNavigationBarIconBrightness: .light
          ),
        ),
      ),
      themeMode: .system,
      debugShowCheckedModeBanner: false,
      home: const GridListDrama(),
    );
  }
}

class GridListDrama extends StatefulWidget {
  const GridListDrama({super.key});

  @override
  State<GridListDrama> createState() => GridListDramaState();
}

class GridListDramaState extends State<GridListDrama> {
  String accessKey = "";
  final TextEditingController accessKeyController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    loadAccessKey();
  }

  Future<void> loadAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => accessKeyController.text = prefs.getString("access_key").toString());
  }

  Future<void> saveAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_key", accessKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MayDrama"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Masukan Access Key"),
                    content: TextField(
                      controller: accessKeyController,
                      decoration: InputDecoration(
                        labelText: "Access Key",
                        border: OutlineInputBorder(
                          borderRadius: .circular(15)
                        )
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          accessKeyController.clear();
                          loadAccessKey();
                          Navigator.pop(context);
                        },
                        child: const Text("Batal", style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          accessKey = accessKeyController.text;
                          setState(() {
                            if (accessKey.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Input tidak boleh kosong"))
                              );
                            } else {
                              saveAccessKey();
                              loadAccessKey();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Access Key berhasil disimpan"))
                              );
                            }
                          });
                          accessKeyController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text("Simpan"),
                      )
                    ],
                  );
                }
              );
            },
            icon: const Icon(Icons.key),
          )
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.9
        ),
        padding: const EdgeInsets.all(15),
        itemCount: ServerManager().appList.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () => ServerManager().appList[index].isActive ? Navigator.push(context, MaterialPageRoute(builder: (ctx) => MayDrama(index: index)))
              : showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text("${ServerManager().appList[index].name} Comming Soon"),
                    ),
                  ),
                ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.primaries[index % Colors.primaries.length],
                  borderRadius: .circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    Icon(
                      Icons.star,
                      size: 40,
                      color: ServerManager().appList[index].isActive ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ServerManager().appList[index].name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: .bold
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