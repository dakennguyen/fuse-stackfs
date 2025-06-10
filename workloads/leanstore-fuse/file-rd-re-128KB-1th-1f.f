set mode quit alldone
set $dir=/mnt/test4
set $nfiles=1
set $nthreads=1
#Fix I/O amount to 60 G (SSD)
set $memsize=128k
set $iterations=491520

define file name=bigfileset, path=$dir, size=2g, prealloc, reuse

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$memsize, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, random, iosize=$memsize, iters=$iterations, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}

create files
#mounting and unmounting for better stable results
#system "sync"
#system "umount /mnt/test4/"
#Change accordingly for HDD(sdb) and SSD(sdd)
#system "mount -t ext4 /dev/sdd /mnt/test4"

#warm up the cache (RAM)
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "dd if=/mnt/test4/bigfileset/00000001/00000001 of=/dev/null bs=4096 count=1048576 &> /dev/null"

system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
run
