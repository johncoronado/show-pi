#!/usr/bin/env python3
import os
import json
import time
import threading
import azure.cognitiveservices.speech as speechsdk
from collections import deque
import textwrap
import tkinter as tk

# ——— Ensure DISPLAY is set ———
os.environ["DISPLAY"] = ":0"

# ——— Load Azure creds ———
cred_path = os.path.expanduser("~/.azure_speech_creds")
with open(cred_path, "r") as f:
    creds = json.load(f)

# ——— Configure Speech SDK ———
speech_config = speechsdk.SpeechConfig(
    subscription=creds["key"],
    region=creds["region"]
)
# TrueText punctuation
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_PostProcessingOption,
    "TrueText"
)
# Reduce flicker on partials
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_StablePartialResultThreshold,
    "3"
)
# Simple text-only output
speech_config.output_format = speechsdk.OutputFormat.Simple
# Use time-based segmentation (2 sec silence)
speech_config.set_property(
    speechsdk.PropertyId.Speech_SegmentationStrategy,
    "Time"
)
speech_config.set_property(
    speechsdk.PropertyId.Speech_SegmentationSilenceTimeoutMs,
    "2000"
)

audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
recognizer  = speechsdk.SpeechRecognizer(speech_config, audio_config)

# ——— Shared state ———
rollup         = deque(maxlen=2)  # keep exactly 2 committed lines
buffered_text  = ""               # accumulate until final punctuation
interim_lines  = []               # in-flight wrapped lines
lock           = threading.Lock()
running        = True

# ——— Helper ———
def wrap_lines(text):
    return textwrap.wrap(text, 50)

# ——— Event handlers ———
def on_recognizing(evt):
    global interim_lines
    partial = evt.result.text or ""
    with lock:
        # merge buffered + live partial
        combined = (buffered_text + " " + partial).strip()
        interim_lines = wrap_lines(combined)

def on_recognized(evt):
    global buffered_text, interim_lines
    final = evt.result.text.strip()
    if not final:
        return

    # accumulate into buffer
    buffered_text = (buffered_text + " " + final).strip()

    # commit only on true punctuation
    if buffered_text[-1] in ".?!":
        wrapped = wrap_lines(buffered_text)
        with lock:
            for ln in wrapped:
                rollup.append(ln)
            # reset for next sentence
            buffered_text = ""
            interim_lines = []
    else:
        # still no terminal punctuation, treat as interim
        with lock:
            interim_lines = wrap_lines(buffered_text)

recognizer.recognizing.connect(on_recognizing)
recognizer.recognized.connect(on_recognized)

# ——— Tkinter overlay setup ———
root = tk.Tk()
root.attributes("-fullscreen", True)
root.configure(bg="black")
root.bind("<Escape>", lambda e: root.destroy())

label = tk.Label(
    root,
    text="",
    font=("Helvetica", 32),
    fg="white",
    bg="black",
    justify="left",
)
label.pack(side="bottom", fill="x", padx=20, pady=40)

# ——— Refresh both terminal & HDMI ———
def refresh():
    os.system("clear")
    with lock:
        merged = list(rollup) + interim_lines
        # only show last 2 lines for true roll-up
        display_lines = merged[-2:]
    # terminal debug
    for ln in display_lines:
        print(ln)
    # HDMI overlay
    label.config(text="\n".join(display_lines))
    root.after(200, refresh)

# ——— Main ———
if __name__ == "__main__":
    print("\n🎤 Azure Live Roll-Up Captions (Esc to close, Ctrl+C to stop)\n")
    recognizer.start_continuous_recognition()
    root.after(0, refresh)
    try:
        root.mainloop()
    except KeyboardInterrupt:
        pass
    finally:
        running = False
        recognizer.stop_continuous_recognition()
        print("\n⛔ Stopped by user.")
