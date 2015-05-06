#!/usr/bin/perl

#*****************************************************
# Author:
# Lokesh Jindal
# lokeshjindal15@cs.wisc.edu
# May, 2015
#*****************************************************

use File::Find;
use File::Basename;

# my $RATE_CALC_PERIOD = 0.0002; # 200us or 0.2ms

if (@ARGV !=2)
{
	print "ERROR! Provide a value for RATE_CALC_PERIOD for the rate calculator in seconds\n";
	print "Usage: <script> <name of directory containing subdirectories with gem5sim.out files> <RATE_CALC_PERIOD>\n";
	exit;
}

my $RATE_CALC_PERIOD = $ARGV[1];

my $DATA_DIR = "";
if ($ARGV[0])
{
	$DATA_DIR = $ARGV[0];
	print "DATA_DIR being used is *$DATA_DIR*\n";
}
else
{
	print "Usage: <script> <name of directory containing subdirectories with gem5sim.out files> <RATE_CALC_PERIOD>\n";
	print "Kindly enter a valid DATA_DIR to look for gem5sim.out files! Exiting ... \n";
	exit;
}

my @out_file_list;

sub wanted_files
{
	my $file_name = $File::Find::name;
	#print "file_name is $file_name\n";
	if (!(-d $file_name))
	{
		# print "file_name is $file_name\n";
	}

	if (!(-d $file_name) and ($_ =~ /gem5sim.out$/)and !($file_name =~ /switch/) and !($file_name =~ /tux4/))# ignore switch and tux4 gem5sim.out
	{
		push @out_file_list, $file_name;
	}
}
find(\&wanted_files, $DATA_DIR);

$num_out_file = @out_file_list;

print "number of gem5sim.out files found is $num_out_file\n";
my $l = 0;
while ( $l < $num_out_file)
{
	chomp($out_file_list[$l]);
	print "$out_file_list[$l]\n";
	$l++;
}

