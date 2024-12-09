# General aliases
alias ..='cd ..'
alias ...='cd ../..'
alias v='vim'
alias nv='neovide'
alias g='git'
alias grep='grep --color=auto'
alias gdb='gdb -q'
alias feh="feh --scale-down"
alias diff='diff --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias mpvs='mpv --shuffle -- '
alias ncal3='ncal -3 -w'
alias cal='cal -m'
alias ytdl720="yt-dlp -f 'bestvideo[height<=720]+bestaudio'"
alias ytdlhd="yt-dlp -f 'bestvideo[width<=1920]+bestaudio'"
alias ytdl_it='yt-dlp --no-mtime --no-call-home'
alias ytaudio='mpv --ytdl-format=bestaudio'
command -v fdfind > /dev/null && alias fd='fdfind'
alias pmode_toggle='xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -T && echo "Presentation mode is $(xfconf-query  -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -v)"'
# Load loopback module for monitoring inputs
alias paloop='pactl load-module module-loopback'

# Apt
alias sau='sudo apt update && apt list --upgradable'

# Compilers
alias use_gcc='CC=gcc CXX=g++'
alias clang_build='CC=clang-15 CXX=clang++-15 LD=clang++-15'
alias clang_build_traced='CC="clang-15 -ftime-trace" CXX="clang++-15 -ftime-trace" LD=clang++-15'
alias clang_asan='CC="clang-15 -fsanitize=address" CXX="clang++-15 -fsanitize=address" LD=clang++-15'
alias gnu_asan='CC="gcc -fsanitize=address -ggdb" CXX="g++ -fsanitize=address -ggdb"'
alias alias_edit='vim ~/config/bash_aliases && alias_reload'
alias alias_reload='source ~/config/bash_aliases'
alias pformat='autopep8 --max-line-length 120 -i -r'

run_asan() {
  local asan_loc
  asan_loc=$(ldconfig -p | awk '/libasan/ {print $4}') || return 255
  LD_PRELOAD=${asan_loc} ${@}
}


# Toggle debugging, etc
alias dbg_enable='echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope'
alias dbg_disable='echo 1 | sudo tee /proc/sys/kernel/yama/ptrace_scope'
alias perf_enable='echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid'
alias perf_disable='echo 3 | sudo tee /proc/sys/kernel/perf_event_paranoid'
alias coredumpson='ulimit -c unlimited'
alias coredumpsoff='ulimit -c 0'
# make wlan prio higher than lan
#sudo route add -net default gw 10.17.43.254 netmask 0.0.0.0 dev wlp1s0 metric 1
#setxkbmap to reset kb layout

# Docker
if command -v docker &> /dev/null ; then
  alias kaniko='docker run --rm -v$(pwd):/context:ro gcr.io/kaniko-project/executor:debug --context /context'
  # Docker image inspection tool
  alias dive='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest'
  if command -v fzf &> /dev/null ; then
    source ~/config/docker_fzf
  fi
elif command -v podman &> /dev/null ; then
  alias kaniko='podman run --rm -v$(pwd):/context:ro gcr.io/kaniko-project/executor:debug --context /context'
  # Docker image inspection tool
  # Needs systempct start --user podman.socket
  alias dive='podman run --rm -it -v /var/run/user/${UID}/podman/podman.sock:/var/run/docker.sock wagoodman/dive:latest'
fi



# Workspaces
alias cdnav='cdws nav'
# alias cdbmw='cdws bmwstr'
# alias cdlearn='cdws learning'
# alias source_ikos='export PATH=/home/fez/local/ikos/bin:$PATH'
# alias tf_env='. ~/git/tensorflow-env/bin/activate'
# alias tb_log='tensorboard --host 127.0.0.1 --logdir'


