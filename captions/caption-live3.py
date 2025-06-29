#!/usr/bin/env python3
import os
import json
import time
import threading
import azure.cognitiveservices.speech as speechsdk
from collections import deque
import textwrap

# ——— Load Azure creds ———
cred_path = os.path.expanduser("~/.azure_speech_creds")
with open(cred_path, "r") as f:
    creds = json.load(f)

speech_config = speechsdk.SpeechConfig(
    subscription=creds["key"],
    region=creds["region"]
)
# Better punctuation
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_PostProcessingOption,
    "TrueText"
)
# Use simple output format
speech_config.output_format = speechsdk.OutputFormat.Detailed

audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
recognizer  = speechsdk.SpeechRecognizer(speech_config, audio_config)

# ——— Shared state ———
rollup       = deque(maxlen=2)  # last 2 finalized lines
interim_text = ""               # current in-flight text
lock         = threading.Lock()

# ——— Event handlers ———
def on_recognizing(evt):
    global interim_text
    with lock:
        interim_text = evt.result.text.strip()


def on_recognized(evt):
    global interim_text
    final = evt.result.text.strip()
    if not final:
        return
    # wrap final text into lines of max 50 chars
    wrapped = textwrap.wrap(final, 50)
    with lock:
        for line in wrapped:
            # if last rollup line has room, append to it
            if rollup and len(rollup[-1]) + 1 + len(line) <= 50:
                rollup[-1] += ' ' + line
            else:
                rollup.append(line)
        interim_text = ""

recognizer.recognizing.connect(on_recognizing)
recognizer.recognized.connect(on_recognized)

# ——— Display thread ———
running = True

def display_loop():
    while running:
        os.system("clear")
        with lock:
            # print current roll-up lines
            for ln in rollup:
                print(ln)
            # print interim text wrapped to 50 chars
            if interim_text:
                for line in textwrap.wrap(interim_text, 50):
                    print(line)
        time.sleep(0.2)  # redraw at 5×/sec

# ——— Main ———
if __name__ == "__main__":
    print("\n🎤 Azure Live Roll-Up Captions (Ctrl+C to stop)\n")
    t = threading.Thread(target=display_loop, daemon=True)
    t.start()
    recognizer.start_continuous_recognition()
    try:
        while True:
            time.sleep(0.1)
    except KeyboardInterrupt:
        pass
    finally:
        running = False
        recognizer.stop_continuous_recognition()
        t.join()
        print("\n⛔ Stopped by user.")
