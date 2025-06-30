#!/usr/bin/env python3
import os
import json
import time
import threading
import azure.cognitiveservices.speech as speechsdk # type: ignore
from collections import deque
import textwrap
import tkinter as tk

# ——— Ensure DISPLAY is set ———
os.environ["DISPLAY"] = ":0"

# ——— Load Azure creds ———
cred_path = os.path.expanduser("~/git/azure_speech_creds")
with open(cred_path, "r") as f:
    creds = json.load(f)

# ——— Configure Speech SDK ———
speech_config = speechsdk.SpeechConfig(
    subscription=creds["key"],
    region=creds["region"]
)

speech_config.set_property(
    property_id = speechsdk.PropertyId.SpeechServiceResponse_StablePartialResultThreshold,
    value = "20" # string, not int
)

speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_PostProcessingOption,
    "TrueText"
)
# Don’t finalize on short pauses—wait 3000 ms of silence
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceConnection_EndSilenceTimeoutMs,
    "3000"
)
speech_config.set_property(
    speechsdk.PropertyId.SpeechServiceResponse_StablePartialResultThreshold,
    "3"
)
speech_config.output_format = speechsdk.OutputFormat.Simple

audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
recognizer  = speechsdk.SpeechRecognizer(speech_config, audio_config)

# ——— Shared state ———
rollup       = deque()          # unbounded commit history
interim_text = ""               # current in-flight text
lock         = threading.Lock()
running      = True

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
        for line in wrapped:
            # commit each wrapped line
            rollup.append(line)
        interim_text = ""

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

# ——— Combined refresh ———
def refresh():
    # clear terminal
    os.system("clear")
    with lock:
        # merge committed + interim
        merged = list(rollup)
        if interim_text:
            merged.extend(textwrap.wrap(interim_text, 50))
        # cap to last 4 lines
        display_lines = merged[-4:]
    # terminal output
    for ln in display_lines:
        print(ln)
    # HDMI overlay
    label.config(text="\n".join(display_lines))
    # schedule next update
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
