#!/bin/bash

#Author: Het Patel : 110123875


# declration of directory paths
bk_dir="/mnt/c/Users/kingh/Desktop/ASP/Assignment4/backup" # main backup directory
cpt_bk_dir="$bk_dir/cb" # the directory for complete backup
ict_bk_dir="$bk_dir/ib" # directory for incremental backup
log_f="$bk_dir/backup.log" # path for log file


# chekcing whether the backup dir is present or not

if [ ! -d "$bk_dir" ]; then # if not present
    
    mkdir -p "$bk_dir"  # creating backup dir
    mkdir -p "$cpt_bk_dir" # creating complete backup dir
    mkdir -p "$ict_bk_dir" # creating incremental backup dir
    touch $log_f # creating log file

else # if  backup dir is present 

    if [ ! -d "$cpt_bk_dir" ]; then  # checking whether the complete backup dir is present or not
       # if not present
       mkdir -p "$cpt_bk_dir" # creating it
    fi

    if [ ! -d "$ict_bk_dir" ]; then # checking whether the incremental backup dir is present or not
      # if not present 
      mkdir -p "$ict_bk_dir" # creating it
    fi

    if [ ! -f "$log_f" ]; then # checking whether the log file is present or not
     
     # if not present 
     touch $log_f # creating it
    fi

fi # end of conditional statement

getdate(){ # function to get date and current timestamp using data command
    
    date # date command

}

# Function to get the timestamp in a densly packed manner
get_timestamp() {

    date  # date command its formatting 

}

last_timestamp=$0 # initializing var to store the last timestamp of update with program name

cnt=1 # defining a counter 

cpt_backup(){ # function to do complete backup

    #echo complete backup started    

    last_timestamp=$(getdate) # updating last timestamp var with current time
    timestamp_c=$(get_timestamp) # getting timestamp by calling the function 
  

    # creating a tarball of every .c and .txt files present in the specified root dir 
    tar -cf "$cpt_bk_dir/cb0000$cnt.tar" --files-from <(find /mnt/c/Users/kingh/Desktop -type f \( -name "*.c" -o -name "*.txt" \)) 

    
    #echo complete backup ended

    echo "$timestamp_c: cb0000$cnt.tar was created" >> "$log_f" # storing the backup file log in log file with timestamp
    echo cb0000$cnt.tar was created # printing out message 

    cnt=$(($cnt+1)) # incrementing the counter 
    #echo $cnt 
}


icnt=1 # defining a couter for incremental backup

ict_backup() { # function to do incremental backup

    #echo incremental backup started
    #echo $last_timestamp 
    timestamp_n=$(get_timestamp) # getting a timestamp for incremental backup
    last_backup=$(cat "$log_f" 2>/dev/null)

    chum_files=$(find /mnt/c/Users/kingh/Desktop -type f \( -name "*.c" -o -name "*.txt" \) -newermt "$last_timestamp") #finding the updated or added or modified files since last timestamp 
    #echo $chum_files
    if [ -n "$chum_files" ]; then # checking if there is any files updated or modified files

        # if the string is not null

        # creating a tarball of every updated and modified .c and .txt files present in the specified root dir
        tar -cf "$ict_bk_dir/ib1000$icnt.tar" $chum_files
        #tar -cf "$ict_bk_dir/ib000$icnt.tar" $chum_files
        # with timestamp mentioning the file name in log file
        echo "$timestamp_n: ib1000$icnt.tar was created" >> "$log_f"

        echo "ib1000$icnt.tar was created" # printing out the message
        
         icnt=$(($icnt+1)) # incremeting the counter
         #echo $icnt
    else
        #if no files is modified or updated  

        echo "$timestamp_n: No files are added or modified since the last backup --- Incremental backup was not created" >> "$log_f" # writing message into log file
        echo 'No files are added or modified since the last backup --- Incremental backup was not created'  # printing out the message
    
    fi

    last_timestamp=$(getdate) # updating the value of last timestamp variable
    #echo incremental backup ended
   
}


while [ true ]  # inifinite while loop

do
    
    # calling the function to do complete backup
    cpt_backup

    sleep 120 # pausing for 2 mins

    # calling the function to do 1st incremental backup
    ict_backup

    sleep 120 # pausing for 2 mins

     # calling the function to do incremental backup of 1st incremental backup
    ict_backup

    sleep 120 # pausing for 2 mins

     # calling the function to do incremental backup of 2nd incremental backup
    ict_backup
    
    sleep 120 # pausing for 2 mins

done & # to make loop run continuously in background


