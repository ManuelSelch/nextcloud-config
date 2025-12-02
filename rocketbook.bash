# !/bin/bash
TMP=/tmp/rocketbook
MAILDIR=/root/nextcloud/mails/INBOX/new
PROCESSEDDIR=/root/nextcloud/mails/Processed/cur
NAME=nextcloud-app
NOTES=/var/www/html/data/manuel/files
SCAN_PATH=/manuel/files

offlineimap
mkdir $TMP
cd $TMP
echo "start unpacking files"
for i in `ls $MAILDIR`
do
    echo $i
    munpack -tf $MAILDIR/$i

    TO_FIELD=$(grep -m 1 -i '^To:' $MAILDIR/$i | sed 's/^To: //i')
    NAME_BEFORE_AT=$(echo "$TO_FIELD" | cut -d '@' -f 1)

    mv $MAILDIR/$i $PROCESSEDDIR/$i
    echo "to name extracted: "
    echo $NAME_BEFORE_AT

    if [ "$NAME_BEFORE_AT" = "paper" ]; then
        NAME_BEFORE_AT="Scans"
    else
        NAME_BEFORE_AT="Schule/$NAME_BEFORE_AT"
    fi

    find $TMP -type f ! -name '*.pdf' -delete
    docker cp $TMP/. $NAME:$NOTES/$NAME_BEFORE_AT
    rm -rf $TMP/*

done

echo "moved files files"

rm -rf $TMP
docker exec $NAME su -s /bin/bash -c "chown -R www-data:www-data $NOTES"

docker exec --user www-data $NAME /var/www/html/occ files:scan --path="$SCAN_PATH/Scans"
docker exec --user www-data $NAME /var/www/html/occ files:scan --path="$SCAN_PATH/Schule"
offlineimap
