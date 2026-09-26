# CleanCity — Contexte du projet pour Claude Code

## 1. Contexte

Ce projet est réalisé dans le cadre du **Flufithon '26**, le hackathon final du **FlutterFire Summer Camp 2026**. Nous sommes une équipe de 5 étudiants qui terminent une formation Flutter + Firebase. La thématique du hackathon est celle des **ODD (Objectifs de Développement Durable)**.

- **Début du développement :** 26 septembre 2026
- **Freeze du code et rendu final :** 6 octobre 2026 à 23h59 GMT
- **Demo Day devant le jury :** 10 octobre 2026

Le projet sera présenté en direct : **la priorité absolue est une application stable qui fonctionne**, plutôt qu'une application ambitieuse mais fragile. Le code doit rester compréhensible par des étudiants de niveau intermédiaire, car chaque membre de l'équipe doit pouvoir expliquer sa partie au jury.

## 2. Le projet

**Nom :** CleanCity
**ODD ciblés :** ODD 11 (Villes et communautés durables) et ODD 13 (Lutte contre le changement climatique)
**Contexte géographique :** Abidjan, Côte d'Ivoire

**Description :** CleanCity est une application mobile qui permet aux citoyens de signaler les dépôts d'ordures sauvages et les caniveaux bouchés grâce à une photo et leur position GPS. Une intelligence artificielle analyse la photo pour identifier le type de problème, estimer son niveau d'urgence et proposer une description. Les signalements sont visibles par tous et peuvent être suivis jusqu'à leur résolution, pour des quartiers plus propres et moins exposés aux inondations.

## 3. Stack technique

