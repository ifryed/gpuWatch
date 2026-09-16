# GPU Watch

A floating macOS speedometer for live GPU usage.

It reads Apple GPU stats from IOKit (no sudo) and shows:

- **0–100%** device utilization on a needle gauge
- **GPU memory in GB** under the percentage
- A **Keep in Front** pin so the widget can sit above other windows

## Run

```bash
make run
```

## Install from the disk image

```bash
make dmg
open GPUWatch.dmg
```

Drag **GPU Watch** into Applications, then launch it from there or with Spotlight.

## Controls

- **Pin** on the widget (or **Keep in Front** in the menu bar): stay above other windows, or drop back to a normal window
- **X**: hide the widget
- **Menu bar extra**: show/hide, pin, or quit
- Close from the menu bar with **Quit GPU Watch**
