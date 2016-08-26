use lib 'lib';
use Pink <parse process load dump>;

my $ast = parse q:to/END/;
class Point {
    has f64 x
    has f64 y
}
END

my $past = process $ast;

dump $ast;
dump $past;

my $unit = load $past;
$unit.write($*OUT);
