set mode quit alldone
set $dir=/mnt/leanfs
set $nfiles=3
set $meandirwidth=3
set $nthreads=1
set $io_size=1m
set $iterations=1024

define fileset name=bigfileset, path=$dir, entries=$nfiles, dirwidth=$meandirwidth,dirgamma=0,size=2g

define process name=filesequentialwrite, instances=1
{
        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create1, filesetname=bigfileset, fd=1, indexed=1
                flowop write name=write-file1, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=1
                flowop closefile name=close1, fd=1, indexed=1
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create2, filesetname=bigfileset, fd=1, indexed=2
                flowop write name=write-file2, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=2
                flowop closefile name=close2, fd=1, indexed=2
                flowop finishoncount name=finish, value=1
        }

        thread name=filewriter, memsize=$io_size, instances=$nthreads
        {
                flowop createfile name=create3, filesetname=bigfileset, fd=1, indexed=3
                flowop write name=write-file3, filesetname=bigfileset, iosize=$io_size,iters=$iterations, fd=1, indexed=3
                flowop closefile name=close3, fd=1, indexed=3
                flowop finishoncount name=finish, value=1
        }
}
create files
system "sync"
system "echo 3 > /proc/sys/vm/drop_caches"
system "echo started >> cpustats.txt"
system "echo started >> diskstats.txt"
run 60
