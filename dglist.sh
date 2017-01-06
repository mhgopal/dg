dg=fra; for dir in $(asmcmd ls $dg); do echo $dg/$dir; asmcmd du $dg/$dir; done
