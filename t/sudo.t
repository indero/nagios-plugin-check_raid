#!/usr/bin/perl
BEGIN {
	(my $srcdir = $0) =~ s,/[^/]+$,/,;
	unshift @INC, $srcdir;
}

use strict;
use warnings;

use Test::More tests => 17;
use test;

my $bindir = TESTDIR . '/data/bin';
unshift(@utils::paths, $bindir);

my $commands = {
	proc => ['<', '.']
};

my %params = (
	commands => $commands,
);

my %sudo = (
	mdstat => [],
	afacli => [],
	gdth => [],
	dpt_i2o => [],
	cciss => [],
	lsscsi => [],

	megacli => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/MegaCli -PDList -aALL -NoLog",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/MegaCli -LdInfo -Lall -aALL -NoLog",
	],
	ips => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/ipssend getconfig 1 LD",
	],
	aaccli => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/aaccli container list /full",
	],
	mpt => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/mpt-status",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/mpt-status -n",
	],
	tw_cli => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/tw_cli info*",
	],
	arcconf => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/arcconf GETSTATUS 1",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/arcconf GETCONFIG 1 AL",
	],
	megarc => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/megarc -AllAdpInfo -nolog",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/megarc -dispCfg -a* -nolog",
	],
	cmdtool2 => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/CmdTool2 -AdpAllInfo -aALL -nolog",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/CmdTool2 -CfgDsply -a* -nolog",
	],
	sas2ircu => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/sas2ircu LIST",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/sas2ircu * STATUS",
	],
	hpacucli => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/hpacucli controller all show status",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/hpacucli controller * logicaldrive all show",
	],
	areca => [
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/cli64 rsf info",
		"CHECK_RAID ALL=(root) NOPASSWD: $bindir/cli64 disk info",
	],
);

# check that sudo rules are what expected (to understand when they change)
foreach my $pn (@utils::plugins) {
	my $plugin = $pn->new(%params);
	my @rules = $plugin->sudo(1) or undef;

	my $exp = join "\n", @{$sudo{$pn}};
	my $rules = join "\n", @rules;
	printf("%s => '%s' ne '%s'\n", $pn, $exp, $rules) if $exp ne $rules;
	ok($exp eq $rules, "$pn sudo ok");
}
