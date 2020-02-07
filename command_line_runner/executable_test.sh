#Captain! Make the ${cwd} a parsable argument, and have it run here
#Keyword in config file to indicate that a run should now be made
run_keyword="run"

#Name of the file to store the command line string that generated the test results
invocation_file_keyword="command_line_string"

#Keyword in config file to indicate that what follows is the name of the executable to run
executable_keyword="executable"

#Keyword in config file. If this follows an option, it is to be left out of the command string
omit_option_keyword="-"

#Keyword in config file. Whatever follows is to be prepended to the command
prepend_keyword="prepend"

#Keyword in config file. Whatever follows is to appended to the command
append_keyword="append"

#Post action keyword
post_action_keyword="post_action"

#Which run
run_count=0

#directory
cwd_keyword="cwd"

function run_executable
{
    #change working directory to the location of the executable	
    pushd "${cwd}"

    #Open a file
    exec {command_file}> "${cwd}/${invocation_file_keyword}_${run_count}.txt"

    run_count=$((${run_count}+1))

    #Write command_str to the file
    echo "${command_str}" >&${command_file}

    #Close the file
    exec {command_file}>&-

    #Then eval the command below
    eval ${command_str}

    unset positionals

    popd
}

#Build a command line string from the params associative array.
function build_string
{
    #full path to the executable must be provided.
    string="${executable}"

    local post_action=""

    for key in "${!param[@]}" ; do

        option="${param["${key}"]}"

        if [[ "${option}" != "${omit_option_keyword}" ]] ; then

            if [[ "${key}" = "${prepend_keyword}" ]] ; then

                string="${option} ${string}"

            elif [[ "${key}" = "${post_action_keyword}" ]] ; then

                post_action="${option}"

            else

                #add option to the command_string
                string="${string} ${key} ${option}"
            fi
        fi

    done

    for item in "${positionals[@]}" ; do

        string="${string} ${item}"

    done

    if [[ -n "${post_action}" ]] ; then

        string="${string} ; ${post_action}" 

    fi

    echo "${string}"
}

#Parse a line from the config file. If it denotes a command line option, run it
#If it
function parse
{
    #key is the first word in the line
    key=${1}

    val=${2}

    #If the line specifies the executable
    if [[ ${key} = ${executable_keyword} ]] ; then

        #executable is the second word in the line
	#Captain! Is this just val?
        executable=${line#* }

    elif [[ ${key} = ${append_keyword} ]] ; then

        positionals+=("${val}")

    elif [[ ${key} = ${cwd_keyword} ]] ; then

	cwd="${val}"

    #If the line specifies a command line option
    else

        param["${key}"]="${val}"

    fi

    return
}

#Get "c" option (config file)
while getopts "c:" opt ; do

    case "${opt}" in

        c)

            input_file="${OPTARG}"

            break

            ;;

        *)
            echo usage: -c \<input_file_name\>

            exit 1

            ;;

    esac

done

if [[ -z "${input_file}" ]] ; then

    echo usage: -c \<input_file_name\>

    exit 1

fi

#Open the config file
exec {input}< ${input_file}

#read lines of the file into an array
declare -a lines

mapfile -t -u ${input} lines

#Close the config file
exec {input}<&-

#Associative array for parameters
declare -A param

declare -a positionals

#Loop through the array of lines.
for line in "${lines[@]}" ; do

    #skip empty lines
    if [[ -z ${line} ]] ; then

        continue

    fi

    #skip comment lines
    first_char=${line:0:1}

    if [[ ${first_char} = "#" ]] ; then

        continue

    fi

    #key is the first word in the line
    key=${line%% *}

    #val is everything after
    val="${line#${key}}"

    #remove leading white space
    val="${val#* }"

    #remove trailing white space
    val="${val%* }"

    #If the line specifies to run, do so
    if [[ ${key} = ${run_keyword} ]] ; then

        #build the command line string
        command_str=$(build_string)
                                                                             
        run_executable

    else

        #Send the line to a parser
        parse ${key} "${val}"

    fi

done
