#!/bin/bash
#Student name: Xiaolei Hu
#Student ID: 10485617

ECU_web="https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=ml-2018-campus" #variable ECU address for grep html source code as ARRAY
unit="KB…." # kb unit for file size metric
filetotal=0 # initial totalsize metric
RED='\033[00;31m'                      ##########################
YELLOW='\033[00;33m'                   #                        #
BLUE='\033[00;34m'                    # Use for color output text #
GREEN='\033[00;32m'                    #                        #
NCOL='\033[0m'                         ##########################                       

menu () {
        cd $dir # enter specify directory
        echo -e "${GREEN}You are in directory $dir now..${NCOL}"
        echo -e "${BLUE}Please wait, the system is loading...${NCOL}"
        wget -q "$ECU_web" -O - |grep img | cut -d\" -f4 > wget.txt # wget html source from ecuweb site to local as text file
        values=($(<wget.txt)) # generate text file named wget for calling by function
    while true; do    # call while true to loop the menu selction
        echo -e "${GREEN}1) Download a specific thumbnail, i.e. 0231 (by the last 4 digits of the file name):${NCOL} "
        echo -e "${GREEN}2) Download images in a range:${NCOL} "
        echo -e "${GREEN}3) Download a specified number of images, input numerical to download images:${NCOL} "
        echo -e "${GREEN}4) Download ALL thumbnails:${NCOL} "
        echo -e "${GREEN}5) Clean up ALL files:${NCOL} "
        echo -e "${GREEN}6) Exit Program:${NCOL} "
        read -p "Please select valid code: " selopt # user choose relative option
    
        if ! [[ $selopt =~ ^[1-9]$ ]]; then # if statment to restrict only numbers is valid
            echo -e "${RED}Please select valid number code!!!!!!${NCOL} " # if user input non numeric, the menu will loop
        else
            case $selopt in # if user input is right, go to further option by calling case in function
                1) read -p "Please enter last 4 digits of imagine: " digits
                    specific $digits ;; # calling specific function
                2) read -p "Please input first imagine number(last 4 digits): " digits1
                   read -p "Please input last imagine number(last 4 digits): " digits2
                    rancp $digits1 $digits2 ;; # calling rancp funcion
                3) read -p "Please input random number for downloading randomly imagines: " digits
                    if ! [[ $digits =~ ^[1-9][0-9]*$ ]]; then
                        echo "your input is invalid"
                    else
                        read -p "Please input first imagine number(last 4 digits): " digits1
                        read -p "Please input last imagine number(last 4 digits): " digits2
                        
                    fi
                    random $digits ;; # calling random function
                4) echo -e "${RED}Download All thumbnails:${NCOL} "
                    allpics ;; # calling allpics function
                5) echo -e "${RED}files are waiting to be deleted....${NCOL}"
                    clean ;; # calling clean function
                *) echo -e "${RED}The program is terminated${NCOL}" && exit 1;; # existing the code.
            esac
        fi
    done
}
#menu function will be called when the directory has been created for user interface to select relative option

cal () {
        file=$(du -b $line.jpg | awk '{adj=$1/1024; printf "%.2f\n", adj}') # calling du and awk to calculate and size metric
        total=((file++))
        echo -e "${YELLOW}Downloading $line, with the file name $line.jpg, with a file size of $file $unit File Download Complete${NCOL}" # out put the metric
}
# cal function use for calculate the size metric and output to the screen

specific () {
    echo -e "Please wait, the image(s) are downloading...."
    if ! [[ $digits =~ [0][2-6][0-7][0-9]$ ]];then # use if statement to restric user input

        echo -e "${YELLOW}Your image does not exsit, please try again!!!!!!!!${NCOL}" # output information that the digits not match

    else
            for line in $(cat wget.txt); do # loop specific from wget text file
                if [[ $line = DSC0$digits ]]; then # if user input matches the value where looped in text file, then execute wget to download the image
                wget -c -q "https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$line.jpg" # download image by wget
                cal $line # calling cal function to output result
                else
                    echo -e "${YELLOW}Your image does not exsit, please try again!!!!!!!!${NCOL}"
                fi
            done
        echo -e "${YELLOW}total size of all files donwloaded is $filetotal $unit${NCOL}" # output total size
    fi
}
# specific function use for download image by input last 4 digits

