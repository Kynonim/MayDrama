import 'package:flutter/material.dart';
import 'package:maydrama/utils/platform.dart';
import 'package:maydrama/utils/service.dart';

class UI {
  static void go(BuildContext context, Widget appWidget) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => appWidget));
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}

class MaySettings extends StatefulWidget {
  const MaySettings({super.key});

  @override
  State<MaySettings> createState() => MaySettingsState();
}

class MaySettingsState extends State<MaySettings> {
  String token = "null";
  bool isTyping = false, isSaved = false;

  final inputController = TextEditingController();
  final apiService = ApiService();

  Future<void> loadToken() async {
    final key = await apiService.loadAccessToken();
    inputController.text = key;
  }

  Future<void> saveToken() async {
    isSaved = await apiService.saveAccessToken(token);
  }

  @override
  void initState() { 
    super.initState();
    loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        padding: const .all(16),
        child: Column(
          children: [
            TextField(
              controller: inputController,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: const .all(8),
                hintText: "A23GHJKLDKJD...",
                labelText: "Access Key",
                border: OutlineInputBorder(
                  borderRadius: .circular(16),
                ),
                prefixIcon: IconButton(
                  onPressed: () {
                    if (isTyping) {
                      inputController.clear();
                    }
                  },
                  icon: Icon(isTyping ? Icons.close : Icons.key_outlined),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    saveToken();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${isSaved ? "Berhasil" : "Gagal"} Menyimpan access key")),
                    );
                  },
                  icon: Icon(Icons.save_rounded),
                )
              ),
              onChanged: (value) {
                token = value;
                setState(() => isTyping = true);
              },
            ),
            const SizedBox(height: 10),
            Text(
              "* Masukan Access Key supaya bisa mengakses semua fitur aplikasi ini",
              style: TextStyle(fontStyle: .italic),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    await AppPlatforms.updateAppPlatform(token);
                  },
                  label: Text("Update App Platform"),
                  icon: Icon(Icons.update_outlined),
                ),
                Icon(Icons.check),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Contributors", style: TextStyle(fontWeight: .bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: contributors.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(contributors[index].name, style: TextStyle(fontWeight: .w400)),
                    leading: CircleAvatar(
                      child: ClipOval(
                        child: Image.network(contributors[index].logo)
                      ),
                    ),
                    subtitle: Text(contributors[index].github),
                  );
                },
              ),
            )
          ],
        ),
      )
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}

class Contributors {
  final String id, name, github, logo;
  Contributors({
    required this.id,
    required this.name,
    required this.github,
    required this.logo
  });
}

List<Contributors> contributors = [
  Contributors(
    id: "kynonim",
    name: "Riky Ripaldo",
    github: "https://github.com/Kynonim",
    logo: "https://avatars.githubusercontent.com/u/64513539?v=4",
  ),
];