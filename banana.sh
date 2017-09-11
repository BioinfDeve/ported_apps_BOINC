#!/bin/bash -l
#@ environment = $FILE;$EXEC


resolve_file()
{
    LOGICAL_NAME=$1
    RESOLVED=`boinc resolve_filename "${LOGICAL_NAME}"`
    if [ $? -ne 0 ]; then
        echo "Could not resolve file: ${LOGICAL_NAME}." 1>&2
        exit ${RESOLVE_ERROR}
    fi
    echo "${LOGICAL_NAME} has been resolved: $RESOLVED" 1>&2
}

resolve_input_file()
{
    resolve_file $1
    if [ ! -f ${RESOLVED} ]; then
        echo "File does not exist: ${LOGICAL_NAME}." 1>&2
        exit ${INPUT_FILE_MISSING_ERROR}
    fi
}
INPUT_SEQUENCE="fasta_input"  #defined in the input port
INPUTFILE=`boinc resolve_filename "${INPUT_SEQUENCE}"`
echo ${INPUTFILE} 1>&2; #for testing the name
i=0
awk  '{ 
i=NR%2;
j=NR;
if (i == 1) print $0 >> j"_banana"
if (i == 0) print $0 >> (j-1)"_banana"

}' < ${INPUTFILE}

EXECUTABLE_FILE="banana.exe"; #name of the executable

outp=`boinc resolve_filename "tabdelimited"`
echo $outp 1>&2
echo -e cpg_id"\t"banana_bend_structure"\t"banana_curve_structure > ${outp}
echo "entered while" 1>&2


for f in *"_banana"
do
 echo "Processing $f"

 cpg_id=`awk '{if (NR == 1) print $1}' < $f` ;  
 options="-auto Y -outfile "$f".profile -sequence "$f" -graph null";  
 
 echo $EXECUTABLE_FILE " " $options > start.bat
 ./start.bat
 #Base   Bend      Curve
 #T       0.0      0.0
 bend=`awk 'BEGIN{bend=0}{if(NR >1) bend=bend+$2} END{print bend/(NR-1)}' < $f".profile"`
 curve=`awk 'BEGIN{curve=0}{if(NR >1) curve=curve+$3} END{print curve/(NR-1)}' < $f".profile"`

 echo $cpg_id 1>&2
 
 echo -e $cpg_id"\t"$bend"\t"$curve >> ${outp} 
done
boinc finish 0