rancp () {
    echo -e "${YELLOW}Please wait, the image(s) are downloading....${NCOL}" # output the status of downloading
    first_dig=DSC0$digits1 # set first variable by input digit
    last_dig=DSC0$digits2 # set second variable by input digit
    rg="$first_dig.*$last_dig" #set the range between first variable and second variable
    [[ "${values[@]}" =~ $rg ]] #makeup new array and output new range
    [[ "${values[@]}" =~ ${first_dig:-FAIL} ]] || icorr+=("Image $first_dig is not exist") # determine if the first input is wrong
    [[ "${values[@]}" =~ ${last_dig:-FAIL}  ]] || icorr+=("Image $last_dig is not exist") # determine if second input is wrong
    [[ "${values[@]}" =~ $first_dig.*$last_dig  ]] || printf "${icorr[@]}" # output if the input number is wrong for fist or last
    for line in $BASH_REMATCH # loop in new array
    do
        wget -c -q "https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$line.jpg" # download images by user selection
        cal $line # calling cal function to output result
    done
        echo -e "${YELLOW}total size of all files donwloaded is $filetotal $unit${NCOL}"
}
# rancp function use for download image by the range which be specifc from user input

random () {
        echo -e "Please wait, the image(s) are downloading...." # output the status of downloading

        first_dig=DSC0$digits1 # set first variable by input digit
        last_dig=DSC0$digits2 # set second variable by input digit
        rg="$first_dig.*$last_dig" #set the range between first variable and second variable
        [[ "${values[@]}" =~ $rg ]] && echo $BASH_REMATCH > random_array1.txt #call BASH_REMATCH to makeup new array and output new range
        [[ "${values[@]}" =~ ${first_dig:-FAIL} ]] || icorr+=("Image $first_dig is not exist") # determine if the first input is wrong
        [[ "${values[@]}" =~ ${last_dig:-FAIL}  ]] || icorr+=("Image $last_dig is not exist") # determine if second input is wrong
        [[ "${values[@]}" =~ $first_dig.*$last_dig  ]] || printf "${icorr[@]}" # output if the input number is wrong for fist or last
        tr -s '[:blank:]' '\n' < random_array1.txt > random_array.txt
        r_values=($(<random_array.txt)) # set new arry
    for ((i=1;i<=$digits;i++)); do # use C-style function to loop
        arry_r=${#r_values[@]} # to call the array 
        arry_i=$(($RANDOM % $arry_r)) # all the RANDOM function for select random images from array
        local line=${r_values[$arry_i]} # declare local variable, calling new variable in wget 
        wget -c -q "https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$line.jpg" # download images
        cal $line # calling cal function to output result
    done
        echo -e "${YELLOW}total size of all files donwloaded is $total $unit${NCOL}" # 
}
# random function is to select random numbers by user for downloading random numbers of images

allpics () {
    echo -e "${YELLOW}Please wait, the image(s) are downloading....${NCOL}" # output the status of downloading
    cat wget.txt | while read line # use while read text and loop by calling cat wget text file
    do
        wget -c -q "https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$line.jpg" # download all images
        cal $line # calling cal function to output result 
    done
        echo "total size of all files donwloaded is $filetotal $unit"
}
# alpics function is for downloading all images

clean () {
    cd ~ # to quite the specify folder
    rm -r $dir # forcely delete all files by user creation 
    echo -e "${RED}All files have been deleted!${NCOL}" # output the status 
}
#clean function use for deleting all files and folders once your select

while true; do
    read -p "Please enter directory to access: " dir # prompt user to enter directory
    if ! [[ -d $dir ]]; then # if statement to determine if directory exists or not
        read -p "Directory $dir no exists, do you need to create one? (y/n) " reply # to create new folder
        if [[ "$reply" =~ [yY](es)* ]]; then # calling $reoly for new creation
            echo -e "${BLUE}The directory $dir has been created.${NCOL}" # output status of folder creation
            mkdir -p $dir # create directory
            menu $dir # calling menu function by $dir
        else
            echo -e "${BLUE}You are unable to access system without creating specify folder! Bye${NCOL}" # output if user dont want to create folder
        fi
    else
        menu $dir # calling menu function again if the dirctory exists
    fi
done

exit 0 # exiting program code