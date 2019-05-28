# Authorization

echo $1"dsasd"

AUTH="f015a8410296a14427a739561c93b88a9b0b825c42804c0c4b992fff9ce0859e"

FOLDER="android/$(date +%s)"

mkdir -p $FOLDER

FILE_PATH="$FOLDER/Reporte.pdf"

URL_API="http://localhost:8000"

PROYECT_NAME="fastlane-demo"

FILE_NAME="app-debug.apk"

HTTP_BODY=""

HASH=""

SCAN_TYPE=""

TIMESTAMP=$(date +%s)

# -----------------------------------------------------------------------------------------------------------------------------

echo 
echo "------------------------------ UPLOAD FILE ------------------------------"
echo 

HTTP_STATUS=0; while [ $HTTP_STATUS -ne 200 ]; do
# store the whole response with the status at the and
HTTP_RESPONSE=$(curl --progress-bar -v --write-out "HTTPSTATUS:%{http_code}" -F 'file=@/Users/Shared/Jenkins/Home/workspace/fastlane-demo/app/build/outputs/apk/debug/app-debug.apk' $URL_API/api/v1/upload -H "Authorization:$AUTH")

# extract the body
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
echo $HTTP_BODY 

HASH=`echo $HTTP_BODY | python -c "import sys, json; print json.load(sys.stdin)['hash']"`

SCAN_TYPE=`echo $HTTP_BODY | python -c "import sys, json; print json.load(sys.stdin)['scan_type']"`

# extract the status
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

done

# -----------------------------------------------------------------------------------------------------------------------------

echo 
echo "------------------------------ SCAN FILE ------------------------------"
echo 

HTTP_STATU_SCAN=0; while [ $HTTP_STATU_SCAN -ne 200 ]; do
# store the whole response with the status at the and
HTTP_RESPONSE=$(curl --progress-bar -v --write-out "HTTPSTATUS:%{http_code}" POST --url http://localhost:8000/api/v1/scan --data "scan_type=$SCAN_TYPE&file_name=$FILE_NAME&hash=$HASH&re_scan=1" -H "Authorization:$AUTH")

# extract the status
HTTP_STATU_SCAN=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

done

# -----------------------------------------------------------------------------------------------------------------------------

echo 
echo "------------------------------ DOWNLOAD REPORT FILE ------------------------------"
echo 

HTTP_STATU_DOWNLOAD=0; while [ $HTTP_STATU_DOWNLOAD -ne 200 ]; do

sleep 60
# store the whole response with the status at the and
HTTP_RESPONSE=$(curl --progress-bar -v --write-out "HTTPSTATUS:%{http_code}" -v -o $FILE_PATH  -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$HASH&scan_type=$SCAN_TYPE" -H "Authorization:$AUTH")

# extract the status
HTTP_STATU_DOWNLOAD=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

done

echo
echo "------------------------------ FINISH DOWNLOAD ------------------------------"
echo "$FILE_PATH"

#curl -v -o $TIMESTAMP.pdf  -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$HASH&scan_type=$SCAN_TYPE" -H "Authorization:f015a8410296a14427a739561c93b88a9b0b825c42804c0c4b992fff9ce0859e"
