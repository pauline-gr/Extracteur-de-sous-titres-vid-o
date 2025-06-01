# Extracteur de sous-titres - Windows

## Installation

### Installer Whisper et Torch

Installer Whisper et les dépendances nécessaires :

```bash
pip install --user openai-whisper
pip install --user torch
```

### Ajouter le dossier des scripts Python au PATH

Ajouter le chemin du dossier des scripts Python à la variable d'environnement PATH.

1. Sur Windows, faire `Win` → taper **variables d'environnement** → cliquer sur **"Modifier les variables d'environnement système"** → cliquer sur **"Variables d'environnement"** en bas

2. Dans la section **"Variables utilisateur"**, sélectionner la variable `Path` et cliquer sur **"Modifier"** → **"Nouveau"** → ajouter le chemin où se trouve le dossier des scripts Python. Par exemple :

```
C:\Users\utilisateur\AppData\Roaming\Python\Python311\Scripts
```

Vérification :

Dans un terminal, exécuter la commande suivante pour s'assurer que Whisper est bien installé :

```bash
whisper --help
```

Si l'aide s'affiche, l'installation est correcte.

### Installer FFmpeg

1. Se rendre sur le site officiel : [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)

2. Cliquer sur **Windows**, puis sélectionner le lien **"Windows builds from gyan.dev"** ou accéder directement à [https://www.gyan.dev/ffmpeg/builds/](https://www.gyan.dev/ffmpeg/builds/)

3. Télécharger l’archive **ffmpeg-release-essentials.zip**

4. Extraire le contenu de l’archive dans un dossier, par exemple :

```
C:\ffmpeg
```

Le fichier `ffmpeg.exe` se trouvera alors dans :

```
C:\ffmpeg\bin
```

### Ajouter FFmpeg au PATH

1. Sur Windows, faire `Win` → taper **variables d'environnement** → cliquer sur **"Modifier les variables d'environnement système"** → cliquer sur **"Variables d'environnement"** en bas

2. Dans la section **"Variables utilisateur"**, sélectionner la variable `Path` → cliquer sur **"Modifier"** → **"Nouveau"** → ajouter le chemin suivant :

```
C:\ffmpeg\bin
```

3. Valider avec **OK** sur toutes les fenêtres, puis redémarrer le terminal

Vérification :

Dans un terminal, exécuter la commande suivante pour s’assurer que FFmpeg est bien installé :

```bash
ffmpeg -version
```

Si les informations de version s'affichent, l’installation est terminée.

## Utilisation

Déposer les fichiers vidéo au format MP4 à la racine du projet, double cliquer sur le fichier `whisper_batch_cleaner.bat` pour lancer le traitement ou exécuter la commande suivante dans un terminal :

```bash
./whisper_batch_cleaner.sh
```

Cette commande va extraire les sous-titres des fichiers vidéo et les enregistrer dans un fichier texte pour chaque vidéo dans le dossier `done`. Une fois le traitement terminé, les fichiers vidéo seront déplacés dans le dossier `done`.
