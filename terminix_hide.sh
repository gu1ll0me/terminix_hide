if [ ! $(type -P xdotool) ] ; then
    echo "xdotool not found."
    exit
fi

TNIX_COLS=128
TNIX_ROWS=56
TNIX_X=50
TNIX_Y=50
TNIX_TMPFILE=/tmp/terminix_geometry

pid=$(ps -e | grep 'terminix' | awk '{print $1}')
if [ -z $pid ] ; then
    # Not launched
    terminix --geometry=${TNIX_COLS}x${TNIX_ROWS}+${TNIX_X}+${TNIX_Y}
else
    winid=$(xdotool search --pid $pid | sort -n | head -n2 | tail -n1)
    focused=$(xdotool getactivewindow)
    if [ $focused -eq $winid ] ; then
        # Visible and focused
        xdotool getwindowgeometry --shell $winid > $TNIX_TMPFILE
        xdotool windowunmap $winid
    else
        visible=$(xdotool search --onlyvisible --pid $pid)
        if [ -z $visible ] ; then
            # Hidden
            x=$(cat $TNIX_TMPFILE | grep 'X=' | cut -d'=' -f 2)
            y=$(cat $TNIX_TMPFILE | grep 'Y=' | cut -d'=' -f 2)
            xdotool windowmap $winid
            xdotool windowmove $winid $x $y
            xdotool windowactivate $winid
        else
            # Visible but not focused
            xdotool set_desktop_for_window $winid $(xdotool get_desktop)
            xdotool windowfocus $winid
            xdotool windowraise $winid
        fi
    fi
fi
