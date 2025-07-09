set mode quit alldone
set $dir=/home/khoa/mnt/test4
set $nfiles=3
set $meandirwidth=3
set $nthreads=1
#Each thread reading 1G
set $io_size=128k
set $iterations=8192

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, dirgamma=0, size=1g, prealloc

define process name=filereader,instances=1
{
        thread name=filereaderthread,memsize=$io_size, instances=$nthreads
        {
                flowop openfile name=open1, indexed=1, filesetname=bigfileset, fd=1
                flowop read name=read-file-1, indexed=1, filesetname=bigfileset, random, iosize=$io_size, iters=$iterations, fd=1
                flowop closefile name=close1, indexed=1, fd=1
                flowop finishoncount name=finish, value=1
        }

        thread name=filereaderthread,memsize=$io_size, instances=$nthreads
        {
                flowop openfile name=open2, indexed=2, filesetname=bigfileset, fd=1
                flowop read name=read-file-2, indexed=2, filesetname=bigfileset, random, iosize=$io_size, iters=$iterations, fd=1
                flowop closefile name=close2, indexed=2, fd=1
                flowop finishoncount name=finish, value=1
        }

        thread name=filereaderthread,memsize=$io_size, instances=$nthreads
        {
                flowop openfile name=open3, indexed=3, filesetname=bigfileset, fd=1
                flowop read name=read-file-3, indexed=3, filesetname=bigfileset, random, iosize=$io_size, iters=$iterations, fd=1
                flowop closefile name=close3, indexed=3, fd=1
                flowop finishoncount name=finish,value=1
        }
}
create files
#mount and unmount for better stability
#system "sync"
#system "umount /mnt/EXT4_FS"
#Change accordingly for HDD(sdb) and SSD(sdd)
#system "mount -t ext4 /dev/sdd /mnt/EXT4_FS"
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
run 60
