#rm *.jpeg
#rm *.mp4
#rm -rf text
#mkdir text
mkdir $(date +%d-%m-%Y)
fol=$(date +%d-%m-%Y)
mkdir $fol/text
rm $fol/*.jpeg
rm $fol/*.mp4
rm msgstore*
cp /data_mirror/data_ce/null/10/com.whatsapp/databases/msgstore.db .
sqlite3 msgstore.db -cmd ".headers off" "select _id from message where chat_row_id = 67;" > "$fol/text/id.txt"
sqlite3 msgstore.db -cmd ".headers off" "select text_data from message where chat_row_id = 67;" > "$fol/text/text.txt"
#sqlite3 msgstore.db -cmd ".headers off" "select sender_jid_row_id from message where chat_row_id = 67;" > "$fol/text/jid.txt"
COUNT=1
# GETTING HOW MANY LINES IN URL FILE
STOP=$(wc -l "$fol/text/id.txt" | awk '{ print $1 }')
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
curl -O $url

fn=$(echo $url | sed 's:.*/::')

echo "$COUNT downloading"
#echo $tt
echo $pno--$text
./whatsapp-media-decrypt -o "$fol/$COUNT)$pno($text)$ff" -t $tt ./$fn $hex

#./whatsapp-media-decrypt -o "$fol/$COUNT)$pno$ff" -t $tt ./$fn $hex
COUNT=$(($COUNT+1))
done
echo "all done"
rm *.enc
