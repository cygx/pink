use lib 'lib';
use Pink;

sub pretty($_) {
    my proto compile(|) {*}

    multi compile(List $_, $i is copy) {
        take '(';

        if $_ {
            my ($n, $pre);
            given .[0] {
                when any(<unit block>) {
                    $n = 1;
                    $pre = "\n" ~ '  ' x ++$i;
                }
                when any(<role impl>) {
                    $n = 2;
                    $pre = "\n" ~ '  ' x ++$i;
                }
                default {
                    $n = 1;
                    $pre = ' ';
                }
            }

            take |.[^$n];

            for .[$n..*] {
                take $pre;
                compile($_, $i);
            }
        }

        take ')';
    }

    multi compile(Str $_, $i) {
        take /^\w+$/ ?? $_ !! "'$_'"
    }

    [~] do gather compile($_, 0);
}

my $ast = parse q:to/END/;
class Point {
    has f64 x
    has f64 y
}
END

my $past = process $ast;

say pretty($ast), "\n";
say pretty($past), "\n";
say load($past), "\n";
