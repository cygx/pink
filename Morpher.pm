proto morph(|) is export {*}

multi morph($_ where 'unit', **@_) {
    ($_, |@_.map({ morph |$_ }));
}

multi morph('has', $type, $name, :$class!, :$role!) {
    slip
        ('fn', $name, ('paras', ("$class~", 'self')),('ret', $type)),
        ('fn', $name, ('paras', ("$class~", 'self'), ($type, $name)),
            ('ret', $name));
}

multi morph('has', $type, $name, :$class!, :$impl!) {
    slip
        ('fn', $name, ('paras', ("$class", 'self')),('ret', $type),
            ('block', ('call', $name, ('lex', 'self')))),
        ('fn', $name, ('paras', ("$class", 'self'), ($type, $name)),
            ('ret', $name),
            ('block',));
}

multi morph($_ where 'class', Str $name, @ ('block', **@body)) {
    my @members;
    my @role;
    my @impl;

    for @body {
        when .[0] === 'has' {
            @members.push(.[1..*]);
            @role.push(morph(|$_, class => $name, :role));
            @impl.push(morph(|$_, class => $name, :impl));
        }
    }

    slip
        (.?attach-match('struct'), $name, |@members),
        (.?attach-match('role'), $name, ('block', |@role)),
        (.?attach-match('impl'), $name, ('block', |@impl));
}

multi morph(|c) {
    die c.perl;
}
