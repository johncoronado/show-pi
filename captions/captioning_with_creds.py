#!/usr/bin/env python3

from datetime import time
from itertools import pairwise
from os import linesep, remove
from os.path import exists
from time import sleep
from typing import List, Optional
import wave
import azure.cognitiveservices.speech as speechsdk  # type: ignore
import caption_helper
import helper
import user_config_helper
import os
import json

# ——— Load Azure credentials ———
cred_path = os.path.expanduser("~/.azure_speech_creds")
with open(cred_path, "r") as f:
    creds = json.load(f)
os.environ["SPEECH_KEY"] = creds["subscription"]
os.environ["SPEECH_REGION"] = creds["region"]

USAGE = """Usage: python captioning.py [...]

  HELP
    --help                           Show this help and stop.

  CONNECTION
    --key KEY                        Your Azure Speech service resource key.
                                     Overrides the SPEECH_KEY environment variable. You must set the environment
                                     variable (recommended) or use the `--key` option.
    --region REGION                  Your Azure Speech service region.
                                     Overrides the SPEECH_REGION environment variable. You must set the environment
                                     variable (recommended) or use the `--region` option.
                                     Examples: westus, eastus

  LANGUAGE
    --language LANG1                 Specify language. This is used when breaking captions into lines.
                                     Default value is en-US.
                                     Examples: en-US, ja-JP

  INPUT
    --input FILE                     Input audio from file (default input is the microphone.)
    --format FORMAT                  Use compressed audio format.
                                     If this is not present, uncompressed format (wav) is assumed.
                                     Valid only with --file.
                                     Valid values: alaw, any, flac, mp3, mulaw, ogg_opus

  MODE
    --offline                        Output offline results.
                                     Overrides --realTime.
    --realTime                       Output real-time results.
                                     Default output mode is offline.

  ACCURACY
    --phrases ""PHRASE1;PHRASE2""    Example: ""Constoso;Jessie;Rehaan""

  OUTPUT
    --output FILE                    Output captions to FILE.
    --srt                            Output captions in SubRip Text format (default format is WebVTT.)
    --maxLineLength LENGTH           Set the maximum number of characters per line for a caption to LENGTH.
                                     Minimum is 20. Default is 37 (30 for Chinese).
    --lines LINES                    Set the number of lines for a caption to LINES.
                                     Minimum is 1. Default is 2.
    --delay MILLISECONDS             How many MILLISECONDS to delay the appearance of each caption.
                                     Minimum is 0. Default is 1000.
    --remainTime MILLISECONDS        How many MILLISECONDS a caption should remain on screen if it is not replaced by another.
                                     Minimum is 0. Default is 1000.
    --quiet                          Suppress console output, except errors.
    --profanity OPTION               Valid values: raw, remove, mask
                                     Default is mask.
    --threshold NUMBER               Set stable partial result threshold.
                                     Default is 3.
"""

# Import the main logic from Microsoft sample
from captioning import Captioning

if user_config_helper.cmd_option_exists("--help"):
    print(USAGE)
else:
    captioning = Captioning()
    captioning.initialize()
    speech_recognizer_data = captioning.speech_recognizer_from_user_config()
    captioning.recognize_continuous(
        speech_recognizer=speech_recognizer_data["speech_recognizer"],
        format=speech_recognizer_data["audio_stream_format"],
        callback=speech_recognizer_data["pull_input_audio_stream_callback"],
        stream=speech_recognizer_data["pull_input_audio_stream"]
    )
    captioning.finish()
