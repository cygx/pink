my grammar Grammar { ... }

sub parse($_) is export { Grammar.parse($_).made }

sub find-match-obj {
    my $pkg = CALLER::;
    loop {
        given $pkg<$/> {
            when .defined { .return }
            default { $pkg = $pkg<CALLER>.WHO }
        }
    }
}

sub bailout($msg = '?', :match($_) = find-match-obj)
        is hidden-from-backtrace {
    my $from = (.orig.rindex("\n", .to - 1) // -1) + 1;
    my $to = .orig.index("\n", .to) // *;
    my $n = .orig.substr(0, .to).comb("\n") + 1;
    my $line = .orig.substr($from ..^ $to);
    my $mark = ' ' x ($n.chars + .to - $from + 3) ~ '^';
    die "SORRY: $msg\n[$n] $line\n$mark";
}

role Matched[$match] {
    method matched { $match }
    method attach-match($obj) { $obj but Matched[$match] }
}

my grammar Grammar {
    token name      { <:letter> \w* }
    token longname  { <.name>+ % '::' }
    token comma     { \h* ',' \s* }
    token rolemark  { '~' }

    token TOP is hidden-from-backtrace {
        \s* <definition>* % [ \h* \v \s* ] \s*
        { make ('unit' but Matched[$/], |$<definition>>>.made) }
    }

    token definition {
        <pragma=.name> \h+ <name=.longname>
        [ \h+ <?before '('> [ <signature> ||{bailout} ] ]?
        [ <infix> <expression> | \h+ <block> ]?
        {
            make (~$<pragma> but Matched[$/], ~$<name>,
                $<infix> ?? ($<infix>.made, $<expression>.made) !!
                $<block> ?? $<block>.made !! Empty);
        }
    }

    token signature {
        '(' ~ ')' [ \s*
            <declarator>* % <.comma>
            [ \h+ '-->' \s+ [ <longname> <rolemark>? | <name> ] ]?
        \s* ]
    }


    token declarator {
        <type=.name> <rolemark>? \h+ <name>
        { make ($<type> ~ ($<rolemark> // ''), ~$<name>) }
    }

    token arglist {
        '(' ~ ')' [ \s* <expression>* % <.comma> \s* ]
    }

    token term {
        <longname>
    }

    token infix {
        [ \h* (':') \s+
        | \h+ (<.name>) \h+
        | \h+ (<[\S]-[\w,;.]>+) \h+
        ] { make ~($0 // $1 // $2) }
    }

    token declaration {
        <name> \h+ <declarator> [ <infix> <expression> ]?
        {
            make (
                ~$<name>,
                |$<declarator>.made,
                $<infix> ?? ($<infix>.made, $<expression>.made) !! Empty
            );
        }
    }

    token statement {
        [ <name> \h+ ]? <expression>+ % <.comma>
        { make ($<name> ?? ~$<name> !! 'do', |$<expression>>>.made) }
    }

    token expression {
        <term>+ % <infix>
    }

    token lines {
        [ <line=.declaration> | <line=.statement> ]* % [ \h* \v \s* ]
        { make $<line>>>.made }
    }

    token block {
        '{' ~ '}' [ \s* <lines> \s* ]
        { make ('block', |$<lines>.made) }
    }
}
