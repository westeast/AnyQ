#!/bin/bash
SCRIPT_PATH=$(dirname $0)
cd $SCRIPT_PATH/../build/

alias grep="/usr/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS
PROC_NAME=solr
ProcNumber=`ps -ef |grep -w $PROC_NAME|grep -v grep|wc -l`
if [ $ProcNumber -le 0 ];then
   echo "${PROC_NAME} is not run"
   ./solr/anyq_solr.sh ./solr/sample_docs ./solr-4.10.3-anyq/
else
   echo "${PROC_NAME} is  running.."
   bash ./solr/solr_deply.sh stop ./solr-4.10.3-anyq/ 8900
fi


./run_server
