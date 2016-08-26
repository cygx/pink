use lib 'lib';
use Pink <parse process load dump compile>;

my $code = q:to/END/;
class Point {
    has f64 x
    has f64 y
}
END

my $ast = parse $code;
my $past = process $ast;
my $unit = load $past;

dump $ast;
dump $past;
print compile $unit;
