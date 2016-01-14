#!/bin/sh
progname=`basename $0`
version=1.0
date=2016-01-14

usage()
{
  cat >&2 <<HELP
usage: $progname <subcommand> [options] [args]
svn / git submit analysis, ver $version
writen by luwei<strongerlu@gmail.com> 2016-01-14

valid commends are
help: $progname help
  show this help information
rank: $progname rank [options] <repository>
  print developer's submit rank 
getline: $progname release [options] [working directory]
  print debeloper's all lines of submits

HELP
}

args()
{
  while getopts d:s:u:m OPTION "$@"; do
    case $OPTION in
    d)
      dir=${OPTARG}
      ;;
    s)
      repo=${OPTARG}
      ;;
    u)
      name=${OPTARG}
      ;;
    "?")
      echo "Unknown option $OPTARG"
      ;;
    esac
  done
}
checkfile(){
    if [ "x$dir" == "x" ]
        then
            echo 'The svn log file needed. such as -d /tmp.svn.log'>&2
        exit 1
    fi
    if [ ! -e "${dir}" ]; then
        echo 'The svn log file is not exists.' >&2
        exit 1
    fi
}
#example
#sh repostat.sh rank -d /tmp/svn.log
rank(){
    args $@
    shift $((OPTIND - 1))
    checkfile 
    echo 'The submit rank as follow:' >&2
    cat $dir | awk -F '|' '{print $2}' | sed '/^$/d' | sort | uniq -c | sort -rn >&2
}
#example:
#sh repostat.sh getline -u tangjun -d /tmp/svn.log -s http://xxxx.1verge.net/svn/xxxx
getline(){
    args $@
    shift $((OPTIND - 1))
    if [ "x$name" == "x" ]
        then
            echo "Please input the developer's svn username parameter.such as: -u luwei" >&2
            exit 1
        fi
        if [ "x$repo" == "x" ]
           then
               echo "Please input the  svn repo.such as: -s http://xxx.com/svn/xxxx" >&2
           exit 1
        fi

        checkfile 
        echo "scaning ${name}'s submits..."
        local versionfile=$(dirname $dir)/.${name}.ver
        local countfile=$(dirname $dir)/.${name}.count
        cat $dir | grep ${name} | awk -F '|' '{print $1}' | awk -F 'r' '{print $2}' > $versionfile
        [ -d $countfile ] && exit 1
        if [ -e $countfile ] && [ -f $countfile ]; then
            rm -f $countfile 2>&1 > /dev/null
        fi 
        local i=0
        cat $versionfile | while read line
        do
            let i+=1
            let ver=line-1
            svn diff -r${line}:${ver} $repo | awk '/^+/' | wc -l >> $countfile
            echo "scaning ${name}'s $i submit..."
        done

        echo "${name} commit"
        awk '{sum+=$1} END {print sum}' $countfile
        echo "lines of code！"
}

verbose()
{
  if [ "x$slient" == "x" ]
  then
    echo $@
    "$@"
  else
    "$@" 2>/dev/null
  fi

  if [ "x$?" != "x0" ]
  then
    echo "Error exit status: $@"
    exit
  fi
}

init()
{
  "$@"
}

########## end ##############
if [[ $1 =~ ^(|rank|getline)$ ]]
then
  init "$@"
else
  echo "Invalid subcommand $1" >&2
  usage
  exit 1
fi
exit 0
