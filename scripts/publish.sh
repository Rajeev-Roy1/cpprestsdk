#!/bin/bash

declare -a upload_files

if [ -f build/packages/debfilename ]; then
	DEB_FILENAME=$(head build/packages/debfilename)
fi

if [ -f build/packages/rpmfilename ]; then

	#Determine EL/YoctoDistro

	RPM_FILENAME=$(head "build/packages/rpmfilename")
	echo "$RPM_FILENAME"
	my_array=($(echo $RPM_FILENAME | tr "." "\n"))
	for i in "${my_array[@]}"
	do
	    if [[ "$i" == "el"* ]]; then
	    	repo="rocky"
	    	repo_version=$(echo "${i#el}")
	    	break
	    elif [[ "$i" == "yocto"* ]]; then
	    	repo="yocto"
	    	repo_version=$(echo "${i#yocto}")
	    	break
	    fi
	done

	echo "REPO: $repo REPO VERSION $repo_version"

	if [[ $repo == "" ]]; then
		echo "Invalid RPM filename: $RPM_FILENAME"
	fi

	url="http://repo.dta.lan/repo/$repo/$repo_version/api/upload/"
	upload_files+=$RPM_FILENAME
fi

if [ -f build/packages/makeselffilename ]; then
	
	MAKESELF_FILENAME=$(head "build/packages/makeselffilename")
	TAR_FILENAME=$(head "build/packages/tarfilename")
	echo "$RPM_FILENAME"
	my_array=($(echo $MAKESELF_FILENAME | tr "." "\n"))
	for i in "${my_array[@]}"
	do
		echo "$i...."
	    if [[ "$i" == "bb"* ]]; then
	    	repo="busybox"
	    	repo_version=$(echo "${i#bb}")
	    	break
	    fi
	done

	echo "REPO VERSION: $repo_version ${#repo_version}"
	if [[ "$repo_version" == "4" ]]; then
		arch="armv7"
	elif [[ "$repo_version" == "5" ]]; then
		arch="aarch64"
	fi

	echo "REPO: $repo REPO VERSION $repo_version ARCH $arch"	

	if [[ $repo == "" ]]; then
		echo "Invalid filename: $MAKESELF_FILENAME"
	fi

	url="http://repo.dta.lan/repo/$repo/$repo_version/api/upload/$arch/"
	upload_files+=($MAKESELF_FILENAME)
	upload_files+=($TAR_FILENAME)
fi

cd build/packages
for file in ${upload_files[@]}
do
   	echo "Uploading $file: $url$file"
	curl -T $file "$url$file"
done
