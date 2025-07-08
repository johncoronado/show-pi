#!/usr/bin/env python3
import os, json, time, threading
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
# We want BOTH interim and final
speech_config.output_format = speechsdk.OutputFormat.Simple

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
    wrapped = textwrap.wrap(final, 50)
    with lock:
        # commit each wrapped line into rollup
        for line in wrapped:
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
            # print roll-up lines first
            for ln in rollup:
                print(ln)
            # then the current interim (if any)
            if interim_text:
                # wrap interim to 50 characters max
                for line in textwrap.wrap(interim_text, 50):
                    print(line)
        time.sleep(0.2)  # redraw 5×/sec

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
