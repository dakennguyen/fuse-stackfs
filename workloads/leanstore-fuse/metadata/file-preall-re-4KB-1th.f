set mode quit alldone
set $dir=/mnt/leanfs
#Fix the No. of files to 1M prealloc (0.3 M run)
set $nfiles=100000
set $meandirwidth=1000
set $nthreads=1

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, dirgamma=0, size=4k, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=4k, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop readwholefile name=read-file, filesetname=bigfileset, iosize=4k, fd=1
                flowop closefile name=close-file,filesetname=bigfileset, fd=1
                flowop finishoncount name=finish, value=4000000
                #so that open, read and close happen 1 M times
        }
}

create files

system "sync"
system "umount /mnt/ext4"
system "umount /mnt/xfs"
system "umount /mnt/btrfs"
system "mount /dev/sdc /mnt/ext4"
system "mount /dev/sdd /mnt/xfs"
system "mount /dev/sde /mnt/btrfs"

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

run 10
