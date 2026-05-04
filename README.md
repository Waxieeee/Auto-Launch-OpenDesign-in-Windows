# Auto Launch OpenDesign in Windows

A Windows batch script that starts your local [OpenDesign]([https://opendesign.dev](https://github.com/nexu-io/open-design)) dev server, automatically detects the randomized port it binds to, and opens Brave Browser directly to the correct URL — no manual copy-pasting required.

---

## Why This Exists

OpenDesign's dev server (`pnpm exec tools-dev run web`) binds to `http://127.0.0.1` on a **randomized port every time it starts**. That means every launch you have to:

1. Wait for the server to boot
2. Scan terminal output for the port number
3. Manually type or copy the URL into your browser

That's friction you don't need. This script eliminates all three steps — launch it once, and Brave opens automatically on the right URL the moment the server is ready.

---

## What It Does

1. Navigates to your OpenDesign project directory
2. Activates the correct Node version via `nvm`
3. Starts the dev server **in a separate terminal window**, piping its output to a temp log file
4. Polls the log file every 2 seconds, waiting for a `http://127.0.0.1:<port>` URL to appear
5. Extracts the full URL using a PowerShell regex match
6. Opens that URL directly in Brave Browser

The server window stays open and live — closing it stops the server. The launcher window stays open so you can see the detected URL and log file path.

---

## Requirements

| Requirement | Notes |
|---|---|
| Windows 10 / 11 | Batch + PowerShell (both built-in) |
| [nvm for Windows](https://github.com/coreybutler/nvm-windows) | To manage Node versions |
| Node.js (via nvm) | Version configurable in the script |
| pnpm | Must be on your PATH |
| OpenDesign project | Cloned and dependencies installed |
| Brave Browser | Falls back to default browser if not found |

---

## Quickstart

### 1. Clone or download this repo

```bash
git clone https://github.com/YOUR_USERNAME/auto-launch-opendesign-windows.git
```

Or just download `start-opendesign.bat` directly.

---

### 2. Open the script in any text editor

Look for the **CONFIGURE THESE** block near the top of the file:

```batch
:: ── CONFIGURE THESE ──────────────────────────────────────────────────────────
:: Path to your OpenDesign project folder
set "PROJECT_DIR=C:\Users\B3ast\open-design"

:: Path to Brave Browser executable (check both Program Files locations)
set "BRAVE=C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
set "BRAVE_ALT=C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"

:: Node version to use (via nvm)
set "NODE_VERSION=24"
:: ─────────────────────────────────────────────────────────────────────────────
```

---

### 3. Replace the values

| Variable | What to change | How to find it |
|---|---|---|
| `PROJECT_DIR` | Full path to your OpenDesign project folder | Navigate to it in Explorer, copy the address bar |
| `BRAVE` | Path to `brave.exe` | Run `where brave` in a terminal, or check your Brave shortcut properties |
| `BRAVE_ALT` | Secondary Brave path to try | Usually the `(x86)` variant — leave as-is unless you know it's elsewhere |
| `NODE_VERSION` | Node version number for `nvm use` | Run `nvm list` to see what's installed; pick what OpenDesign needs |

**Example — if your username is `John` and your project is in `Documents`:**
```batch
set "PROJECT_DIR=C:\Users\John\Documents\open-design"
```

---

### 4. Run the script

Double-click `start-opendesign.bat`, or right-click → **Run as administrator** if you hit permission issues with nvm.

You'll see output like:
```
=========================
Starting OpenDesign...
=========================
Current directory:
C:\Users\John\Documents\open-design
Switching Node version...
Now using node v24.0.0 (64-bit)
Starting server (output captured to: C:\Users\John\AppData\Local\Temp\opendesign_server.log)
Waiting for server URL......
============================================
 Server detected at: http://127.0.0.1:54321/
============================================
Opening Brave Browser...
```

Brave will open automatically at the correct URL.

---

## Troubleshooting

**Script says "Brave not found" and opens default browser instead**
Run `where brave` in a terminal and paste the result into the `BRAVE=` line.

**Script hangs on "Waiting for server URL" forever**
The server may be outputting the URL in a different format. Open the log file at `%TEMP%\opendesign_server.log` while the script is running and look for the URL. If it doesn't contain `http://127.0.0.1:`, open an issue with a sample of your server output.

**`nvm` is not recognized**
Make sure [nvm for Windows](https://github.com/coreybutler/nvm-windows) is installed and on your system PATH. Restart your terminal after installing.

**`pnpm` is not recognized**
Install pnpm globally: `npm install -g pnpm`, or follow the [pnpm installation guide](https://pnpm.io/installation).

---

## License

MIT — do whatever you want with it.
