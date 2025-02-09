alias trash='mv -t ~/.local/share/Trash/files/'
alias dbg_enable='echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope'
alias dbg_disable='echo 1 | sudo tee /proc/sys/kernel/yama/ptrace_scope'
alias ckin_dbg_cfg='catkin config --cmake-args "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" "-DCMAKE_BUILD_TYPE=Debug" -DCMAKE_CXX_FLAGS="-Werror=uninitialized -Werror=return-type -Werror=format -ggdb"'
alias cb='colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 --cmake-args -DBUILD_TESTING=OFF --parallel-workers 12'
alias cb_db='colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 --cmake-args -DBUILD_TESTING=OFF --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo --parallel-workers 12'
alias cb_db_p='colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 --cmake-args -DBUILD_TESTING=OFF --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo --parallel-workers 12 --packages-up-to '
alias cb_test='colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 --cmake-args -DBUILD_TESTING=ON --cmake-args -DCMAKE_BUILD_TYPE=Debug --parallel-workers 12'
alias is_ros_workspace='[ -n "${ROS_WORKSPACE}" ] && [ -d "${ROS_WORKSPACE}" ] || (echo "Not a ROS workspace" && false)'
alias rdi='rosdep install --from-paths src -r -y'

# General aliases
alias l='ls -CF'
alias devcontainer_up='devcontainer up --workspace-folder ./'
alias ..='cd ..'
alias ...='cd ../..'
alias v='vim'
alias vim='nvim'
# alias nv='neovide --multigrid'
alias g='git'
alias ga='git commit --amend --no-edit'
alias gP='git push --force-with-lease'
alias gp='git pull --rebase'
alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gf='git fetch --all'

alias grep='grep --color=auto'
alias gdb='gdb -q'
# alias feh="feh --scale-down"
alias diff='diff --color=auto'
alias cp='cp -i'
alias mv='mv -i'
# alias mpvs='mpv --shuffle -- '
# alias ncal3='ncal -3 -w'
# alias cal='cal -m'
# alias ytdl720="yt-dlp -f 'bestvideo[height<=720]+bestaudio'"
# alias ytdlhd="yt-dlp -f 'bestvideo[width<=1920]+bestaudio'"
# alias ytdl_it='yt-dlp --no-mtime --no-call-home'
command -v fdfind > /dev/null && alias fd='fdfind'
# alias pmode_toggle='xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -T && echo "Presentation mode is $(xfconf-query  -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -v)"'
# Load loopback module for monitoring inputs
# alias paloop='pactl load-module module-loopback'

# Apt
alias sau='sudo apt update && apt list --upgradable'

# Compilers
alias use_gcc='CC=gcc CXX=g++'
alias clang_build='CC=clang-15 CXX=clang++-15 LD=clang++-15'
alias clang_build_traced='CC="clang-15 -ftime-trace" CXX="clang++-15 -ftime-trace" LD=clang++-15'
alias clang_asan='CC="clang-15 -fsanitize=address" CXX="clang++-15 -fsanitize=address" LD=clang++-15'
alias gnu_asan='CC="gcc -fsanitize=address -ggdb" CXX="g++ -fsanitize=address -ggdb"'
alias alias_edit='vim ~/config/bash_aliases && alias_reload'
# alias alias_reload='source ~/config/bash_aliases'
alias alias_reload='source ~/.bash_aliases'
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
alias dcd='docker compose down'
alias dc='docker compose'
alias dp='docker ps --format "{{.Names}}"'
alias kaniko='docker run --rm -v$(pwd):/context:ro gcr.io/kaniko-project/executor:debug --context /context'
alias docker_killall='docker kill $(docker ps -q)'
doexec() {
    # Get the list of running containers and their IDs
    local container=$(docker ps --format "{{.Names}}" | fzf --height=40% --reverse --border --prompt="Select container: ")

    # If a container is selected, execute into it
    if [[ -n "$container" ]]; then
        docker exec -it "$container" bash
    else
        echo "No container selected."
    fi
}
doimages() {
  # Prompt for SSH device selection or manual input
  local ssh_device=$(cat ~/.ssh/config | grep -E "^Host " | awk '{print $2}' | fzf --height=10% --reverse --border --prompt="Select host or press Enter to input manually: ")
  if [[ -z "$ssh_device" ]]; then
    read -p "Enter SSH device: " ssh_device
  fi

  # Select Docker image
  local image=$(docker images --format "{{.Repository}}:{{.Tag}}" | fzf --height=40% --reverse --border --prompt="Select image: ")
  if [[ -n "$image" ]]; then
    docker save "$image" | pigz | pv | ssh "$ssh_device" "unpigz | docker load"
  else
    echo "No image selected."
  fi
}