my $OUT_FILE_I = 0;
while ($OUT_FILE_I < $num_out_file)
{
	$out_file = $out_file_list[$OUT_FILE_I];
	$out_dir = dirname($out_file);
	$BENCHMARKS[$OUT_FILE_I] = basename ($out_dir);
	print "gem5sim.out file beng used is $out_file and outdir is $out_dir\n";
	print "********DANGER******** Removing existing pdgem5int.csv: rm $out_dir/m5out/pdgem5int.csv\n";
	`rm $out_dir/m5out/pdgem5int.csv`;

	if (-e "$out_dir/m5out/cum.allcores.csv")
	{
	}
	else
	{
		print "***** ERROR! Can't find file $out_dir/m5out/cum.allcores.csv Exiting ...\n";
		exit;
	}
	if (-e "$out_dir/m5out/stats.txt")
	{
	}
	else
	{
		print "***** ERROR! Can't find file $out_dir/m5out/stats.txt Exiting ...\n";
		exit;
	}

	# $NUMPOINTS = `cat $out_dir/m5out/cum.allcores.csv | wc -l`;
	# chomp($NUMPOINTS);
	# $NUMPOINTS = $NUMPOINTS - 1;
	# $ref_sim_sec = ...; # parse the cumsimseconds from the cum.all.cores.csv file

	$start_tick = `head -10 "$out_dir/m5out/stats.txt" | grep final_tick`;
	if ($start_tick =~ /.*final_tick\s+(\d{9})\d{4}/) # read only 9 digits out of 13 reported digits
	{
		$BEGIN_TICK = $1;
	}
	else
	{
		print "ERROR! Could not find final tick Exiting ...\n";
		exit;
	}
	print "start_tick is $start_tick and BEGIN_TICK is $BEGIN_TICK\n";
	
	$tail = `tail -1 "$out_dir/m5out/cum.allcores.csv"`;
	my @values = split(',', $tail);

	my $MAX_SEC = $values[0] ; # TODO FIXME get the max number of seconds from cum.allcores.csv

	print "TAIL is $tail and MAX_SEC is $MAX_SEC\n";

	my $sec_iter = 0;
	@time_array = 0;
	$time_array[$sec_iter] = 0;
	while ($time_array[$sec_iter] < $MAX_SEC)
	{
		$sec_iter++;
		$time_array[$sec_iter] = $RATE_CALC_PERIOD + $time_array[$sec_iter - 1];
	}
	$NUMPOINTS = $sec_iter - 1;

	my $MAXINTS = 0;
	$MAXINTS = `grep "SENDING PDGEM5INT @ TICK" $out_file | wc -l`;
	chomp($MAXINTS);
	print "Number of PDGEM5INTS in $out_file is $MAXINTS\n";

	if($MAXINTS == 0)
	{
		print "***** WARNING ***** MAXINTS is $MAXINTS for file $out_file\n";
		# exit;
	}
	else # generate pdgem5int.csv file since MAXINTS > 0
	{
		open OUT_FILE, $out_file or die $!;
		my $line = "";
		my @interrupt;
		my @dump_interrupt;

		my $int_num;
		$int_num = 0;
		while ($line = <OUT_FILE>)
		{
			if ($line =~ /.*SENDING PDGEM5INT @ TICK :(\d{9})\d{4}:/)
			{
				$interrupt[$int_num] = $1;
				$interrupt[$int_num] = ($1 - $BEGIN_TICK) / 100000000; # reading only 9 digits out of 13 so divide by 10^8 instead of 10^12 
				$int_num = $int_num + 1;
				# print "int_num = $int_num and interrupt is $interrupt[$int_num]\n";
			}
			# else
			# {
			# 	print "ERROR! tick match failed for line $line for file $out_file\n";
			# 	print "Exiting ...\n";
			# 	exit;
			# }
		}

		close OUT_FILE;
		if ($int_num != $MAXINTS)
		{
			print "***** ERROR! int_num = $int_num NOT EQUAL TO MAXINTS = $MAXINTS for file $out_file Exiting ...\n";
			exit;
		}

		# $int_num = 0;
		# my $iter = 0;
		# while ($iter < $NUMPOINTS)
		# {
		# 	if (($int_num < $MAXINTS) && ($interrupt[$int_num] < $ref_sim_sec[$iter]))
		# 	{
		# 		while (($interrupt[$int_num] < $ref_sim_sec[$iter]))
		# 		{
		# 			$dump_interrupt[$iter] = 100;
		# 			$int_num++;
		# 			$iter++;
		# 		}
		# 	}
		# 	else
		# 	{
		# 		$dump_interrupt[$iter] = 0;
		# 		$iter++;
		# 	}
		# }

		# if ($int_num != $MAXINTS)
		# {
		# 	print "ERROR! After populating dump_interrupt, int_num = $int_num DOES NO MATCH MAXINTS = $MAXINTS Exiting ...";
		# 	exit;
		# }

		$int_num = 0;
		$iter = 0;
		while ($iter < $NUMPOINTS)
		{
			if (($interrupt[$int_num] < $time_array[$iter]) && ($int_num < $MAXINTS))
			{
				$dump_interrupt[$iter] = 100;
				$iter++;
				$int_num++;
			}
			else
			{
				$dump_interrupt[$iter] = 0;
				$iter++;
			}
		}
		if ($int_num != $MAXINTS)
		{
			print "ERROR! After populating dump_interrupt, int_num = $int_num DOES NO MATCH MAXINTS = $MAXINTS Exiting ...";
			exit;
		}
		
		print "Let's create the csv file $out_dir/m5out/pdgem5int.csv\n";
		open F1, ">$out_dir/m5out/pdgem5int.csv" or die $!;
		print F1 "cumtime,intornot\n";
		
		$iter = 0;
		while ($iter < $NUMPOINTS)
		{
			print F1 "$time_array[$iter], $dump_interrupt[$iter]\n";
			$iter++;
		}
		close F1;

		# close $OUT_FILE;

	} # end of creating the pdgem5int.csv file
	print "########################################################################################################";
	$OUT_FILE_I++;
}


