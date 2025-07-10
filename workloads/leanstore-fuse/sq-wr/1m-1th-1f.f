set mode quit alldone
set $dir=/mnt/leanfs
set $nthreads=1

define file name=bigfile, path=$dir

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=1m, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfile
                flowop write name=write-file, filesetname=bigfile, iosize=1m, iters=1024
                flowop closefile name=close1
                flowop finishoncount name=finish, value=1
        }
}
create files
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
run 60