add_ros_alias() {
	# Common launch commands
	alias bmwregcfgui='ROBOT_ENV=werk-regensburg-halle-56 roslaunch bmwstr_bringup config_gui.launch launch_server:=false'
	alias bmwrviz='roslaunch bmwstr_bringup rviz.launch robot:=str_v3'
	alias bmwsim='roslaunch bmwstr_simulation single_robot_sim.launch robot:=str_v3'
	alias bmwteleop='roslaunch /home/fez/git/bmwstr/teleop_keyboard.launch'
	alias bmwnav='roslaunch bmwstr_bringup ground_truth_nav.launch'
	alias bmwltsnav='roslaunch bmwstr_bringup ipa_navigation.launch robot:=str_v3 robot_env:=bmw-factory localization_backend:=lts_ng lts_backup_folder:=/tmp'
	alias bgsim='roslaunch cob_bringup_sim robot.launch gui:=false'
	alias fgsim='roslaunch cob_bringup_sim robot.launch'
	alias cobsim='bgsim robot:=cob4-18'
	alias ltsnav='roslaunch ipa_navigation ipa_navigation.launch'
	alias iparviz='roslaunch ipa_navigation rviz.launch'
	alias reconfig='rosrun rqt_reconfigure rqt_reconfigure'
	alias viewltsmap='roslaunch ipa_long_term_slam lts_view.launch robot_env:=unused map:=$PWD/map.yaml ltsmap:=$PWD/map.ltsmap'

	# Compile flags
	alias ckin_dbg_cfg='catkin config --cmake-args "-DCMAKE_C_COMPILER_LAUNCHER=ccache" "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache" "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" "-DCMAKE_BUILD_TYPE=Debug" -DCMAKE_CXX_FLAGS="-Werror=uninitialized -Werror=return-type -Werror=format -Wsign-compare -ggdb"'
	alias ckin_san_cfg='catkin config --cmake-args "-DCMAKE_C_COMPILER_LAUNCHER=ccache" "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache" "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" "-DENABLE_SANITIZER_ADDRESS=ON" "-DENABLE_SANITIZER_LEAK=ON" "-DENABLE_SANITIZER_UNDEFINED_BEHAVIOR=ON" "-DCMAKE_BUILD_TYPE=Debug" -DCMAKE_CXX_FLAGS="-Werror=uninitialized -Werror=return-type -Werror=format -Wsign-compare -ggdb"'
	alias ckin_san_rel_cfg='catkin config --cmake-args "-DCMAKE_C_COMPILER_LAUNCHER=ccache" "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache" "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" "-DENABLE_SANITIZER_ADDRESS=ON" "-DENABLE_SANITIZER_LEAK=ON" "-DENABLE_SANITIZER_UNDEFINED_BEHAVIOR=ON" "-DCMAKE_BUILD_TYPE=Release" -DCMAKE_CXX_FLAGS="-Werror=uninitialized -Werror=return-type -Werror=format -Wsign-compare -ggdb"'
	alias ckin_rel_cfg='catkin config --cmake-args "-DCMAKE_C_COMPILER_LAUNCHER=ccache" "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache" "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" "-DCMAKE_BUILD_TYPE=Release" -DCMAKE_CXX_FLAGS="-Werror=uninitialized -Werror=return-type -Werror=format -Wsign-compare -ggdb"'

	alias trace_lts_ng='rosparam set /lts_ng/trace_output /tmp/lts_ng && rosparam set /lts_ng/trace_debug true'
	live_lts_trace() {
		fname=$(fd -tf lts_ng.*.json /tmp/ | sort -r | head -n 1)
		if [ "${fname}" ]; then
			tail -f "${fname}"
		fi
	}

	alias no_odom_ramps='rosrun dynamic_reconfigure dynparam  set /move_base/EbandLocalPlanner/controller/diff use_odom_for_ramps false'

	verbose_rosconsole() {
		export ROSCONSOLE_FORMAT='[${severity} T: ${time}] [${node}/${thread} ${file}:${line} (${function})] ${message}'
	}

	single_ros_test() {
		if [ $# -lt 2 ]; then
			echo "Usage: single_ros_test package testname [test args]"
			echo "Use --gtest_filter=SomeRegex* to run specific tests only"
			return;
		fi;
		catkin build "$1" --no-deps --make-args "$2" && rosrun "$1" "$2" "${@:3}"
	}

	rostest_gdb() {
		if [ $# -lt 2 ]; then
			echo "Usage: rostest_gdb package testname [test args]"
			echo "Use --gtest_filter=SomeRegex* to run specific tests only"
			return;
		fi;
		gdb --args "$(catkin_find "$1" "$2")" "${@:3}"
	}

	single_ros_test_xml() {
		if [ $# -lt 2 ]; then
			echo "Usage: single_ros_test_xml package testname [rostest args]"
			return
		fi
		catkin build "$1" --no-deps --make-args "$2" && rostest "${@:3}" "$1" "${2}.xml"
	}

	single_ros_test_test() {
		if [ $# -lt 2 ]; then
			echo "Usage: single_ros_test_test package testname [rostest args]"
			return
		fi
		catkin build "$1" --no-deps --make-args "$2" && rostest "${@:3}" "$1" "${2}.test"
	}

	single_ros_test_launch() {
		if [ $# -lt 2 ]; then
			echo "Usage: single_ros_test_launch package testname [rostest args]"
			return
		fi
		catkin build "$1" --no-deps --make-args "$2" && rostest "${@:3}" "$1" "${2}.launch"
	}

	stop_override() {
		local topic="/base/twist_mux/command_teleop_keyboard"
		if [ $# -gt 0 ]; then
			topic="${1}"
		fi
		echo "topic is ${topic}"
		rostopic pub "${topic}" geometry_msgs/Twist "{linear: {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}" -r100
	}
}

function pandocslides {
	if [ $# -ne 1 ]; then
		echo "Usage: pandocslides source.org"
		return;
	fi;
	pandoc -t revealjs -s --self-contained --slide-level=3 -o "${1}.html" "${1}"
}

function mp3_convert {
  find -maxdepth 1 -iname '*.flac' -type f -print0  | xargs -0 -P 8 -n 1 lame --out-dir /tmp -V 0 -S
}

function ffmpeg_compress {
	if [ $# -ne 2 ]; then
		echo "Usage: ffmpeg_comress in out"
		return;
	fi;
	ffmpeg -i "$1" -c:v libx265 -preset medium "$2"
}

function ffmpeg_from_pngs {
  if [ $# -ne 2 ]; then
    echo "Usage: ffmpeg_from_pngs file_pattern output.mp4"
    return;
  fi;
  # yuv420p so powerpoint can play it
  # use input pattern like foo_%6d.png
  ffmpeg -r 24 -i "${1}" -pix_fmt yuv420p -r 24 "${2}"
}

alias record_rviz_area='sleep 5;ffmpeg -probesize 10M -r 60 -f x11grab -video_size 1920x1080 -i :0.0+5760,58 -c:v libx265 -crf 0 -x265-params pools=4 -preset ultrafast -vf format=yuv420p -r 15'
alias record_screen_2_x264='sleep 5;ffmpeg -probesize 10M -r 30 -f x11grab -video_size 1920x1080 -i :0.0+5760,58 -c:v libx264 -crf 0 -preset ultrafast'
alias record_screen_2='sleep 5;ffmpeg -probesize 10M -r 30 -f x11grab -video_size 3840x2160 -i :0.0+3840,0 -c:v libx265 -crf 0 -preset ultrafast -vf format=yuv420p -r 15'
alias record_screen_2_half_res='sleep 5;ffmpeg -probesize 10M -r 30 -f x11grab -video_size 3840x2160 -i :0.0+3840,0 -c:v libx265 -crf 0 -preset ultrafast -size 1920x1080 -vf format=yuv420p -r 30'
alias record_screen_2_raw='sleep 5;ffmpeg -video_size 3840x2160 -framerate 15 -f x11grab -i :0.0+3840,0 -c:v libx264 -crf 0 -preset ultrafast'

# FFMPEG Gif stuff
# ffmpeg -ss 61.0 -t 2.5 -i StickAround.mp4 -filter_complex "[0:v] palettegen" palette.png
# ffmpeg -ss 61.0 -t 2.5 -i StickAround.mp4 -i palette.png -filter_complex "[0:v][1:v] paletteuse" prettyStickAround.gif

function ffmpeg_make_gif {
	if [ $# -lt 1 ]; then
		echo "Need a filename"
		return
	fi
	ffmpeg -i "$1" -filter_complex "[0:v] palettegen" /tmp/palette.png
	ffmpeg -i "$1" -i /tmp/palette.png -filter_complex "[0:v][1:v] paletteuse" "${1}.gif"
}

function rsource_ros2_base {
  local ROS_ROOT
  [ -d "/opt/ros/jazzy" ] && . /opt/ros/jazzy/setup.bash
  # [ -d "/opt/ros/iron" ] && . /opt/ros/iron/setup.bash
  [ -e /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]\
    && . /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
  [ -e /usr/share/colcon_cd/function/colcon_cd.sh ]\
    && . /usr/share/colcon_cd/function/colcon_cd.sh
}

function rsource {
  local ROS_ROOT
  [ -d "/opt/ros/noetic" ] && ROS_ROOT="/opt/ros/noetic/setup.bash"
  # ROS2 things
  [ -e /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]\
    && . /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
  [ -e /usr/share/colcon_cd/function/colcon_cd.sh ]\
    && . /usr/share/colcon_cd/function/colcon_cd.sh
	local WS_ROOT="git"
	local ws
  ws=$(pwd | grep -o -e "^/home/${USER}/${WS_ROOT}/[^\/]\+")
	if [ -z "$ws" ]; then
		echo "Not inside a workspace, sourcing from ${ROS_ROOT}";
		source "${ROS_ROOT}"
		return 0;
	fi
  for cs in "install" "devel"; do
    local path="${ws}/${cs}/setup.bash"
    if [ -e "${path}" ]; then
      echo "Sourcing workspace in ${path}";
      source "${path}";
      return 0;
    fi
  done
  echo "Devel space not found";
  return 2;
}

function cdws {
  if [ $# -lt 1 ]; then
    echo "No ws!"
    return
  fi
  local workspace=~/git/${1}
  if [ -d "${workspace}" ]; then
    export ROS_WORKSPACE=${workspace}
		export RCUTILS_COLORIZED_OUTPUT=1
    cd "${workspace}/src/${1}" 2>/dev/null || cd "${workspace}/src/" || cd "${workspace}" || return
    # if [ -e "${workspace}/.built_by" ]; then
			rsource_ros2_base
		# else
		# 	add_ros_alias
		# 	rsource
		# fi
  fi
}

function is_ros_workspace {
	{ [ -n "${ROS_WORKSPACE}" ] && [ -d "${ROS_WORKSPACE}" ]; } || { echo "Not a ROS workspace" && false; }
}
alias cdbase='is_ros_workspace && cd $ROS_WORKSPACE'
alias cds='is_ros_workspace && cd $ROS_WORKSPACE/src'
alias cdbuild='is_ros_workspace && cd $ROS_WORKSPACE/build'
alias cddev='is_ros_workspace && cd $ROS_WORKSPACE/devel/.private'

# Better roscd
function rcd {
  local pkgpath
  pkgpath=$(cols list --base-paths "${ROS_WORKSPACE}" | fzf -q "${1}" | cut -f 2)
  [ -n "${pkgpath}" ] && cd "${pkgpath}"
}

# Better rosed
function re {
  local pkg
  pkg=$(cols  list --base-paths "${ROS_WORKSPACE}" | fzf -q "${1}" | cut -f 2)
  [ -n "${pkg}" ] || return
  local filename
  filename=$(fd -0 --type f . "${pkg}" | fzf --read0 --prompt="file: ")
  [ -n "${filename}" ] || return
  ${EDITOR} "${filename}"
}

alias threadps='ps -T -f -p '
# alias safety_plot='rosrun rqt_plot rqt_plot cmd_vel_safety/linear/x cmd_vel_reduced/linear/x'

function if_ip_addr {
  ifconfig "${1}" | awk '/inet / {print $2}'
  #ifconfig "${1}" | grep 'inet addr' | cut -d: -f2 | cut -d\  -f 1 # kinetic
}

function perf_record_pid {
  perf record "${@:2}" -p "${1}" -o "${HOME}/perf_records/${1}-$(date --iso-8601=seconds).perf"
}

function perf_record {
  local pid
  pid=$(pidof "${1}")
  if [ -z "${pid}" ]; then
    echo "No such process"
    return
  fi
  perf record "${@:2}" -p "${pid}" -o "${HOME}/perf_records/${1}-$(date --iso-8601=seconds).perf"
}

function prompted_dmenu {
  dmenu -f -c -l 30 -i -p "$(echo "${@:1}")"
}

function list_ros_masters {
  # Seems to be reliable for roscores, but technically the -p argument could be anywhere...
  pgrep -a rosmaster | awk '{print $6}' | sort
}

function with_rosmaster {
  local port
  port=$(ps -ax | awk '/[r]osmaster/ {print $9}' | sort | prompted_dmenu "${@:1}")
  ROS_MASTER_URI=http://localhost:${port} "${@:1}"
}

alias wrm='with_rosmaster'

function with_rosnode {
  rosnode list |  prompted_dmenu "${@:1}" | xargs -r "${@:1}"
}

alias rni='with_rosnode rosnode info'

function with_rostopic {
  rostopic list | prompted_dmenu "${@:1}" | xargs -r "${@:1}"
}

alias rti='with_rostopic rostopic info'

function exportrosmaster {
  local wifi_dev="enp5s0"
  local lan_dev="enp5s0"

  local dev=${lan_dev}
  local uri="http://127.0.0.1:11311"

  if [ $# -ge 3 ]; then
    if [ "${3}" = "lan" ]; then
      dev=${lan_dev}
    elif [ "${3}" = "wifi" ]; then
      dev=${wifi_dev}
    else
      dev=${3}
    fi
  fi

  if [ $# -ge 2 ]; then
    uri="http://${2}"
  else
    dev="lo" # use loopback if nothing is specified
  fi

  local profile="local"
  if [ $# -ge 1 ]; then
    profile="${1}"
  fi

  local ip
  ip=$(if_ip_addr ${dev})

  export ROS_MASTER_URI=${uri}
  export ROS_IP=${ip}
  echo "Set ROS_MATER_URI=${uri} and ROS_IP=${ip} for preset ${profile} on device ${dev}"
}

function detect_on_network {
  nmap --open -p 11311 "${1}"/24 --host-timeout 2 -oG - | awk '/^[^#]/ {print $3" "$2":11311 wifi"}'
}

function srm_detect {
  local wifi_dev="enp5s0"
  local ip
  ip=$(if_ip_addr ${wifi_dev})
  local candidates
  candidates=$(detect_on_network "${ip}") || return
  local selected
  selected=$(echo "${candidates}" | uniq | prompted_dmenu "set ros master") || return
  exportrosmaster ${selected}
}

function srp {
  export ROS_MASTER_URI=http://localhost:${1}
  export ROS_IP=127.0.0.1
  echo "Set ROS_MATER_URI=${ROS_MASTER_URI} and ROS_IP=${ROS_IP}"
}

function srm {
  # find running cores/ports
  local discovered
  discovered="$(list_ros_masters | awk '{print "running 127.0.0.1:" $0 " lo"}')"
  if [ -z "$discovered" ]; then
    discovered="local"
  fi

  local presets="${discovered}
automatica 192.168.10.22:11311 wifi
logimat 192.168.1.42:11311 wifi
vfd_serer 192.168.0.104:11311 wifi
raw4-0-lan 192.168.0.127:11311 wifi
raw3-3 192.168.43.101:11311 wifi
str16 192.168.10.135:11311 wifi
str203 192.168.0.147:11311 wifi
dcartnighthawk 192.168.0.139:11311 wifi
dcartdirect 10.42.0.1:11311 wifi
dcart 192.168.10.145:11311 wifi
begmachine 192.168.1.100:11311 wifi
mir 192.168.12.20:11311 wifi
mir_pc_2 192.168.10.133:11311 wifi
cob4-18 10.4.18.11:11311 wifi
cob4-20 10.4.20.11:11311 wifi"

  local selected
  selected=$(echo "${presets}" | prompted_dmenu "set ros master") || return
  exportrosmaster ${selected}
}

function kill_named_pythons {
  if [ $# -ne 1 ]; then
    echo "Need an argument"
    return;
  fi
  pgrep -a -f "python.*${1}" || return
  read -r -p "Kill those processes?" choice
  if [ "${choice}" = "y" ]; then
    kill -9 $(pgrep -f "python.*${1}")
  fi
}

function jqdiff {
  if [ $# -ne 2 ]; then
    echo "Usage: jqdiff base candidate"
    return;
  fi

  diff <(jq --sort-keys . "${1}") <(jq --sort-keys . "${2}")
}

function devenv {
  if [ -e "pyproject.toml" ] || [ -e "tox.ini" ]; then
    tox devenv
    source venv/bin/activate
  else
    echo "No pyproject.toml/tox.ini found"
  fi
}

function verbose_ros2console {
  export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity} {time}] [{name}] [{function_name} @ {file_name}:{line_number})]: {message}"
}


# Transferring GPG keys
# gpg --export-secret-key KeyId | ssh user@remote gpg --allow-secret-key-import --import
# gpg --export KeyId | ssh user@remote gpg --import


# Keep ros1 on localhost
export ROS_MASTER_URI=http://localhost:11311
# Keep ros2 on localhost
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_PYTHON_CHECK_FIELDS=1
export RCUTILS_COLORIZED_OUTPUT=1
export CYCLONEDDS_URI="file:///${HOME}/config/cyclonedds.xml"
export MAKEFLAGS="-j12 -l12"
