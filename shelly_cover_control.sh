#!/bin/bash

# Default properties file
DEFAULT_PROPERTIES_FILE="config.properties"

# Check if PROPERTIES_FILE environment variable is set, otherwise use default
PROPERTIES_FILE="${PROPERTIES_FILE:-$DEFAULT_PROPERTIES_FILE}"

# Load the properties file
if [[ -f "$PROPERTIES_FILE" ]]; then
  source "$PROPERTIES_FILE"
else
  echo "Error: Properties file '$PROPERTIES_FILE' not found."
  exit 1
fi

SHELLY_IP=$(pass $PASS_SHELLY_IP)
if [[ -z "$SHELLY_IP" ]]; then
  echo "Error: Unable to retrieve Shelly IP."
  exit 1
fi

SHELLY_PASS=$(pass $PASS_SHELLY_PASSWORD)
if [[ -z "$SHELLY_PASS" ]]; then
  echo "Error: Unable to retrieve Shelly password."
  exit 1
fi

CURL="curl -s --digest -X POST"

# Function to get cover configurations
get_status() {
  $CURL http://${SHELLY_IP}/rpc/Cover.GetStatus \
       --user admin:${SHELLY_PASS} \
       -d '{"id":0}'
}

# Function to get cover configurations
get_configuration() {
  $CURL http://${SHELLY_IP}/rpc/Cover.GetConfig \
       --user admin:${SHELLY_PASS} \
       -d '{"id":0}'
}

# Function to set cover position
set_position() {
  local position=$1
  $CURL http://${SHELLY_IP}/rpc/Cover.GoToPosition \
       --user admin:${SHELLY_PASS} \
       -d "{\"id\":0, \"pos\":${position}}"
}

# Function to open the cover
open_cover() {
  $CURL http://${SHELLY_IP}/rpc/Cover.Open \
       --user admin:${SHELLY_PASS} \
       -d '{"id":0}'
}

# Function to close the cover
close_cover() {
  $CURL http://${SHELLY_IP}/rpc/Cover.Close \
       --user admin:${SHELLY_PASS} \
       -d '{"id":0}'
}

# Function to stop the cover
stop_cover() {
  $CURL http://${SHELLY_IP}/rpc/Cover.Stop \
       --user admin:${SHELLY_PASS} \
       -d '{"id":0}'
}

add_percent() {
  current_pos=$(get_status | jq '.current_pos')
  if [ "$current_pos" -le "$LOW_LIMIT_FOR_PERCENT" ]; then
    new_pos=$((current_pos + $1))
    if [ "$new_pos" -gt 100 ]; then
      new_pos=100
    fi
    set_position $new_pos
  else
    echo "Current position is already 70% or more, no action taken."
  fi
}

# Main script logic
case $1 in
  set_position)
    if [[ "$2" =~ ^[0-9]+$ ]]; then
      if (( $2 >= 0 && $2 <= 100 )); then
        set_position $2
      else
        echo "Error: Position must be between 0 and 100."
        echo "Usage: $0 set_position [0-100]"
        exit 1
      fi
    else
      echo "Error: Position must be an integer."
      echo "Usage: $0 set_position [0-100]"
      exit 1
    fi
  ;;
  open)
    open_cover
    ;;
  close)
    close_cover
    ;;
  stop)
    stop_cover
    ;;
  quarter)
    add_percent 1
    ;;
  half)
    add_percent 2
    ;;
  set)
    case $2 in
      pos)
        if [[ "$3" =~ ^[0-9]+$ ]]; then
          if (( $3 >= 0 && $3 <= 100 )); then
            set_position $3
          else
            echo "Error: Position must be between 0 and 100."
            echo "Usage: $0 set_position [0-100]"
            exit 1
          fi
        else
          echo "Error: Position must be an integer."
          echo "Usage: $0 set_position [0-100]"
          exit 1
        fi
        ;;
      *)
        echo "Error: Unknow parameter."
        echo "Usage: set [pos]"
        exit 1
    esac
    ;;
  get)
    case $2 in
      temp)
        current_temp_c=$(get_status | jq '.temperature.tC')
        echo "$current_temp_c°C"
        ;;
      pos)
        current_pos=$(get_status | jq '.current_pos')
        echo "$current_pos%"
        ;;
      status)
        case $3 in
          pretty)
            get_status | jq '.'
            ;;
          *) get_status
            ;;
        esac
        ;;
      state)
        state=$(get_status | jq '.state')
        echo ${state//\"/}
        ;;
      configuration)
        get_configuration
        ;;
      *)
        echo "Error: Unknow parameter."
        echo "Usage: get [pos|state|status [pretty]|temp]"
        exit 1
    esac
    ;;
  *)
    echo "Usage: $0 {get_status|get_configuration|set_position|open|close|stop|quarter|half|get} [position|temp|pos|state]"
    ;;
esac
