rm *.jpeg
rm *.mp4
rm -rf text
mkdir text
rm msgstore*
cp /data_mirror/data_ce/null/10/com.whatsapp/databases/msgstore.db .
sqlite3 msgstore.db -cmd ".headers off" "select _id from message where chat_row_id = 67;" > 'text/id.txt'
sqlite3 msgstore.db -cmd ".headers off" "select text_data from message where chat_row_id = 67;" > 'text/text.txt'
sqlite3 msgstore.db -cmd ".headers off" "select sender_jid_row_id from message where chat_row_id = 67;" > 'text/jid.txt'
#sed -i 's/@s.whatsapp.net//g' 'text/text.txt'
COUNT=1
# GETTING HOW MANY LINES IN URL FILE
STOP=$(wc -l 'text/id.txt' | awk '{ print $1 }')
#STOP=1
while [ $COUNT -le $STOP ]
do
id=$(sed "$COUNT!d" 'text/id.txt')
echo "Making $COUNT text"
sqlite3 msgstore.db -cmd ".headers off" "select message_url from message_media where message_row_id = $id;" >> 'text/url.txt'

sqlite3 msgstore.db -cmd ".headers off" "select mime_type from message_media where message_row_id = $id;" >> 'text/type.txt'

sqlite3 msgstore.db -cmd ".headers off" "select hex(media_key) from message_media where message_row_id = $id;" >> 'text/hex.txt'

url=$(sed "$COUNT!d" 'text/url.txt')
type=$(sed "$COUNT!d" 'text/type.txt')
hex=$(sed "$COUNT!d" 'text/hex.txt')
text=$(sed "$COUNT!d" 'text/text.txt')
jid=$(sed "$COUNT!d" 'text/jid.txt')

pno=$(sqlite3 msgstore.db -cmd ".headers off" "select user from jid where _id = $jid;")
if [ -z "$url" ]
then
echo "null" >> 'text/url.txt'
echo "null" >> 'text/type.txt'
echo "null" >> 'text/hex.txt'
fi

if [ "$type" = "video/mp4" ]
then
tt=2
ff=".mp4"
else
tt=1
ff=".jpeg"
fi

curl -O $url

fn=$(echo $url | sed 's:.*/::')

echo "$COUNT downloading"
echo $tt
./whatsapp-media-decrypt -o "$COUNT)$pno($text)$ff" -t $tt ./$fn $hex

COUNT=$(($COUNT+1))
done
echo "all done"
rm *.enc
