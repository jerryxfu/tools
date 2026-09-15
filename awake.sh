#!/bin/bash
#
# awake.sh
# Disables sleep (including lid-closed sleep) while this script runs,
# then restores your previous sleep settings when you stop it (Ctrl+C).
#
# Usage: ./awake.sh
#
# Notes:
# - Requires sudo, because "pmset -a disablesleep 1" needs admin rights.
# - This lets the machine stay fully awake with the lid closed, as long
#   as it's plugged into power (on battery, macOS may still sleep on
#   lid-close for safety — using an external display/dock is one way
#   to make lid-closed operation reliable, but that's independent of
#   this script).

set -u

# --- Capture current settings so we can restore them exactly ---
echo "Reading current power settings..."

ORIG_DISABLESLEEP=$(pmset -g custom | grep -m1 'disablesleep' | awk '{print $2}')
if [ -z "$ORIG_DISABLESLEEP" ]; then
    ORIG_DISABLESLEEP=0
fi

echo "Current disablesleep value: $ORIG_DISABLESLEEP"

CAFFEINATE_PID=""
RESTORED=0

# --- Restore function, runs on exit no matter how we exit ---
# Guarded with RESTORED so it only ever does its work once, even though
# the trap fires on both INT (Ctrl+C) and EXIT.
restore_settings() {
    if [ "$RESTORED" -eq 1 ]; then
        return
    fi
    RESTORED=1

    echo ""
    echo "Stopping..."

    # Kill caffeinate if it's still running
    if [ -n "$CAFFEINATE_PID" ] && kill -0 "$CAFFEINATE_PID" 2>/dev/null; then
        kill "$CAFFEINATE_PID" 2>/dev/null
        wait "$CAFFEINATE_PID" 2>/dev/null
    fi

    echo "Restoring disablesleep to $ORIG_DISABLESLEEP..."
    sudo pmset -a disablesleep "$ORIG_DISABLESLEEP"

    echo "Done. Sleep settings restored."
}

trap restore_settings EXIT INT TERM

# --- Disable sleep (lets the lid be closed without sleeping) ---
echo "Disabling sleep (lid-closed included)..."
if ! sudo pmset -a disablesleep 1; then
    echo "Could not get sudo access — exiting without changing anything."
    RESTORED=1  # nothing was actually changed, so skip the restore step
    exit 1
fi

# --- Run caffeinate in the foreground ---
# -i : prevent idle sleep
# -m : prevent disk sleep
# -s : prevent system sleep (AC power)
# -u : declare user is active (resets idle timer, useful with lid closed)
# (no -d, so the display is still allowed to sleep on its own schedule —
#  this doesn't affect screenshots or anything reading the screen, since
#  the OS and GUI layer keep running even with the display off)
echo "Starting caffeinate. Press Ctrl+C to stop and restore normal sleep behavior."
caffeinate -i -m -s -u &
CAFFEINATE_PID=$!

wait "$CAFFEINATE_PID"
