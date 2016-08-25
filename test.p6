use lib '.';
use Parser;
use Morpher;

sub pretty($_) {
    multi compile(List $_, $i is copy) {
        take '(';

        if $_ {
            take .[0];

            my $pre := .[0] ~~ any(<unit block>)
                ?? slip "\n", '  ' x ++$i
                !! ' ';

            for .[1..*] {
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