dologs() {
    # Get the list of running containers and their IDs
    local container=$(docker ps -a --format "{{.Names}}" | fzf --height=40% --reverse --border --prompt="Select container: ")
    if [[ -n "$container" ]]; then
        docker logs -f "$container" 
    else
        echo "No container selected."
    fi
}
dostop() {
    # Get the list of running containers and their IDs
    # tab to select multiple containers
    local containers=$(docker ps --format "{{.Names}}" | fzf --height=40% --reverse --border --prompt="Select container: " --multi)
    if [[ -n "$containers" ]]; then
       docker stop $containers
    else
        echo "No container selected."
    fi
}
dorestart() {
    # Get the list of running containers and their IDs
    # tab to select multiple containers
    local containers=$(docker ps -a --format "{{.Names}}" | fzf --height=40% --reverse --border --prompt="Select container: " --multi)
    if [[ -n "$containers" ]]; then
      docker restart $containers
    else
        echo "No container selected."
    fi
}
alias docker-transfer='function _docker_transfer() { 
  images=$(docker images --format "{{.Repository}}:{{.Tag}}" | fzf --multi)
  for image in $images; do
    echo "Processing $image..."
    docker save "$image" | pigz | pv | ssh node@node-fms "unpigz | docker load"
  done
}; _docker_transfer'


# Workspaces
alias cdnav='cdws nav'
alias cdbmw='cdws bmwstr'
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

