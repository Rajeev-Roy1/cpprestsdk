#!/bin/bash
##
## Installs Dependencies to compile this project

function installRpm()
{
	deps=$1
	dnf install -y ${deps[@]}
}

function installDeb()
{
	echo "Calling Install Deb"
	#apt-get install -y dtacore
}

function installMakeself()
{
	echo "Install Makeself"
	#wget http://repo.dta.lan/repo/${arch}/packages
}

function installTar()
{
	arch=$1
	deps=$2
	if [[ "$arch" == "a53" ]]; then
		url="http://repo.dta.lan/repo/busybox/5/aarch64/packages/"
		rootfs_dir="$BUILDROOT/output/host/aarch64-buildroot-linux-gnu/sysroot/"
	elif [[ "$arch" == "a8" ]]; then
		url="http://repo.dta.lan/repo/busybox/4/armv7/packages/"
		rootfs_dir="$BUILDROOT/output/host/aarch64-buildroot-linux-gnu/sysroot/"
	fi 

	depsString=$(printf "%s," "${deps[@]}" | sed 's/,$/\n/') 
 	echo "$depsString" 
 	files=$(python3 scripts/get_files.py -u $url -n $depsString -e "tar")    

	for entry in $files
	do
		echo "$url$entry"
  		wget "$url$entry" 
		tar -xvf $entry -C $rootfs_dir --strip-components=1
  		rm $entry
	done
}

function installRpmViaWget()
{
	deps=$1
	url="http://repo.dta.lan/repo/yocto/5/aarch64/packages/"
	rootfs_dir="/opt/yocto-sdk/sysroots/armv8a-poky-linux/"

	depsString=$(printf "%s," "${deps[@]}" | sed 's/,$/\n/') 
 	echo "$depsString" 
	files=$(python3 scripts/get_files.py -u $url -n $depsString -e "rpm")

	for entry in $files
	do
		echo "HERE"
		echo "$url$entry"
  		wget "$url$entry" 
  		rpm2archive $entry
		tar -xvf $entry.tgz -C $rootfs_dir
  		rm $entry $entry.tgz
	done
}

arch="x86_64"
POSITIONAL_ARGS=()
doCrossCompile=0
while [[ $# -gt 0 ]]; do
    case "$1" in
    	-a|--architecture)
			arch="$2"
        	shift
            shift
            ;;
        -c|--cross_compile)
			doCrossComiple=1
			shift
			shift
			;;
		*)
			shift
			;;
    esac
done

# Initialize an empty array
declare -a deps
# Read lines from file into the array
mapfile -t deps < "dependencies.txt"
echo "DEPS: ${deps[@]}"
if [[ "$arch" == "x86_64" ]]; then
	ID_LIKE=$(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release | cut -d ' ' -f 1 | tr -d '\n' | tr -d '\"')

	if [[ "$ID_LIKE" == "rhel" ]]; then
		installRpm ${deps[@]}
	elif [[ "$ID_LIKE" == "debian" ]]; then
		installDeb $deps
	fi
elif [[ "$arch" == "imx8mp" ]]; then
	installRpmViaWget ${deps[@]}
else 
	installTar $arch ${deps[@]}
fi
