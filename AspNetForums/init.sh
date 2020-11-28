!/bin/sh
echo 'echo drop database aspnetforums|psql template1' | su postgres
echo 'psql template1 < aspnetforums-init.sql' | su postgres
echo 'psql aspnetforums < aspnetforums-add.sql' | su postgres
echo 'psql aspnetforums < ForumsData.sql' | su postgres
echo 'psql aspnetforums < ResetSequences.sql' | su postgres
echo 'psql aspnetforums < AlterObjectOwner.sql' | su postgres
