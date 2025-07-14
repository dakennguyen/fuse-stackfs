set mode quit alldone
set $dir=/mnt/leanfs
set $iosize=4k
set $nfiles=1
set $meandirwidth=1
set $nthreads=1

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, size=1g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$iosize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, iosize=$iosize, iters=26214400, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}

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
