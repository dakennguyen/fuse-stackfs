set mode quit alldone
set $dir=/mnt/leanfs
set $iosize=4k
set $nthreads=1

define file name=bigfile, path=$dir

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=$iosize, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfile
                flowop write name=write-file, filesetname=bigfile, iosize=$iosize, iters=10240000
                flowop closefile name=close1
                flowop finishoncount name=finish, value=1
        }
}

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "iostat -xy 1 > stat.log &"
run 10
