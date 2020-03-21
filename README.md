### AutoBackup

#### Usage

1. `mkdir backup` make backup dir

2. `backup/list.conf` use to record a file list that need to backup

3. `backup/reserve.conf` use to record a file list that won't removed by script

4. Run `backup.sh` to backup files in `backup/list.conf`

5. Run `restore.sh` to restore files in `backup/list.conf`

> NOTE: `backup.cron` use to regularly backup and upload to github

#### License

[MIT](LICENSE)
