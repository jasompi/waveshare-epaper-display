ROOT_DIR=`git rev-parse --show-toplevel`

cd ${ROOT_DIR}

. InkyDisplay/env.sh

function log {
    echo "---------------------------------------"
    echo ${1^^}
    echo "---------------------------------------"
}


cd ${ROOT_DIR}

log "Add weather info"
.venv/bin/python3 screen-weather-get.py

log "Add Calendar info"
.venv/bin/python3 screen-calendar-get.py

# Only layout 5 shows a calendar, so save a few seconds.
if [ "$SCREEN_LAYOUT" -eq 5 ]; then
    log "Add Calendar month"
    .venv/bin/python3 screen-calendar-month.py
fi

if [ -f InkyDisplay/screen-custom-get.py ]; then
    log "Add Custom data"
    .venv/bin/python3 InkyDisplay/screen-custom-get.py
elif [ ! -f screen-output-custom-temp.svg ]; then
    # Create temporary empty svg since the main SVG needs it
    echo "<svg />" > screen-output-custom-temp.svg
fi



log "Resize svg"
. InkyDisplay/resolution.sh
.venv/bin/python3 inky-resize.py

log "Export to PNG"

.venv/bin/cairosvg -o screen-output.png -f png --dpi 300 --output-width $INKY_DISPLAY_WIDTH --output-height $INKY_DISPLAY_HEIGHT screen-output-weather.svg

[[ ! -z "${INKY_DISPLAY_BTADDR}" ]] &&  BTADDR_ARG="--btaddr ${INKY_DISPLAY_BTADDR}"

log "Display on epaper"
.venv/bin/python3 InkyDisplay/InkyDisplay.py --type ${INKY_DISPLAY_TYPE} ${BTADDR_ARG} --colour ${INKY_DISPLAY_COLOR} -i screen-output.png
