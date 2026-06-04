# Energy Clicker

Energy Clicker est un jeu de clicker développé avec **Flutter**.
Le but est simple : cliquer pour générer de l’énergie, acheter des améliorations, augmenter ses gains par clic et par seconde, puis progresser de plus en plus loin.

Le jeu est prévu pour fonctionner sur :

* Windows
* Android

## Fonctionnalités

* Système de clic principal
* Améliorations achetables
* Gains par clic
* Gains automatiques par seconde
* Multiplicateur global
* Effets visuels avec éclairs
* Sauvegarde locale
* Synchronisation cloud avec Firebase
* Connexion par compte email/mot de passe
* Menu admin pour modifier la monnaie et tester rapidement le jeu
* Affichage des grands nombres avec K, M, B, T, etc.

## Technologies utilisées

* Flutter
* Dart
* Firebase Auth
* Cloud Firestore
* Shared Preferences

## Installation du projet

Pour lancer le projet, il faut avoir Flutter installé sur le PC.

Clone le projet :

```bash
git clone https://github.com/RealLongName/energyclicker.git
cd energyclicker
```

Installe les dépendances :

```bash
flutter pub get
```

Lance le jeu sur Windows :

```bash
flutter run -d windows
```

Lance le jeu sur Android :

```bash
flutter run -d <ID_DE_TON_TELEPHONE>
```

Exemple :

```bash
flutter run -d RFCW40CGMWY
```

## Build Windows

Pour créer une version Windows :

```bash
flutter build windows
```

Le build se trouve ensuite dans :

```txt
build/windows/x64/runner/Release
```

## Build Android APK

Pour créer un APK Android :

```bash
flutter build apk
```

L’APK se trouve ensuite dans :

```txt
build/app/outputs/flutter-apk/app-release.apk
```

## Firebase

Le jeu utilise Firebase pour :

* l’authentification des comptes ;
* la sauvegarde cloud ;
* la synchronisation entre Windows et Android.

Les services utilisés sont :

* Firebase Authentication
* Cloud Firestore

## Progression

La progression du joueur est sauvegardée avec :

* une sauvegarde locale sur l’appareil ;
* une sauvegarde cloud si le joueur est connecté.

## Statut du projet

Le jeu est encore en développement.
Des améliorations peuvent être ajoutées plus tard, comme :

* plus d’améliorations ;
* prestige/rebirth ;
* succès ;
* boutique ;
* effets visuels avancés ;
* meilleurs menus ;
* système de skins ;
* version Android APK publique.

## Auteur

Projet créé par **RealLongName**.