- **Flutter** (dernière version stable) et **Dart**, application mobile Android en priorité (iOS si possible, sans bloquer le reste)
- **Firebase Authentication** : inscription et connexion par email / mot de passe
- **Cloud Firestore** : base de données
- **Pas de Firebase Storage** : il exige le forfait Blaze (carte bancaire), que nous n'avons pas. Les photos sont compressées et stockées en base64 directement dans Firestore (voir section 5).
- **Rodium AI** (sponsor du hackathon) : analyse des photos. Rodium AI est une passerelle d'API compatible OpenAI (`https://api.rodiumai.io/v1`) qui donne accès aux modèles d'OpenAI, Anthropic, Google, etc. avec une seule clé. Documentation : https://www.rodiumai.io/docs
- **Packages complémentaires :** `http` (appels à Rodium AI), `image_picker` (photo), `geolocator` (GPS), `url_launcher` (ouvrir Google Maps), `provider` (gestion d'état), `intl` (formatage des dates)

Avant d'utiliser un package, vérifie sur pub.dev la version actuelle et sa documentation. Pour Rodium AI, consulte la documentation officielle (endpoint `POST /v1/chat/completions`, liste des modèles via `GET /v1/models`) plutôt que de supposer le format.

Le fichier `lib/firebase_options.dart` est généré par `flutterfire configure` par le Lead et commité dans le dépôt. Ne le régénère pas et ne le modifie pas.

## 4. Fonctionnalités

### Rôles utilisateurs
- **Citoyen** : crée des signalements, consulte tous les signalements, suit l'état des siens.
- **Admin** : en plus, change le statut des signalements. Le rôle admin est attribué manuellement dans Firestore (pas d'écran pour devenir admin).

### Écrans
1. **Splash / redirection** : redirige vers la connexion ou l'accueil selon l'état d'authentification (`authStateChanges`).
2. **Connexion** et **Inscription** (nom, email, mot de passe), avec messages d'erreur clairs en français.
3. **Accueil** : fil des signalements les plus récents en temps réel (StreamBuilder), avec filtres par statut et par catégorie. Bouton flottant « Signaler ».
4. **Nouveau signalement** :
   - prise de photo (caméra) ou choix dans la galerie ;
   - analyse automatique de la photo par l'IA, qui pré-remplit catégorie, urgence et description ;
   - l'utilisateur peut corriger les champs avant de valider ;
   - récupération de la position GPS ; en cas de refus de permission ou d'erreur, saisie manuelle de la commune (liste déroulante) et d'un repère ;
   - envoi : compression de la photo, encodage en base64, puis création du document Firestore contenant la photo ;
   - indicateur de chargement pendant l'analyse et l'envoi.
5. **Détail d'un signalement** : photo, catégorie, urgence, description, date, auteur, statut, bouton « Voir sur la carte » qui ouvre Google Maps (`https://www.google.com/maps?q=LAT,LNG`). Si l'utilisateur est admin, possibilité de changer le statut.
6. **Mes signalements** : liste des signalements de l'utilisateur connecté.
7. **Profil** : nom, email, nombre de signalements, déconnexion.
8. **(Bonus, seulement si tout le reste fonctionne)** Carte intégrée affichant tous les signalements avec `flutter_map` (sans clé API).

### Valeurs possibles
- **Catégories :** `ordures`, `caniveau`, `eau_stagnante`, `autre`
- **Urgence :** `faible`, `moyenne`, `elevee`
- **Statut :** `en_attente`, `en_cours`, `resolu`
- **Communes (saisie manuelle) :** Abobo, Adjamé, Attécoubé, Cocody, Koumassi, Marcory, Plateau, Port-Bouët, Treichville, Yopougon, Bingerville, Songon, Anyama

Dans l'interface, afficher ces valeurs avec des libellés lisibles en français (« Caniveau bouché », « Urgence élevée », « Résolu »…) et une couleur par statut et par urgence.

## 5. Modèle de données Firestore

Ces noms de collections et de champs sont **fixés pour toute l'équipe**. Ne les modifie pas sans le signaler explicitement.

```
users/{uid}
  nom: string
  email: string
  role: "citoyen" | "admin"
  createdAt: timestamp

signalements/{id}
  userId: string
  userNom: string
  description: string
  photoBase64: string    // photo JPEG compressée, encodée en base64
  categorie: "ordures" | "caniveau" | "eau_stagnante" | "autre"
  urgence: "faible" | "moyenne" | "elevee"
  statut: "en_attente" | "en_cours" | "resolu"
  latitude: number | null
  longitude: number | null
  commune: string | null
  repere: string | null
  analyseIA: boolean      // true si la catégorie a été proposée par l'IA
  createdAt: timestamp
  updatedAt: timestamp
```

### Stockage des photos dans Firestore
Firebase Storage n'est pas utilisé (forfait Blaze requis). La photo est stockée dans le champ `photoBase64` du document :
- à la sélection, `image_picker` compresse l'image avec `maxWidth: 800`, `maxHeight: 800` et `imageQuality: 60` ;
- les octets sont encodés avec `base64Encode` (`dart:convert`) ;
- **contrôle obligatoire :** si la chaîne base64 dépasse 700 000 caractères, recompresser plus fort (par exemple `maxWidth: 600`, `imageQuality: 45`) ou afficher un message d'erreur. La limite d'un document Firestore est de 1 Mo ;
- l'affichage utilise `Image.memory(base64Decode(...))` ; décoder une seule fois par widget (pas à chaque build) et prévoir un `errorBuilder` ;
- la même chaîne base64 est réutilisée pour l'analyse IA (section 6), sans nouvelle compression.

Limite connue, à assumer devant le jury : cette solution convient à un prototype avec quelques dizaines de signalements, pas à une application à grande échelle, où l'on passerait à un service de stockage de fichiers.

## 6. Analyse IA de la photo

L'analyse passe par **Rodium AI**, sponsor du hackathon. Service dédié `lib/services/ia_service.dart` qui :
1. reçoit la photo déjà compressée et encodée en base64 (la même que celle enregistrée dans Firestore) ;
2. appelle `POST https://api.rodiumai.io/v1/chat/completions` avec le package `http`, l'en-tête `Authorization: Bearer <clé>` et un message utilisateur au format OpenAI multimodal (une partie `text` avec la consigne, une partie `image_url` avec `data:image/jpeg;base64,...`) ;
3. utilise un modèle **qui accepte les images** (vision), choisi dans la liste `GET /v1/models` ou la page Models de Rodium (par exemple un modèle GPT-4o ou Gemini). Le nom du modèle est une constante dans `utils/constants.dart` pour pouvoir en changer facilement ;
4. demande une réponse **uniquement en JSON** au format :
   `{"categorie": "...", "urgence": "...", "description": "..."}`
   avec des valeurs limitées à celles de la section 4 et une description courte en français (une à deux phrases) ;
5. lit le texte dans `choices[0].message.content`, le nettoie et le parse de façon robuste (retirer d'éventuels ```json, vérifier que les valeurs sont autorisées) ;
6. applique un délai maximum de 20 secondes ;
7. **en cas d'erreur, de délai dépassé, de crédits RODI épuisés ou de réponse invalide, ne bloque jamais l'utilisateur** : renvoie `null`, et l'écran laisse l'utilisateur remplir les champs lui-même.

Si l'image ne montre aucun problème urbain identifiable, l'IA doit renvoyer `"autre"` et une description qui le signale.

**Première étape obligatoire :** avant d'écrire le service, vérifie dans la documentation Rodium AI que l'envoi d'images est bien supporté par l'endpoint chat completions et le modèle choisi. Si ce n'est pas le cas, signale-le-moi immédiatement au lieu de contourner le problème.

### Gestion de la clé API (dépôt GitHub public)
- La clé Rodium (`rd_sk_...`) ne doit **jamais** apparaître dans le code ni dans un commit.
- Elle est passée au build avec `--dart-define=RODIUM_API_KEY=rd_sk_...` et lue avec `const String.fromEnvironment('RODIUM_API_KEY')`.
- Pour simplifier, utilise un fichier `dart_defines.json` (lancé avec `--dart-define-from-file=dart_defines.json`), ajouté au `.gitignore`, et commite un modèle `dart_defines.example.json` sans vraie clé.
- Si la clé est vide, `ia_service` renvoie directement `null` (l'app fonctionne sans IA).
- Limite connue, acceptable pour un hackathon : une clé embarquée dans un APK peut être extraite. En production, l'appel passerait par un serveur.

## 7. Architecture du code

```
lib/
  main.dart
  firebase_options.dart
  models/        signalement.dart, app_user.dart  (fromFirestore / toMap)
  services/      auth_service.dart, signalement_service.dart,
                 image_service.dart, location_service.dart, ia_service.dart
  providers/     auth_provider.dart
  screens/       auth/, home/, signalement/, profil/
  widgets/       composants réutilisables (carte de signalement, badges…)
  utils/         constantes (catégories, statuts, communes, couleurs), thème
```

Principes :
- Les écrans n'appellent jamais Firebase directement : ils passent par les services.
- Un fichier par classe, noms de fichiers en `snake_case`.
- Thème centralisé dans `utils/theme.dart` (Material 3, couleur principale verte, par exemple `#2E7D32`), cohérent sur tous les écrans.
- Code commenté en français sur les parties non évidentes.
- Toute l'interface est en français.
- Gestion systématique des erreurs (try/catch) avec un message compréhensible pour l'utilisateur (SnackBar), jamais de crash.

## 8. Règles de sécurité

Fournir `firestore.rules` à la racine du projet :
- seuls les utilisateurs connectés peuvent lire les signalements ;
- un utilisateur ne peut créer un signalement qu'avec son propre `userId` et le statut `en_attente` ;
- seul un admin (champ `role` dans `users/{uid}`) peut modifier le statut ;
- un utilisateur ne peut modifier que son propre document `users/{uid}` et ne peut pas changer son `role` ;
- le champ `photoBase64` est obligatoire à la création et doit faire moins de 900 000 caractères.

## 9. Permissions natives

- **Android** (`AndroidManifest.xml`) : `INTERNET`, `CAMERA`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, et la déclaration `<queries>` nécessaire à `url_launcher` pour ouvrir des liens https.
- **iOS** (`Info.plist`) : `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSLocationWhenInUseUsageDescription`, avec des textes en français.
- Vérifie que `minSdkVersion` est compatible avec tous les packages Firebase.

## 10. Organisation de l'équipe et Git

Équipe de 5, chacun sur sa branche :
- **Lead** : base du projet, intégration, README → `feature/base`
- **Dev 2** : authentification et profil → `feature/auth`
- **Dev 3** : création de signalement, photo, GPS → `feature/signalement`
- **Dev 4** : liste, détail, filtres, statuts → `feature/liste`
- **Dev 5** : IA et thème → `feature/ia`

Règles :
- Ne jamais committer directement sur `main`.
- Rester dans le périmètre de la branche en cours ; si une modification touche une autre partie (modèles, constantes, services partagés), le signaler clairement.
- Commits petits et fréquents, messages en français au format `type: description` (`feat:`, `fix:`, `style:`, `docs:`, `refactor:`).
- Ne jamais committer de clés d'API privées, mots de passe ou fichiers de build.

## 11. Plan de développement

1. **Phase 1 — Base (26 sept)** : création du projet, dépendances, structure des dossiers, modèles, constantes, thème, `main.dart` avec initialisation Firebase et redirection selon l'authentification, écrans vides reliés par la navigation.
2. **Phase 2 — MVP (27 au 29 sept)** : authentification, création de signalement avec photo, liste en temps réel, détail. **Sans GPS ni IA.** À la fin de cette phase, l'application doit fonctionner de bout en bout.
3. **Phase 3 — Fonctionnalités clés (30 sept au 1er oct)** : GPS avec saisie manuelle en secours, analyse IA, gestion des statuts par l'admin, « Mes signalements », profil, filtres.
4. **Phase 4 — Qualité (2 au 4 oct)** : règles de sécurité, gestion des erreurs, états vides et de chargement, finitions du design, tests sur un vrai téléphone ; bonus carte si le temps le permet.
5. **Phase 5 — Rendu (5 au 6 oct)** : README complet (description, ODD, captures d'écran, fonctionnalités, installation, membres), génération de l'APK de release.

## 12. Méthode de travail attendue

- Avant chaque tâche importante, **présente un plan court** et attends ma validation.
- Travaille étape par étape ; après chaque étape, vérifie que le code compile (`flutter analyze`) et explique brièvement ce que tu as fait.
- Privilégie les solutions simples et éprouvées. Si une fonctionnalité risque de retarder le projet, propose une alternative plus simple.
- Quand une action manuelle est nécessaire dans la console Firebase (activer l'authentification email, créer Firestore, créer la clé API sur le tableau de bord Rodium AI, déployer les règles, passer un utilisateur en admin), **donne-moi les étapes précises** au lieu de supposer qu'elle est faite.
- Explique les choix importants de façon pédagogique : nous devons pouvoir défendre le code devant le jury.
