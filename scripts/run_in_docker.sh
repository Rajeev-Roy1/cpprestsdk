#!/bin/bash

#!/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
    	-i|--image)
			image="$2"
        	shift
            shift
            ;;
		*)
			shift
			;;
    esac
done

#SVN_REVISION=$(svnversion -n)
#SVN_URL=$(svn info --show-item url)

#echo "$SVN_REVISION"
#echo "$SVN_URL"

#docker run -it --rm --network=host -v .:/root/code -w /root/code -e SVN_REVISION=$SVN_REVISION -e SVN_URL=$SVN_URL $image /bin/bash
docker run -it --rm --network=host -v .:/root/code -w /root/code $image /bin/bash

