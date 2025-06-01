#!/bin/bash

# --- PARAMÈTRES PERSONNALISABLES ---
MODEL="medium"
MAX_LEN=35
DONE_DIR="done"

# Modifier ici la langue utilisée pour la transcription (ex : fr, en, es, etc.)
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

  # Extraction de l'audio depuis la vidéo avec ffmpeg
  ffmpeg -y -i "$video" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$AUDIO"

  # Transcription de l'audio avec Whisper
  PYTHONIOENCODING=utf-8 whisper "$AUDIO" --model "$MODEL" --output_format srt --output_dir . --language "$LANG"

  # Recherche du fichier SRT
  RAW_SRT=$(ls -1 "${BASENAME}"*.srt 2>/dev/null | head -n 1)

  # Si aucun fichier SRT n'est généré, on passe à la vidéo suivante
  if [[ ! -f "$RAW_SRT" ]]; then
    echo "❌ Aucune transcription générée pour $video. Vidéo laissée dans le dossier."
    rm -f "$AUDIO"
    continue
  fi

  # Traitement et découpage des sous-titres
  python - <<EOF
import re
from datetime import datetime, timedelta

def split_line(line, max_length=$MAX_LEN):
    words = line.split()
    chunks = []
    current = ""
    for word in words:
        if len(current + " " + word) <= max_length:
            current += " " + word if current else word
        else:
            chunks.append(current)
            current = word
    if current:
        chunks.append(current)
    return chunks

with open("$RAW_SRT", "r", encoding="utf-8") as f:
    content = f.read()

entries = re.findall(r"(\d+)\s+(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})\s+(.+?)(?=\n\n|\Z)", content, re.DOTALL)

new_srt = []
counter = 1
fmt = "%H:%M:%S,%f"

for i, (num, start, end, text) in enumerate(entries):
    lines = text.replace('\n', ' ').strip()
    parts = split_line(lines)

    start_dt = datetime.strptime(start, fmt)
    end_dt = datetime.strptime(end, fmt)
    duration = (end_dt - start_dt) / len(parts)

    for idx, part in enumerate(parts):
        seg_start = start_dt + duration * idx
        seg_end = seg_start + duration
        new_srt.append(f"{counter}\n{seg_start.strftime(fmt)[:-3]} --> {seg_end.strftime(fmt)[:-3]}\n{part}\n")
        counter += 1

with open("$CLEAN_SRT", "w", encoding="utf-8") as f:
    f.write("\n".join(new_srt))
EOF

  # Nettoyage des fichiers temporaires et déplacement du résultat
  mv "$video" "$DONE_DIR/"
  mv "$CLEAN_SRT" "$DONE_DIR/"
  rm -f "$AUDIO" "$RAW_SRT"

  echo "✅ Terminé : ${DONE_DIR}/${CLEAN_SRT}"

done

read -p "Appuyez sur Entrée pour fermer..."
