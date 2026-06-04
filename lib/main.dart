import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EnergyClickerApp());
}

class EnergyClickerApp extends StatelessWidget {
  const EnergyClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF080B12),
      ),
      home: const ClickerPage(),
    );
  }
}

class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage>
    with TickerProviderStateMixin {
  final GlobalKey _gameAreaKey = GlobalKey();
  final math.Random _random = math.Random();

  double coins = 0;
  double clickPower = 1;
  double autoPower = 0;
  double globalMultiplier = 1;
  double buttonScale = 1;

  User? currentUser;
  bool cloudBusy = false;
  bool autoCloudSave = true;
  bool silentCloudSaveRunning = false;

  final Set<String> adminEmails = {
    'thereallongname@gmail.com',
  };

  bool get isAdmin {
    final email = currentUser?.email?.toLowerCase();
    if (email == null) return false;
    return adminEmails.contains(email);
  }

  Timer? autoTimer;
  Timer? saveTimer;

  late final AnimationController _effectsController;

  final List<LightningBolt> lightnings = [];
  final List<FloatingTextEffect> floatingTexts = [];

  late Map<String, int> upgradeLevels;

  static final List<UpgradeDefinition> upgrades = [
    UpgradeDefinition(
      id: 'click_1',
      name: 'Doigt énergétique',
      description: '+1 par clic',
      baseCost: 25,
      growth: 1.45,
      clickBonus: 1,
      icon: Icons.touch_app,
    ),
    UpgradeDefinition(
      id: 'click_2',
      name: 'Souris renforcée',
      description: '+5 par clic',
      baseCost: 200,
      growth: 1.55,
      clickBonus: 5,
      icon: Icons.mouse,
    ),
    UpgradeDefinition(
      id: 'click_3',
      name: 'Gant conducteur',
      description: '+25 par clic',
      baseCost: 2000,
      growth: 1.60,
      clickBonus: 25,
      icon: Icons.pan_tool,
    ),
    UpgradeDefinition(
      id: 'click_4',
      name: 'Marteau de foudre',
      description: '+150 par clic',
      baseCost: 25000,
      growth: 1.65,
      clickBonus: 150,
      icon: Icons.flash_on,
    ),
    UpgradeDefinition(
      id: 'click_5',
      name: 'Main divine',
      description: '+1000 par clic',
      baseCost: 500000,
      growth: 1.70,
      clickBonus: 1000,
      icon: Icons.back_hand,
    ),
    UpgradeDefinition(
      id: 'click_6',
      name: 'Clic nucléaire',
      description: '+10000 par clic',
      baseCost: 50000000,
      growth: 1.80,
      clickBonus: 10000,
      icon: Icons.radio_button_checked,
    ),
    UpgradeDefinition(
      id: 'auto_1',
      name: 'Petite batterie',
      description: '+1 par seconde',
      baseCost: 100,
      growth: 1.50,
      autoBonus: 1,
      icon: Icons.battery_charging_full,
    ),
    UpgradeDefinition(
      id: 'auto_2',
      name: 'Mini générateur',
      description: '+8 par seconde',
      baseCost: 800,
      growth: 1.55,
      autoBonus: 8,
      icon: Icons.electric_bolt,
    ),
    UpgradeDefinition(
      id: 'auto_3',
      name: 'Paratonnerre',
      description: '+50 par seconde',
      baseCost: 8000,
      growth: 1.60,
      autoBonus: 50,
      icon: Icons.thunderstorm,
    ),
    UpgradeDefinition(
      id: 'auto_4',
      name: 'Tour Tesla',
      description: '+350 par seconde',
      baseCost: 90000,
      growth: 1.65,
      autoBonus: 350,
      icon: Icons.cell_tower,
    ),
    UpgradeDefinition(
      id: 'auto_5',
      name: 'Centrale électrique',
      description: '+2500 par seconde',
      baseCost: 1200000,
      growth: 1.70,
      autoBonus: 2500,
      icon: Icons.factory,
    ),
    UpgradeDefinition(
      id: 'auto_6',
      name: 'Réacteur plasma',
      description: '+25000 par seconde',
      baseCost: 75000000,
      growth: 1.80,
      autoBonus: 25000,
      icon: Icons.blur_on,
    ),
    UpgradeDefinition(
      id: 'auto_7',
      name: 'Trou noir énergétique',
      description: '+250000 par seconde',
      baseCost: 5000000000,
      growth: 1.90,
      autoBonus: 250000,
      icon: Icons.circle,
    ),
    UpgradeDefinition(
      id: 'multi_1',
      name: 'Overclock',
      description: 'Tous les gains x1.15',
      baseCost: 10000,
      growth: 2.40,
      multiplierFactor: 1.15,
      icon: Icons.speed,
    ),
    UpgradeDefinition(
      id: 'multi_2',
      name: 'Boost quantique',
      description: 'Tous les gains x1.25',
      baseCost: 250000,
      growth: 2.80,
      multiplierFactor: 1.25,
      icon: Icons.auto_awesome,
    ),
    UpgradeDefinition(
      id: 'multi_3',
      name: 'Tempête infinie',
      description: 'Tous les gains x1.50',
      baseCost: 1000000000,
      growth: 3.20,
      multiplierFactor: 1.50,
      icon: Icons.storm,
    ),
  ];

  double get realClickPower => clickPower * globalMultiplier;
  double get realAutoPower => autoPower * globalMultiplier;

  @override
  void initState() {
    super.initState();

    upgradeLevels = {
      for (final upgrade in upgrades) upgrade.id: 0,
    };

    _effectsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(updateEffects);

    loadGame();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;

      setState(() {
        currentUser = user;
      });

      if (user != null) {
        await loadCloud(showMessage: false);
      }
    });

    autoTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (realAutoPower > 0) {
        setState(() {
          coins += realAutoPower / 4;
        });
      }
    });

    saveTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      saveGame();
    });
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    saveTimer?.cancel();
    _effectsController.dispose();
    super.dispose();
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      coins = prefs.getDouble('coins') ?? 0;
      clickPower = prefs.getDouble('clickPower') ?? 1;
      autoPower = prefs.getDouble('autoPower') ?? 0;
      globalMultiplier = prefs.getDouble('globalMultiplier') ?? 1;
      autoCloudSave = prefs.getBool('autoCloudSave') ?? true;

      for (final upgrade in upgrades) {
        upgradeLevels[upgrade.id] = prefs.getInt('level_${upgrade.id}') ?? 0;
      }
    });
  }

  Future<void> saveGame({bool syncCloud = true}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('coins', coins);
    await prefs.setDouble('clickPower', clickPower);
    await prefs.setDouble('autoPower', autoPower);
    await prefs.setDouble('globalMultiplier', globalMultiplier);
    await prefs.setBool('autoCloudSave', autoCloudSave);

    for (final upgrade in upgrades) {
      await prefs.setInt(
        'level_${upgrade.id}',
        upgradeLevels[upgrade.id] ?? 0,
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    if (syncCloud &&
        autoCloudSave &&
        user != null &&
        !cloudBusy &&
        !silentCloudSaveRunning) {
      unawaited(saveCloudSilent());
    }
  }

  Map<String, dynamic> saveDataToMap() {
    return {
      'coins': coins,
      'clickPower': clickPower,
      'autoPower': autoPower,
      'globalMultiplier': globalMultiplier,
      'upgradeLevels': upgradeLevels,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> saveCloudSilent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    silentCloudSaveRunning = true;

    try {
      await FirebaseFirestore.instance
          .collection('saves')
          .doc(user.uid)
          .set(saveDataToMap(), SetOptions(merge: true));
    } catch (_) {
      // Sauvegarde silencieuse : on évite de spam les erreurs pendant le jeu.
    } finally {
      silentCloudSaveRunning = false;
    }
  }

  Future<void> openEmailLoginDialog() async {
    final emailController = TextEditingController(
      text: currentUser?.email ?? 'thereallongname@gmail.com',
    );
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connexion compte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await createAccountWithEmail(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: const Text('Créer le compte'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await signInWithEmail(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: const Text('Connexion'),
            ),
          ],
        );
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (cloudBusy) return;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou mot de passe vide')),
      );
      return;
    }

    setState(() {
      cloudBusy = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        currentUser = credential.user;
      });

      await loadCloud(showMessage: false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecté : ${credential.user?.email}')),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur connexion';

      if (e.code == 'user-not-found') {
        message = 'Compte introuvable. Crée le compte d’abord.';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect.';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email ou mot de passe incorrect.';
      } else {
        message = 'Erreur : ${e.code}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          cloudBusy = false;
        });
      }
    }
  }

  Future<void> createAccountWithEmail(String email, String password) async {
    if (cloudBusy) return;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou mot de passe vide')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit faire au moins 6 caractères'),
        ),
      );
      return;
    }

    setState(() {
      cloudBusy = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        currentUser = credential.user;
      });

      await saveCloud(showMessage: false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compte créé : ${credential.user?.email}')),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur création du compte';

      if (e.code == 'email-already-in-use') {
        message = 'Ce compte existe déjà. Clique sur Connexion.';
      } else if (e.code == 'weak-password') {
        message = 'Mot de passe trop faible.';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide.';
      } else {
        message = 'Erreur : ${e.code}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          cloudBusy = false;
        });
      }
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();

      setState(() {
        currentUser = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnecté')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur déconnexion : $e')),
      );
    }
  }

  Future<void> saveCloud({bool showMessage = true}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connecte-toi avant de sauvegarder'),
        ),
      );
      return;
    }

    if (cloudBusy) return;

    setState(() {
      cloudBusy = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('saves')
          .doc(user.uid)
          .set(saveDataToMap(), SetOptions(merge: true));

      if (!mounted || !showMessage) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde cloud envoyée')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur sauvegarde cloud : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          cloudBusy = false;
        });
      }
    }
  }

  Future<void> loadCloud({bool showMessage = true}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connecte-toi avant de charger le cloud'),
        ),
      );
      return;
    }

    if (cloudBusy) return;

    setState(() {
      cloudBusy = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('saves')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        await FirebaseFirestore.instance
            .collection('saves')
            .doc(user.uid)
            .set(saveDataToMap(), SetOptions(merge: true));

        if (!mounted || !showMessage) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nouvelle sauvegarde cloud créée')),
        );
        return;
      }

      final data = doc.data()!;

      setState(() {
        coins = ((data['coins'] ?? 0) as num).toDouble();
        clickPower = ((data['clickPower'] ?? 1) as num).toDouble();
        autoPower = ((data['autoPower'] ?? 0) as num).toDouble();
        globalMultiplier = ((data['globalMultiplier'] ?? 1) as num).toDouble();

        final levels = Map<String, dynamic>.from(data['upgradeLevels'] ?? {});

        for (final upgrade in upgrades) {
          upgradeLevels[upgrade.id] = (levels[upgrade.id] ?? 0) as int;
        }
      });

      await saveGame(syncCloud: false);

      if (!mounted || !showMessage) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde cloud chargée')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement cloud : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          cloudBusy = false;
        });
      }
    }
  }

  double upgradeCost(UpgradeDefinition upgrade) {
    final level = upgradeLevels[upgrade.id] ?? 0;
    return upgrade.baseCost * math.pow(upgrade.growth, level).toDouble();
  }

  void clickCoins(TapDownDetails details) {
    final box = _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(details.globalPosition);
    final areaSize = box.size;
    final gain = realClickPower;
    final tier = getCurrencyTier(coins);

    setState(() {
      coins += gain;

      createLightning(localPosition, areaSize, tier.color);
      createLightning(localPosition, areaSize, tier.color);

      floatingTexts.add(
        FloatingTextEffect(
          text: '+${formatNumber(gain)}',
          position: localPosition,
          color: tier.color,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });

    pulseButton();
    startEffectsTicker();
  }

  void pulseButton() {
    setState(() {
      buttonScale = 0.92;
    });

    Future.delayed(const Duration(milliseconds: 70), () {
      if (!mounted) return;
      setState(() {
        buttonScale = 1;
      });
    });
  }

  void createLightning(Offset end, Size size, Color color) {
    final start = Offset(_random.nextDouble() * size.width, -40);
    final points = <Offset>[];

    const segments = 8;

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;

      final randomOffset = i == 0 || i == segments
          ? 0.0
          : (_random.nextDouble() - 0.5) * 90;

      points.add(Offset(x + randomOffset, y));
    }

    lightnings.add(
      LightningBolt(
        points: points,
        color: color,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void startEffectsTicker() {
    if (!_effectsController.isAnimating) {
      _effectsController.repeat();
    }
  }

  void updateEffects() {
    final now = DateTime.now().millisecondsSinceEpoch;

    lightnings.removeWhere((bolt) => now - bolt.createdAt > bolt.durationMs);
    floatingTexts.removeWhere((text) => now - text.createdAt > text.durationMs);

    if (lightnings.isEmpty && floatingTexts.isEmpty) {
      _effectsController.stop();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void buyUpgrade(UpgradeDefinition upgrade) {
    final cost = upgradeCost(upgrade);

    if (coins < cost) return;

    setState(() {
      coins -= cost;
      upgradeLevels[upgrade.id] = (upgradeLevels[upgrade.id] ?? 0) + 1;

      clickPower += upgrade.clickBonus;
      autoPower += upgrade.autoBonus;

      if (upgrade.multiplierFactor > 1) {
        globalMultiplier *= upgrade.multiplierFactor;
      }
    });

    saveGame();
  }

 void openSettings() {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF10151F),
    builder: (context) {
      final email = currentUser?.email;

      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (email != null)
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(email),
                  subtitle: Text(isAdmin ? 'Compte admin' : 'Compte joueur'),
                ),

              if (email == null)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Connexion compte'),
                  subtitle: const Text('Synchroniser Windows + Android'),
                  onTap: () async {
                    Navigator.pop(context);
                    await openEmailLoginDialog();
                  },
                ),

              if (email != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: () async {
                    Navigator.pop(context);
                    await signOutGoogle();
                  },
                ),

              SwitchListTile(
                secondary: const Icon(Icons.cloud_sync),
                title: const Text('Sauvegarde cloud automatique'),
                subtitle: const Text('Synchronise la partie en ligne'),
                value: autoCloudSave,
                onChanged: (value) async {
                  setState(() {
                    autoCloudSave = value;
                  });
                  await saveGame(syncCloud: false);
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: const Text('Envoyer la sauvegarde cloud'),
                subtitle: const Text('Cet appareil vers Firebase'),
                onTap: () async {
                  Navigator.pop(context);
                  await saveCloud();
                },
              ),

              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Charger la sauvegarde cloud'),
                subtitle: const Text('Firebase vers cet appareil'),
                onTap: () async {
                  Navigator.pop(context);
                  await loadCloud();
                },
              ),

              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Sauvegarder en local'),
                subtitle: const Text('Sauvegarde sur cet appareil'),
                onTap: () async {
                  Navigator.pop(context);
                  await saveGame(syncCloud: false);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partie sauvegardée')),
                  );
                },
              ),

              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Mod menu admin'),
                  subtitle: const Text('Inf argent, set monnaie, boosts'),
                  onTap: () {
                    Navigator.pop(context);
                    openAdminMenu();
                  },
                ),

              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Réinitialiser la partie'),
                subtitle: const Text('Supprime ta progression locale'),
                onTap: () async {
                  Navigator.pop(context);
                  await resetGame();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void openAdminMenu() {
  final TextEditingController coinsController = TextEditingController(
    text: coins.toStringAsFixed(0),
  );

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF10151F),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 8,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Mod menu admin'),
                  subtitle: Text('Visible seulement pour les comptes admin'),
                ),

                TextField(
                  controller: coinsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Montant de monnaie',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                FilledButton(
                  onPressed: () async {
                    final value = double.tryParse(
                      coinsController.text.replaceAll(',', '.'),
                    );

                    if (value == null) return;

                    setState(() {
                      coins = value;
                    });

                    await saveGame();

                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Set monnaie'),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          setState(() {
                            coins += 1000000.0;
                          });
                          await saveGame();
                        },
                        child: const Text('+1M'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          setState(() {
                            coins += 1000000000.0;
                          });
                          await saveGame();
                        },
                        child: const Text('+1B'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          setState(() {
                            coins += 1000000000000.0;
                          });
                          await saveGame();
                        },
                        child: const Text('+1T'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                FilledButton.tonal(
                  onPressed: () async {
                    setState(() {
                      coins = 1e18;
                    });
                    await saveGame();
                  },
                  child: const Text('Argent infini'),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          setState(() {
                            clickPower *= 10;
                          });
                          await saveGame();
                        },
                        child: const Text('Clic x10'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          setState(() {
                            autoPower *= 10;
                          });
                          await saveGame();
                        },
                        child: const Text('Auto x10'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                FilledButton.tonal(
                  onPressed: () async {
                    setState(() {
                      globalMultiplier *= 10;
                    });
                    await saveGame();
                  },
                  child: const Text('Multiplicateur x10'),
                ),

                const SizedBox(height: 10),

                FilledButton.tonal(
                  onPressed: () async {
                    setState(() {
                      for (final upgrade in upgrades) {
                        upgradeLevels[upgrade.id] =
                            (upgradeLevels[upgrade.id] ?? 0) + 10;

                        clickPower += upgrade.clickBonus * 10;
                        autoPower += upgrade.autoBonus * 10;

                        if (upgrade.multiplierFactor > 1) {
                          for (int i = 0; i < 10; i++) {
                            globalMultiplier *= upgrade.multiplierFactor;
                          }
                        }
                      }
                    });

                    await saveGame();
                  },
                  child: const Text('Toutes les upgrades +10'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Future<void> resetGame() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Réinitialiser la partie ?'),
          content: const Text(
            'Tu vas perdre toute ta progression locale. Le cloud peut rester si tu ne l’écrases pas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      coins = 0;
      clickPower = 1;
      autoPower = 0;
      globalMultiplier = 1;
      autoCloudSave = false;

      upgradeLevels = {
        for (final upgrade in upgrades) upgrade.id: 0,
      };

      lightnings.clear();
      floatingTexts.clear();
    });

    await saveGame(syncCloud: false);
  }

  String formatNumber(double value) {
    const units = [
      '',
      'K',
      'M',
      'B',
      'T',
      'Qa',
      'Qi',
      'Sx',
      'Sp',
      'Oc',
      'No',
      'Dc',
    ];

    double number = value.abs();
    int unitIndex = 0;

    while (number >= 1000 && unitIndex < units.length - 1) {
      number /= 1000;
      unitIndex++;
    }

    String result;

    if (unitIndex == 0) {
      if (number % 1 == 0) {
        result = number.toStringAsFixed(0);
      } else {
        result = number.toStringAsFixed(1);
      }
    } else if (number >= 100) {
      result = '${number.toStringAsFixed(0)}${units[unitIndex]}';
    } else if (number >= 10) {
      result = '${number.toStringAsFixed(1)}${units[unitIndex]}';
    } else {
      result = '${number.toStringAsFixed(2)}${units[unitIndex]}';
    }

    if (value < 0) {
      return '-$result';
    }

    return result;
  }

  CurrencyTier getCurrencyTier(double value) {
    if (value < 1000000) {
      return const CurrencyTier(color: Colors.white);
    }

    if (value < 1000000000) {
      return const CurrencyTier(color: Colors.lightBlueAccent);
    }

    if (value < 1000000000000) {
      return const CurrencyTier(color: Colors.pinkAccent);
    }

    if (value < 1000000000000000) {
      return const CurrencyTier(color: Colors.purpleAccent);
    }

    if (value < 1000000000000000000) {
      return const CurrencyTier(color: Colors.redAccent);
    }

    return const CurrencyTier(color: Colors.amberAccent);
  }

  Widget buildFloatingTexts() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return Stack(
      children: floatingTexts.map((effect) {
        final age = now - effect.createdAt;
        final progress = (age / effect.durationMs).clamp(0.0, 1.0).toDouble();
        final opacity = (1 - progress).clamp(0.0, 1.0).toDouble();

        return Positioned(
          left: effect.position.dx - 45,
          top: effect.position.dy - 40 - progress * 80,
          child: Opacity(
            opacity: opacity,
            child: Text(
              effect.text,
              style: TextStyle(
                color: effect.color,
                fontSize: 18 + 8 * (1 - progress),
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: effect.color.withOpacity(0.8),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = getCurrencyTier(coins);

    return Scaffold(
  extendBody: true,
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  floatingActionButton: SafeArea(
    child: FloatingActionButton.large(
      heroTag: 'settings_button',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bouton options cliqué')),
        );
        openSettings();
      },
      backgroundColor: Colors.black.withOpacity(0.75),
      child: const Icon(
        Icons.settings,
        size: 38,
        color: Colors.white,
      ),
    ),
  ),
  body: Stack(
        key: _gameAreaKey,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LightningPainter(
                bolts: lightnings,
                now: DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          ),

            Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 35, 18, 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  children: [
                    Text(
                      formatNumber(coins),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: tier.color,
                        shadows: [
                          Shadow(
                            color: tier.color.withOpacity(0.8),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        StatChip(
                          label: 'Clic',
                          value: formatNumber(realClickPower),
                          icon: Icons.touch_app,
                        ),
                        StatChip(
                          label: 'Sec',
                          value: formatNumber(realAutoPower),
                          icon: Icons.bolt,
                        ),
                        StatChip(
                          label: 'Multi',
                          value: 'x${globalMultiplier.toStringAsFixed(2)}',
                          icon: Icons.speed,
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    GestureDetector(
                      onTapDown: clickCoins,
                      child: AnimatedScale(
                        scale: buttonScale,
                        duration: const Duration(milliseconds: 80),
                        child: Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                tier.color,
                                tier.color.withOpacity(0.55),
                                Colors.black,
                              ],
                            ),
                            border: Border.all(
                              color: tier.color.withOpacity(0.9),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tier.color.withOpacity(0.65),
                                blurRadius: 45,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.electric_bolt,
                            size: 115,
                            color: Colors.black.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Améliorations',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),

                    const SizedBox(height: 12),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        if (!isWide) {
                          return Column(
                            children: upgrades.map((upgrade) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: UpgradeCard(
                                  upgrade: upgrade,
                                  level: upgradeLevels[upgrade.id] ?? 0,
                                  cost: upgradeCost(upgrade),
                                  canBuy: coins >= upgradeCost(upgrade),
                                  onBuy: () => buyUpgrade(upgrade),
                                  formatNumber: formatNumber,
                                ),
                              );
                            }).toList(),
                          );
                        }

                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: upgrades.map((upgrade) {
                            return SizedBox(
                              width: (constraints.maxWidth - 10) / 2,
                              child: UpgradeCard(
                                upgrade: upgrade,
                                level: upgradeLevels[upgrade.id] ?? 0,
                                cost: upgradeCost(upgrade),
                                canBuy: coins >= upgradeCost(upgrade),
                                onBuy: () => buyUpgrade(upgrade),
                                formatNumber: formatNumber,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: buildFloatingTexts(),
            ),
          ),
        ],
      ),
    );
  }
}

class UpgradeCard extends StatelessWidget {
  final UpgradeDefinition upgrade;
  final int level;
  final double cost;
  final bool canBuy;
  final VoidCallback onBuy;
  final String Function(double) formatNumber;

  const UpgradeCard({
    super.key,
    required this.upgrade,
    required this.level,
    required this.cost,
    required this.canBuy,
    required this.onBuy,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: canBuy ? onBuy : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(14),
        minimumSize: const Size(double.infinity, 92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Icon(upgrade.icon, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upgrade.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(upgrade.description),
                Text('Niveau $level'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatNumber(cost),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: canBuy ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label : $value'),
      side: BorderSide(
        color: Colors.white.withOpacity(0.18),
      ),
      backgroundColor: Colors.black.withOpacity(0.15),
    );
  }
}

class UpgradeDefinition {
  final String id;
  final String name;
  final String description;
  final double baseCost;
  final double growth;
  final double clickBonus;
  final double autoBonus;
  final double multiplierFactor;
  final IconData icon;

  const UpgradeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.growth,
    this.clickBonus = 0,
    this.autoBonus = 0,
    this.multiplierFactor = 1,
    required this.icon,
  });
}

class CurrencyTier {
  final Color color;

  const CurrencyTier({
    required this.color,
  });
}

class LightningBolt {
  final List<Offset> points;
  final Color color;
  final int createdAt;
  final int durationMs;

  const LightningBolt({
    required this.points,
    required this.color,
    required this.createdAt,
    this.durationMs = 650,
  });
}

class FloatingTextEffect {
  final String text;
  final Offset position;
  final Color color;
  final int createdAt;
  final int durationMs;

  const FloatingTextEffect({
    required this.text,
    required this.position,
    required this.color,
    required this.createdAt,
    this.durationMs = 900,
  });
}

class LightningPainter extends CustomPainter {
  final List<LightningBolt> bolts;
  final int now;

  LightningPainter({
    required this.bolts,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final bolt in bolts) {
      final age = now - bolt.createdAt;
      final progress = (age / bolt.durationMs).clamp(0.0, 1.0).toDouble();
      final opacity = (1 - progress).clamp(0.0, 1.0).toDouble();

      if (bolt.points.isEmpty || opacity <= 0) continue;

      final path = Path()..moveTo(bolt.points.first.dx, bolt.points.first.dy);

      for (final point in bolt.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      final glowPaint = Paint()
        ..color = bolt.color.withOpacity(0.18 * opacity)
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final mainPaint = Paint()
        ..color = bolt.color.withOpacity(0.9 * opacity)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final corePaint = Paint()
        ..color = Colors.white.withOpacity(0.95 * opacity)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, mainPaint);
      canvas.drawPath(path, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LightningPainter oldDelegate) {
    return true;
  }
}
