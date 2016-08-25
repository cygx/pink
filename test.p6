use lib '.';
use Parser;
use Morpher;

sub pretty($_) {
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

say pretty $ast;
say pretty morph(|$ast);
