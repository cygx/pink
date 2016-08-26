unit class Pink::Preprocessor;

class Pink::Preprocessor::X is Exception {
    has $.capture;
    has $.message;

    submethod BUILD(:$!capture) {
        $!message = $!capture.perl;
    }
}

method process($ast) { desugar |$ast }

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
