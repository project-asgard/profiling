while getopts "a:b:" opt ; do

    case "${opt}" in

        a)

            pattern="${OPTARG}"

            ;;
    
        b)

            rename="${OPTARG}"

            ;;

        *)
            echo usage: -a \<regex to match\> -b \<filename to rename match to\>

            exit 1

            ;;

    esac

done

if [ -z "${pattern}" ] || [ -z "${rename}" ] ; then

    echo usage: -a \<regex to match\> -b \<filename to rename match to\>

    exit 1
fi

for file_name in * ; do

    if [[ "${file_name}" =~ "${pattern}" ]] ; then

        mv "${file_name}" "${rename}"

    fi

done
