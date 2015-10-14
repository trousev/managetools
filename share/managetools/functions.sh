#!/bin/sh
managetools_functions_prefixes="/etc/managetools `dirname $0`/../etc/managetools $HOME/.config/managetools"
managetools_functions_configs="managetools.conf `basename $0`.conf"

debug() {
    if [ $MANAGETOOLS_DEBUG = 1 ]; then
        echo "[DEBUG] $@" 1>&2
    fi
}
notice() {
    echo "[NOTICE] $@" 1>&2
}
error() {
    echo "[ERROR] $@" 1>&2
}
substring() {
    string=`echo $1 | awk  "{ string=substr(\\$0, $2, $3); print string; }" `
    echo $string
}
getconf () {
    eval managetools_temp_output=\$$1
    if [ -z "$managetools_temp_output" ]; then
        error "Required variable: $1 is not set. Please set it in configuration file."
        error "Configuration files are searched in: $managetools_functions_prefixes"
        error "Configuration files should have names: $managetools_functions_configs"
        error "You can also specify missing variable with --$1 <value> command"
        return 1
    fi
    echo $managetools_temp_output
}
getbinary () {
    for version  in $*; do
        interpreter=`which $version` || true
        if [ -z "$interpreter" ]; then
            debug "Binary not found: $version. Will continue search."
        else
            debug "binary found: $1=>$interpreter"
            echo $interpreter
            return 0
        fi
    done
    error "Binary not found: $1"
    error "Please, install corresponding package(s) into Your system."
    return 1
}

# Usage: <actual version> <minimum version>
checkversion () {
    PRINTF=`getbinary printf`
    SORT=`getbinary sort`
    HEAD=`getbinary head`
    if [ `$PRINTF "$1\\n$2" | $SORT -V | $HEAD -n 1` = $1 ]; then
        error "Failed to verify $3 version. Current $2 is lower than $1"
        return 1
    fi
    return 0
}

# Usage: checkpackage <package name>
checkpackage () {
    DPKGQ=`getbinary dpkg-query`
    RESULT=0
    $DPKGQ -l "$1" 1> /dev/null 2> /dev/null || RESULT=1
    if [ $RESULT = 1 ]; then
        error "No such package: $1"
    fi
    return $RESULT
}
# Usage: installpackage <check query> <package name>
installpackage () {
    DPKGQ=`getbinary dpkg-query`
    APTGET=`getbinary apt-get`
    SUDO=`getbinary sudo` #TODO: need to make clever check

    INSTALLED=1
    $DPKGQ -l "$1" 1> /dev/null 2> /dev/null || INSTALLED=0
    if [ $INSTALLED = 0 ]; then
        $SUDO $APTGET -y install $2
    else
        notice "Skipping $2, because $1 is installed."
    fi
    checkpackage $1
}

## Enviroment initialisation below
MANAGETOOLS_DEBUG=0
    for prefix in $managetools_functions_prefixes; do
        for config in $managetools_functions_configs; do
            if [ -f "$prefix/$config" ]; then
                . $prefix/$config
                debug "loaded config file: $prefix/$config"
            fi
        done
    done

    while [ true ]; do
        case "$1" in
            --*)
                varname=`substring $1 3 99`
                shift
                varvalue=$1
                if [ -z "$varvalue" ]; then
                    varvalue=true
                elif [ "`substring $varvalue 1 2`" = "--" ]; then
                    varvalue=true
                else
                    shift
                fi
                eval $varname=$varvalue
                debug "Variable defined from command line: $varname=>$varvalue"
            ;;
            *)
                break
        esac
    done
    return 0

