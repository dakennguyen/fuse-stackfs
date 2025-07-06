set mode quit alldone
set $dir=/home/khoa/mnt/test4
set $nfiles=1
set $meandirwidth=1
set $nthreads=1

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, size=1g, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=1m, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, iosize=1m, iters=1024, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}
create files
#unmount and mount for better stability results
#system "sync"
#system "umount /tmp"
#change accordingly for HDD(sdb) and SSD(sdd)
#system "mount -t ext4 /dev/sdd /tmp"
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
run

#13.292: Run took 3 seconds...
#13.292: Per-Operation Breakdown
#finish               1ops        0ops/s   0.0mb/s      0.0ms/op [0.00ms -  0.00ms]
#close1               1ops        0ops/s   0.0mb/s      0.0ms/op [0.02ms -  0.02ms]
#read-file            32768ops    10922ops/s 341.3mb/s      0.1ms/op [0.00ms -  3.84ms]
#open1                1ops        0ops/s   0.0mb/s    101.9ms/op [101.92ms - 101.92ms]
#13.292: IO Summary: 32770 ops 10922.700 ops/s 10922/0 rd/wr 341.3mb/s   0.1ms/op
#13.292: Shutting down processes
