#!/bin/bash

# --- PARAMÈTRES PERSONNALISABLES ---
MODEL="medium"
DONE_DIR="done"
LANG="fr"

mkdir -p "$DONE_DIR"

# --- VÉRIFICATION DES DÉPENDANCES ---
for cmd in ffmpeg whisper python; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Erreur : '$cmd' n'est pas installé."
    exit 1
  fi
done

# --- TRAITEMENT DES VIDÉOS ---
for video in *.mp4; do
  [[ -e "$video" ]] || continue

  BASENAME="${video%.mp4}"
  AUDIO="${BASENAME}_audio.wav"
  CLEAN_SRT="${BASENAME}_clean.srt"

  echo "▶️ Traitement : $video"

  # Extraction de l'audio
  ffmpeg -y -i "$video" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$AUDIO"

  # Transcription avec Whisper
  PYTHONIOENCODING=utf-8 whisper "$AUDIO" --model "$MODEL" --output_format srt --output_dir . --language "$LANG"

  RAW_SRT=$(ls -1 "${BASENAME}"*.srt 2>/dev/null | head -n 1)

  if [[ ! -f "$RAW_SRT" ]]; then
    echo "❌ Aucune transcription générée pour $video. Vidéo laissée dans le dossier."
    rm -f "$AUDIO"
    continue
  fi

  # Nettoyage simple sans découpe ni décalage
  python - <<EOF
import re
from datetime import datetime

fmt = "%H:%M:%S,%f"

with open("$RAW_SRT", "r", encoding="utf-8") as f:
    content = f.read()

entries = re.findall(
    r"(\\d+)\\s+(\\d{2}:\\d{2}:\\d{2},\\d{3}) --> (\\d{2}:\\d{2}:\\d{2},\\d{3})\\s+(.+?)(?=\\n\\n|\\Z)",
    content, re.DOTALL)

new_srt = []

for idx, (num, start, end, text) in enumerate(entries, 1):
    clean_text = ' '.join(text.strip().splitlines()).strip()
    new_srt.append(f"{idx}\\n{start} --> {end}\\n{clean_text}\\n")

with open("$CLEAN_SRT", "w", encoding="utf-8") as f:
    f.write("\\n".join(new_srt))
EOF

  # Nettoyage
  mv "$video" "$DONE_DIR/"
  mv "$CLEAN_SRT" "$DONE_DIR/"
  rm -f "$AUDIO" "$RAW_SRT"

  echo "✅ Terminé : ${DONE_DIR}/${CLEAN_SRT}"

done

read -p "Appuyez sur Entrée pour fermer..."
