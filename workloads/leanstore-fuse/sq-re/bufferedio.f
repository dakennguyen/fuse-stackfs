set mode quit alldone
set $dir=/mnt/leanfs
set $iosize=4k
set $nfiles=1
set $meandirwidth=1
set $nthreads=1
set $size=14m

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth, size=$size, prealloc

define process name=fileopen, instances=1
{
        thread name=fileopener, memsize=2m, instances=$nthreads
        {
                flowop openfile name=open1, filesetname=bigfileset, fd=1
                flowop read name=read-file, filesetname=bigfileset, iosize=$iosize, iters=26214400, fd=1
                flowop closefile name=close1, fd=1
                flowop finishoncount name=finish, value=1
        }
}

system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"

system "iostat -xy 1 > stat.log &"
run 10
