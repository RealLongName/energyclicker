
# Energy Clicker

Energy Clicker is a clicker game developed with **Flutter**.

The goal is simple: click to generate energy, buy upgrades, increase your earnings per click and per second, and progress further and further.

The game is designed to run on:

* Windows
* Android

## Features

* Main click system
* Purchasable upgrades
* Earnings per click
* Automatic earnings per second
* Global multiplier
* Visual effects with lightning bolts
* Local save
* Cloud synchronization with Firebase
* Login via email/password
* Admin menu to change the currency and quickly test the game
* Display of large numbers with K, M, B, T, etc.

## Technologies used

* Flutter
* Dart
* Firebase Auth
* Cloud Firestore
* Shared Preferences

## Project Installation

To launch the project, you must have Flutter installed on your PC.

Clone the project:

```bash
git clone https://github.com/RealLongName/energyclicker.git
cd energyclicker
```

Install the dependencies:

```bash
flutter pub get
```

Launch the game on Windows:

```bash
flutter run -d windows
```

Launch the game on Android:

```bash
flutter run -d <YOUR_PHONE_ID>
```

Example:

```bash
flutter run -d RFCW40CGMWY
```

## Build Windows

To create a Windows version:

```bash
flutter build windows
```

The build file will then be located in:

```txt
build/windows/x64/runner/Release
```

## Build Android APK

To create an Android APK :

```bash
flutter build apk
```

The APK can then be found in:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

## Firebase

The game uses Firebase for:

* Account authentication;

* Cloud saves;

* Synchronization between Windows and Android.

The services used are:

* Firebase Authentication
* Cloud Firestore

## Progression

Player progress is saved with:

* A local save on the device;

* A cloud save if the player is connected.

## Project Status

The game is still in development.

Improvements may be added later, such as:

* More improvements;

* Prestige/Rebirth;

* Achievements;

* Shop;

* Advanced visual effects;

* Improved menus;

* Skin system;

* Public Android APK version.

## Author

Project created by **LongName**.






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

Projet créé par **LongName**.