add_ros2_alias() {
	function colb {
		is_ros_workspace && colcon --log-base "${ROS_WORKSPACE}/log" build --mixin compile-commands ccache --base-paths "${ROS_WORKSPACE}" --cmake-args -DENABLE_SANITIZER_ADDRESS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=1 "-DCMAKE_CXX_FLAGS=-ggdb -fdiagnostics-color=always" --build-base "${ROS_WORKSPACE}/build" --install-base ${ROS_WORKSPACE}/install $@
	}
	alias colt='is_ros_workspace && colcon --log-base "${ROS_WORKSPACE}/log" test --base-paths "${ROS_WORKSPACE}" --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 "-DCMAKE_CXX_FLAGS=-ggdb -fdiagnostics-color=always" --build-base "${ROS_WORKSPACE}/build" --install-base "${ROS_WORKSPACE}/install"'
	alias colbthis='is_ros_workspace && colcon --log-base "${ROS_WORKSPACE}/log" build --mixin compile-commands ccache --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 "-DCMAKE_CXX_FLAGS=-ggdb -fdiagnostics-color=always" --build-base "${ROS_WORKSPACE}/build" --install-base "${ROS_WORKSPACE}/install"'
	alias coltr='is_ros_workspace && colcon --log-base "${ROS_WORKSPACE}/log" test-result --test-result-base "${ROS_WORKSPACE}/build" --verbose'
	alias colrelbuild='is_ros_workspace && colcon --log-base "${ROS_WORKSPACE}/log" build --mixin compile-commands ccache --base-paths "${ROS_WORKSPACE}" --cmake-args --DCMAKE_EXPORT_COMPILE_COMMANDS=1 DCMAKE_BUILD_TYPE=Release -DSANITIZE=OFF -DBUILD_TESTING=OFF -DCMAKE_CXX_FLAGS=-ggdb --build-base "${ROS_WORKSPACE}/build" --install-base "${ROS_WORKSPACE}/install"'

	single_ros2test() {
		if [ $# -lt 2 ]; then
			echo "Need a package name and test name"
			return;
		fi
		is_ros_workspace || return
		function rostest_in_base {
			# suppress cmake stuff
			colb --packages-up-to "${1}" --symlink-install --cmake-target-skip-unavailable --cmake-target "${2}" > /dev/null || return
			local test_executable
			test_executable=$(find "${ROS_WORKSPACE}/build/${1}" -type f -iname "${2}") || return
			# echo ${test_executable}
			[ -x "${test_executable}" ] || return 1
			${test_executable}
		}
		rostest_in_base "${1}" "${2}"
	}

	single_ros2test_gdb() {
		if [ $# -lt 1 ]; then
			echo "Need a test name"
			return;
		fi
		is_ros_workspace || return
		local test_executable
		test_executable=$(find ${ROS_WORKSPACE}/build -type f -iname "${1}") || return
		gdb ${test_executable}
	}

	# Takes filename to unit test and rebuilds it without dependencies + runs it
	# Any extra arguments will be used as prefix for the test
	single_ros2test_from_file_fast() {
		test_executable=$1
		shift
		test_name=$(basename "${test_executable}")
		# Account for /test subfolder
		build_dir=$(dirname "$test_executable" | sed -e 's#/test$##')
		pkg_name=$(basename "$build_dir")
		#echo "Test executable: '${test_executable}', build dir: '${build_dir}', pkg name: '${pkg_name}'"
		colb --packages-select "${pkg_name}" --cmake-target "${test_name}" && $@ ${test_executable}
	}

	# Takes filename to unit test and rebuilds + runs it
	# Any extra arguments will be used as prefix for the test
	single_ros2test_from_file() {
		test_executable=$1
		shift
		test_name=$(basename "${test_executable}")
		# Account for /test subfolder
		build_dir=$(dirname "$test_executable" | sed -e 's#/test$##')
		pkg_name=$(basename "$build_dir")
		colb --packages-up-to "${pkg_name}" > /dev/null && $@ ${test_executable}
	}

	single_ros2test_from_source_file() {
		is_ros_workspace || return
		exe=$(basename $1 .cpp)
		test_executable=$(find ${ROS_WORKSPACE}/build -type f -iname "${exe}") || return
		single_ros2test_from_file_fast "$test_executable"
	}

	r2t() {
		is_ros_workspace || return
		local test_executable
		test_executable=$(fd -t x '_test$' "${ROS_WORKSPACE}/build" | fzf) || return
		single_ros2test_from_file "$test_executable" $@
	}

	release_ros2_pkg() {
		if [ $# -lt 1 ]; then
			echo "Need a pkg name"
			return
		fi
		is_ros_workspace || return

		tmpdir=$(mktemp -d)
		colcon --log-base "${tmpdir}/log" build --base-paths "${ROS_WORKSPACE}" --executor parallel --merge-install --install-base "${tmpdir}/install" --build-base "${tmpdir}/build" --ament-cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF --packages-up-to $@
		echo -e "- Install ROS ${ROS_DISTRO}\n- Install dependencies \`rosdep install --ignore-src --from-path install/share\`\n- Source the workspace \`source install/setup.bash\`" > "${tmpdir}/SETUP.md"
		tar -czf "/tmp/${1}_$(date --iso-8601).tar.gz" -C "${tmpdir}" SETUP.md install
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

function ffmpeg_x {
  if [ $# -ne 3 ]; then
    echo "Usage: ffmpeg_x in out speed_up_factor"
    return;
  fi;
  # Get the total duration of the video in seconds using ffprobe
  DURATION=$(ffprobe -i $1 -show_entries format=duration -v quiet -of csv="p=0")
  echo "duration: ${DURATION}"

  # Calculate half the duration
  LEFT_DURATION=$(echo "$DURATION / $3" | bc -l)
  

  # Run the ffmpeg command to speed up the video by 2x and trim to half the duration
  ffmpeg -i $1 -vf "setpts=(1/$3)*PTS" -af "atempo=$3" -to "$LEFT_DURATION" $2
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

function sros2 {
  local ROS_ROOT
  [ -d "/opt/ros/iron" ] && . /opt/ros/iron/setup.bash
  [ -e /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]\
    && . /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
  [ -e /usr/share/colcon_cd/function/colcon_cd.sh ]\
    && . /usr/share/colcon_cd/function/colcon_cd.sh
}

# function rsource {
#   local ROS_ROOT
#   [ -d "/opt/ros/iron" ] && ROS_ROOT="/opt/ros/iron/setup.bash"
#   # ROS2 things
#   [ -e /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]\
#     && . /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
#   [ -e /usr/share/colcon_cd/function/colcon_cd.sh ]\
#     && . /usr/share/colcon_cd/function/colcon_cd.sh
# 	local WS_ROOT="git"
# 	local ws
#   ws=$(pwd | grep -o -e "^/home/${USER}/${WS_ROOT}/[^\/]\+")
# 	if [ -z "$ws" ]; then
# 		echo "Not inside a workspace, sourcing from ${ROS_ROOT}";
# 		source "${ROS_ROOT}"
# 		return 0;
# 	fi
#   for cs in "install" "devel"; do
#     local path="${ws}/${cs}/setup.bash"
#     if [ -e "${path}" ]; then
#       echo "Sourcing workspace in ${path}";
#       source "${path}";
#       return 0;
#     fi
#   done
#   echo "Devel space not found";
#   return 2;
# }

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
    if [ -e "${workspace}/.built_by" ]; then
			add_ros2_alias
			sros2
		else
			add_ros_alias
			rsource
		fi
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
  fzf -dmenu --height=40% --reverse --border --prompt="$1"
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
  rosnode list |  prompted_dmenu "Select ROS Node: " | xargs -r "${@:1}"
}

function rni {
  with_rosnode rosnode info
}

function with_rostopic {
  rostopic list | prompted_dmenu "Select ROS Topic: " | xargs -r "${@:1}"
}

function rte {
  with_rostopic rostopic echo "$@"
}

function rti {
  with_rostopic rostopic info "$@"
}

function exportrosmaster {
  local wifi_dev="wlp3s0"
  local lan_dev="wlp3s0"

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
  local wifi_dev="wlp3s0"
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
ottobo-s8 10.66.77.28 wifi
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

# Transferring GPG keys
# gpg --export-secret-key KeyId | ssh user@remote gpg --allow-secret-key-import --import
# gpg --export KeyId | ssh user@remote gpg --import

# Keep ros1 on localhost
export ROS_MASTER_URI=http://localhost:11311
# Keep ros2 on localhost
# export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET
# export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

#  personal alias
alias s_lmi='sros2 && source ~/node/logistics_manager_ws/install/setup.sh'
alias s_nav='sros2 && source ~/node/navigation_ws/install/setup.sh'
alias s_fms='source ~/node/venvs/fms_venv/bin/activate && pip install --upgrade fms_python_tools'
alias s_node_edge='source ~/node/venvs/node_edge_venv/bin/activate && pip install --upgrade node-edge-provisioning'
alias jiq='~/ws/jiq/jiq_linux_amd64'
alias copy='xclip -sel clip'
