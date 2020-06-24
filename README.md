### AutoBackup

#### Usage

1. `mkdir backup_foo` make backup dir

2. `backup_foo/list.conf` use to record a file list that need to backup

3. `backup_foo/reserve.conf` use to record a file list that won't removed by script

4. Run `./backup.sh foo` to backup files in `backup_foo/list.conf`

5. Run `./restore.sh foo` to restore files in `backup_foo/list.conf`

#### License

[MIT](LICENSE)
