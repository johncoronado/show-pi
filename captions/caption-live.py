#!/usr/bin/env python3
import os
import json
import time
import threading
import azure.cognitiveservices.speech as speechsdk
from collections import deque
import textwrap

# ——— Minimal CaptionHelper ———
class CaptionHelper:
    def __init__(self, language: str, max_line_length: int, lines: int):
        self.max_line_length = max_line_length
        self.lines = lines

    def lines_from_text(self, text: str):
        # simple word-aware wrap, cap at self.lines
        return textwrap.wrap(text, self.max_line_length)[:self.lines]

# ——— Load Azure creds ———
cred_path = os.path.expanduser("~/.azure_speech_creds")
with open(cred_path, "r") as f:
    creds = json.load(f)

# ——— Configure Speech SDK ———
speech_config = speechsdk.SpeechConfig(
    subscription=creds["key"],
    region=creds["region"]
)
# Better punctuation
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_PostProcessingOption,
    "TrueText"
)
# Stable-partial threshold to reduce flicker
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_StablePartialResultThreshold,
    "3"
)
# Simple text output
speech_config.output_format = speechsdk.OutputFormat.Simple

# ——— Audio setup ———
audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
recognizer  = speechsdk.SpeechRecognizer(speech_config, audio_config)

# ——— CaptionHelper for line‐wrapping & roll-up logic ———
helper = CaptionHelper(language="en-US", max_line_length=50, lines=2)

# ——— Shared state ———
rollup        = deque(maxlen=2)  # committed lines
interim_lines = []               # in-flight wrapped lines
lock          = threading.Lock()
running       = True

# ——— Event handlers ———
def on_recognizing(evt):
    text = evt.result.text or ""
    wrapped = helper.lines_from_text(text)
    with lock:
        interim_lines.clear()
        interim_lines.extend(wrapped)

def on_recognized(evt):
    text = evt.result.text or ""
    wrapped = helper.lines_from_text(text)
    with lock:
        for ln in wrapped:
            rollup.append(ln)
        interim_lines.clear()

recognizer.recognizing.connect(on_recognizing)
recognizer.recognized.connect(on_recognized)

# ——— Display loop ———
def display_loop():
    while running:
        os.system("clear")
        with lock:
            # print committed roll-up lines
            for ln in rollup:
                print(ln)
            # print current interim lines
            for ln in interim_lines:
                print(ln)
        time.sleep(0.2)

# ——— Main ———
if __name__ == "__main__":
    print("\n🎤 Azure Live Roll-Up Captions (Ctrl+C to stop)\n")
    # start the display thread
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
