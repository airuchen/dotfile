#!/bin/sh
mkfifo ~/.local/state/gammastep || true
event=$1
case $event in
  period-changed)
    period=$3
    case $3 in
      none)
        echo "  " >> ~/.local/state/gammastep
        ;;
      daytime)
        echo "  " >> ~/.local/state/gammastep
        ;;
      night)
        echo "  " >> ~/.local/state/gammastep
        ;;
      transition)
        case $2 in
          daytime)
            echo "  " >> ~/.local/state/gammastep
            ;;
          night)
            echo "  " >> ~/.local/state/gammastep
            ;;
          none)
            echo "  " >> ~/.local/state/gammastep
            ;;
        esac
    esac
esac
