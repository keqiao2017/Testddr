#! /usr/bin/perl -w
use strict;
use Term::ANSIColor;

# useage: ColorMessage ('green','hello world');
sub ColorMessage {
	my ($colors,$message) = @_;
	print color "bold $colors";
	print "$message\n";
	print color 'reset';
}

#first thing is hot_reset
# my $rst_log = `sudo ~/PCIE-FPGA/HOT_RESET_PCIE 2.sh`;
# print "hot_reset SUCCESSFULLY,\n$rst_log";
#the second thing is to write the addr to the slv_reg1
#my $end_addr = 2147483647; #2G 
my $end_addr = 2147400000;
for (my $start_addr = 0; $start_addr < $end_addr; $start_addr= $start_addr + 100000) {
	# change start_addr to hex 
	my $file_cnt = ($start_addr) / 100000 ;
	my $start_addr_hex = sprintf ("%1x",$start_addr);
	my $end_addr_once = $start_addr + 100000;
	my $end_addr_once_hex = sprintf ("%1x",$end_addr_once);
	ColorMessage ('green',"[$file_cnt]Testing from \"0x$start_addr_hex\" to \"0x$end_addr_once_hex\"");
	# print "[$file_cnt]Testing from \"0x$start_addr_hex\" to \"0x$end_addr_once_hex\"";
	# write the start addr to slv_reg1
	my $write_log = `sudo ./reg_rw /dev/xdma0_user 0x4 w 0x$start_addr_hex`;
	# print "\n$write_log";

	# normally is Write 32-bits value 0x1000 to 0x00000004 (0x0x7f6ae0ea6004)

	#check the addr is right or not
	if ($write_log =~ /\s0x(\w+)\sto\s0x([0-9]*)/){
		my $start_addr_dec = hex($1);
		if ( ($start_addr_dec == $start_addr) && ($2 == 000000004)) {
			ColorMessage ('green',"[$file_cnt]SUCCESSFULLY Write Start Address From\"$1\" to \"$2\" ");
		 	# print "[$file_cnt]SUCCESSFULLY Write Start Address From\"$1\" to \"$2\" ";	
		} 
		else{
			print "\n[$file_cnt]ERRO! Wrong Start Address or Wrong slv_reg1 addr\n";
			print "$start_addr_dec  and $start_addr\n";
			exit;

		} 
	}
	else {
		ColorMessage ('red','ERRO! Write slv_reg1');
		printf "$write_log\n";
		exit;
	}
		
	#sleep 2s
	sleep (1);	
	#read DDR and save in file
	my $read_log = `sudo ./dma64_from_device -d /dev/xdma0_c2h_0  -f keqiao_0308_$file_cnt.bin -s 100000 -a 0x$start_addr_hex -c 1`;
	system ("diff keqiao_0308_$file_cnt.bin testddr_7.bin");
	if($? == 0) {
		ColorMessage ('green',"[$file_cnt]Address Between \"$start_addr_hex\" and \"$end_addr_once_hex\"  is SUCCESSFUL!\n");
		#print "\n[$file_cnt]Address Between \"$start_addr_hex\" and \"$end_addr_once_hex\"  is SUCCESSFUL!\n";
		if($file_cnt > 0) {
			my $rm_cnt = $file_cnt - 1;
			unlink "keqiao_0308_$rm_cnt.bin";
			}
		}
	else {
		die  "\n[$file_cnt]Start Address between $start_addr_hex and $end_addr_once_hex  is WRONG!";
	}
}