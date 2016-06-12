#!/bin/bash
##############################################################################################
# Info :  
# Author : Hong Lin 
# Date : 2016.06.06 
# This script run by root
##############################################################################################
#### "Usage: Parameters: 1.local-username 2.remote-username 3.remote-password 4.remote-host \n"

echo ">>> Start @ [`date`] <<<"

(( $# < 4 )) && {
    echo ">>> Input parameters: 1.local-username 2.remote-username 3.remote-password 4.remote-host @ [`date`] <<<"
    exit 1
}

(( $EUID != 0 )) && {
    echo ">>> [ERROR] You must be root to run this script. @ [`date`] <<<"
    exit 1
}

# Set variables 
localuser=$1
remoteuser=$2
remotepwd=$3
remotehost=$4

# Set local user's home directory 
HOMEDIR=/home

#echo $localuser
#echo $remoteuser
#echo $remotepwd
#echo $remotehost

# Set expect scirpt name 
#TMPEXP_SCRIPT=pwdless.exp
TMPEXP_SCRIPT=/usr/local/bin/pwdless.exp


### check localuser in  /etc/passwd
echo ">>> Checking if localuser in /etc/passwd.  @ [`date`] <<<"
grep "^$localuser:" /etc/passwd > /dev/null 2>&1
RESULT=$?
if (( RESULT == 1 )); then
    echo ">>> [ERROR] There is NOT $localuser user in /etc/passwd. @ [`date`] <<<"
    exit 1
fi

### check localuser ssh file in /home/localuser/.ssh/id_rsa
echo ">>> Checking for $localuser ssh key files in home directory.  @ [`date`] <<<"

SSH_KEYS_FOUND=0

if [[ -d $HOMEDIR/$localuser ]]; then
   if [[ -s $HOMEDIR/$localuser/.ssh/id_dsa && -s $HOMEDIR/$localuser/.ssh/id_rsa ]]; then
      #sudo -u $localuser -- /usr/bin/ssh-keygen -e -f $HOMEDIR/$localuser/.ssh/id_rsa |  grep "4096-bit RSA"  > /dev/null 2>&1
      sudo -u $localuser -- /usr/bin/ssh-keygen -e -f $HOMEDIR/$localuser/.ssh/id_rsa |  grep '4096-bit RSA'  > /dev/null 2>&1
#      su -u $localuser -c "/usr/bin/ssh-keygen -e -f $HOMEDIR/$localuser/.ssh/id_rsa |  grep '4096-bit RSA'  > /dev/null 2>&1"
      RESULT=$?
      if (( RESULT == 0 )); then
          SSH_KEYS_FOUND=1
      fi
   fi
fi

### create ssh file in /home/localuser/.ssh/id_rsa
if (( SSH_KEYS_FOUND == 1 )); then
   echo ">>> SSH Keyfile Found.  @ [`date`] <<<"
else
   echo ">>> SSH Keyfile Not Found.  @ [`date`] <<<"
   rm -Rf $HOMEDIR/$localuser/.ssh > /dev/null 2>&1
   #mkdir $HOMEDIR/$localuser/.ssh > /dev/null 2>&1
   #chmod 700 $HOMEDIR/$localuser/.ssh > /dev/null 2>&1
   #chown -R $localuser:$localuser $HOMEDIR/$localuser/.ssh > /dev/null 2>&1
   #sudo -u $localuser -- /usr/bin/ssh-keygen -q -t rsa -b 4096 -C "my_scp_passwordless" -N "" -f $HOMEDIR/$localuser/.ssh/id_rsa
   sudo -u $localuser -- /usr/bin/ssh-keygen -q -t rsa -b 4096 -C 'my_scp_passwordless' -N '' -f $HOMEDIR/$localuser/.ssh/id_rsa
   #su -u $localuser -c "/usr/bin/ssh-keygen -q -t rsa -b 4096 -C 'my_scp_passwordless' -N '' -f $HOMEDIR/$localuser/.ssh/id_rsa"
   echo ">>> New ssh key files generated (RSA protocol 4096bit) @ [`date`] <<<"
fi

### check localuser ssh file in /home/localuser/.ssh/id_rsa
echo ">>> Checking connection with remotehost.  @ [`date`] <<<"
/bin/ping -q -c 2 $remotehost > /dev/null 2>&1
RESULT=$?
if (( RESULT == 1 )); then
    echo;    echo ">>> [ERROR] - could not ping $host. @ [`date`] <<<"
    exit 1
fi

### copy authorized keyfile to remotehost by ssh-copy-id 

#TMPEXP=passwordless-expect.$$

##$HOMEDIR/$localuser $remoteuser $remotepwd $remotehost

$TMPEXP_SCRIPT $HOMEDIR/$localuser $remoteuser $remotepwd $remotehost

RESULT=$?

if (( RESULT == 0 )); then
   echo ">>>  $argv0 execution is Succeeded @ [`date`] <<<"
   echo ">>> End @ [`date`] <<<"
else
   echo ""
   echo ">>> $argv0 execution is Failed @ [`date`] <<<"
   echo ">>> Check the pwdless_exp.log. @ [`date`] <<<"
   exit 1
fi

echo ">>> Completed. Goodbye. @ [`date`] <<<"

exit 0

