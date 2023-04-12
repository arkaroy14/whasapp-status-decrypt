yr=$(date +"%Y")
mnt=$(date +"%B")
fol=$(date +%d-%m-%Y)

mkdir -p $yr/$mnt/$fol/text
rm $yr/$mnt/$fol/*.jpeg
rm $yr/$mnt/$fol/*.mp4
rm msgstore*
# NEED ROOTED PHONE AND FIND WHATSAPP DATABASE PATH LIKE BELOW AND REPLACE BELOW LINE (user 0 for main profile 10 for work space(Ex: ISLAND FOR WORK PROFILE)
cp /data/user/10/com.whatsapp/databases/msgstore.db .

# BELOW "chat_row_id = 67" IS WHERE MY WHATSAPP STATUS THERE CHECK AND CONFIRM THAT ID BY OPENING YOUR DATABASE. IF THAT ID IS DIFFRENT REPLACE "67"

sqlite3 msgstore.db -cmd ".headers off" "select _id from message where chat_row_id = 67;" > "$yr/$mnt/$fol/text/id.txt"
sqlite3 msgstore.db -cmd ".headers off" "select text_data from message where chat_row_id = 67;" > "$yr/$mnt/$fol/text/text.txt"
#sqlite3 msgstore.db -cmd ".headers off" "select sender_jid_row_id from message where chat_row_id = 67;" > "$fol/text/jid.txt"


COUNT=1
# GETTING HOW MANY LINES IN URL FILE
STOP=$(wc -l "$yr/$mnt/$fol/text/id.txt" | awk '{ print $1 }')
#STOP=1
while [ $COUNT -le $STOP ]
do
id=$(sed "$COUNT!d" "$fol/text/id.txt")
echo "Making $COUNT text"
url=$(sqlite3 msgstore.db -cmd ".headers off" "select message_url from message_media where message_row_id = $id;")

type=$(sqlite3 msgstore.db -cmd ".headers off" "select mime_type from message_media where message_row_id = $id;")

hex=$(sqlite3 msgstore.db -cmd ".headers off" "select hex(media_key) from message_media where message_row_id = $id;")

jid=$(sqlite3 msgstore.db -cmd ".headers off" "select sender_jid_row_id from message where _id = $id;")

text=$(sqlite3 msgstore.db -cmd ".headers off" "select text_data from message where _id = $id;")

pno=$(sqlite3 msgstore.db -cmd ".headers off" "select user from jid where _id = $jid;")

if [ "$type" = "video/mp4" ]
then
tt=2
ff=".mp4"
else
tt=1
ff=".jpeg"
fi
text=$(echo $text | sed 's/\//\ or /g;s/"//g')

# BELOW FORMATTING TEXT TO ONLY TAKE 248 CHARACTERS FROM FILE NAME BECAUSE LINUX ONLY SUPPORT 255 CHARACTERS IN FILENAME INCLUDING EXTENSION SO WE ONLY TAKING 248 FROM STATUS TEXT IN OUR FILENAME 
stxt=$(echo $text | head -c 248)

curl -O $url

fn=$(echo $url | sed 's:.*/::;s/\?.*//') #fix fn having ? symbol

echo "$COUNT downloading"

echo $pno--$text

# BUILD "whatsapp-media-decrypt" FROM "https://github.com/ddz/whatsapp-media-decrypt"

./whatsapp-media-decrypt -o "$yr/$mnt/$fol/$COUNT)$pno($stxt)$ff" -t $tt ./$fn $hex

COUNT=$(($COUNT+1))
done
echo "all done"
rm *.enc
