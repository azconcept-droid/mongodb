## Run the installation script to install mongodb
chmod +x install_mongodb.sh
./install_mongodb.sh

## Take a DB dump
mongodump \
   --host=mongodb1.example.net \
   --port=3017 \
   --username=user \
   --password="pass" \
   --out=/opt/backup/mongodump-1

## Restore the DB in the new environment
mongorestore \
   --host=mongodb1.example.net \
   --port=3017 \
   --username=user \
   --authenticationDatabase=admin \
   /opt/backup/mongodump-1
