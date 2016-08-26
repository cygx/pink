unit class Pink::Preprocessor;

class Pink::Preprocessor::X is Exception {
    has $.capture;
    has $.message;

    submethod BUILD(:$!capture) {
        $!message = $!capture.perl;
    }
}

method process($ast) { desugar |$ast }

method dump($ast, $io) {
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

    $io.put([~] do gather compile($ast, 0));
}

multi desugar($_ where 'unit', **@_) {
    ($_, |@_.map({ desugar |$_ }));
}

multi desugar('has', $type, $name, :$class!, :$role!) {
    slip
        ('fn', $name, ('paras', ("$class~", 'self')),('ret', $type)),
        ('fn', $name, ('paras', ("$class~", 'self'), ($type, $name)),
            ('ret', $name));
}

multi desugar('has', $type, $name, :$class!, :$impl!) {
    slip
        ('fn', $name, ('paras', ("$class", 'self')),('ret', $type),
            ('block', ('call', $name, ('lex', 'self')))),
        ('fn', $name, ('paras', ("$class", 'self'), ($type, $name)),
            ('ret', $name),
            ('block',));
}

multi desugar($_ where 'class', Str $name, @ ('block', **@body)) {
    my @members;
    my @role;
    my @impl;

    for @body {
        when .[0] === 'has' {
            @members.push(.[1..*]);
            @role.push(desugar(|$_, class => $name, :role));
            @impl.push(desugar(|$_, class => $name, :impl));
        }
    }

    slip
        (.?attach-match('struct'), $name, |@members),
        (.?attach-match('role'), $name, |@role),
        (.?attach-match('impl'), $name, |@impl);
}

multi desugar(|c) {
    Pink::Preprocessor::X.new(capture => c).throw;
}
