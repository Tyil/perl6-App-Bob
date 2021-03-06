#! /usr/bin/env perl6

use v6.c;

use App::Cpan6::Commands::New;
use App::Cpan6::Commands::Touch::Lib;
use App::Cpan6::Meta;
use File::Temp;
use Test;

multi sub MAIN { 0 }

# Disable git
%*ENV<CPAN6_EXTERNAL_GIT> = False;

my $root = tempdir;

chdir $root;

plan 2;

ok MAIN(
	"new",
	name => "Local::Test::Touch::Lib::Unit",
	author => "Patrick Spek",
	email => "p.spek@tyil.work",
	perl => "c",
	description => "Nondescript",
	license => "GPL-3.0",
	no-user-config => True,
), "cpan6 new Local::Test::Touch::Lib::Unit";

subtest "Touch unit files", {
	my @tests = <
		First
		Second::Level
		Third::Level::Test
	>;

	my $module-dir = "$root/perl6-Local-Test-Touch-Lib-Unit";

	plan 4 × @tests.elems;

	for @tests -> $test {
		chdir $module-dir;

		ok get-meta()<provides>{$test}:!exists, "META6.json does not contain $test yet";
		ok MAIN("touch", "unit", $test), "cpan6 touch unit $test";

		chdir $module-dir;

		my %new-meta = get-meta;

		ok %new-meta<provides>{$test}:exists, "$test exists in META6.json<provides>";
		ok %new-meta<provides>{$test}.IO.e, "{%new-meta<provides>{$test}} exists";
	}
}

# vim: ft=perl6 noet
