# Reality Windows 10 Port — v13.19 MIDI-Input Lifecycle Fix

This build is based on v13.16, but fixes the failure shown by the supplied v13.16 runtime log.

## What the log proved

Changing MIDI input does **not** corrupt `engine+0x284` or `engine+0x256`: the engine still reports 44100 Hz / output mode 4. Instead, Reality transiently closes the synthetic `Reality` MIDI output. v13.16 treated that ordinary MIDI-device close as a request to stop the entire recovered SSYNENG engine. That stopped the AA9B0 render pump and ran service-4/final cleanup. The following MIDI reopen then restarted service 3 while the DirectSound output was being reconfigured.

The observed bad sequence was:

```text
MIDI output close
 -> host engine pump stopped
 -> SSYNENG service4 teardown
 -> MIDI input open/start
 -> lifecycle service3 init
 -> outputRunning=0, midiProcessGate=0
 -> host pump starts again
```

The modern rate bridge later re-registered cleanly at 44100 Hz, so v13.16's rate-field guard was addressing the wrong failure point.

## v13.17 change

`NativeMidiCloseDevice()` no longer calls `NativeMidiStopEngine()` when the last ordinary MIDI device record closes. MIDI close/open is now treated as routing churn only. The SSYNENG/DSP lifecycle and AA9B0 pump stay alive across a MIDI-input selection change.

Full teardown is still performed by `NativeMidiShutdownDriver()` during driver unload and by SSYNENG's ordered process-exit shutdown.

The v13.10 split-rate/fold fix and v13.14-v13.16 rate guards are otherwise unchanged.

## Build / run

Build Win32/x86 with `build_vs2022.bat`, then launch with:

```bat
run_reality_v13_17.bat "C:\Reality\Reality\Reality.exe" "C:\Reality\Banksets"
```

See `TEST_V13_17.md` for the focused runtime test.


## v13.19 CLAP GUI

The CLAP alpha now has a fixed-size Win32 editor that reparents Reality's main `Reality GUI` window into the host. See `START_HERE_V13_19_CLAP.md`.
