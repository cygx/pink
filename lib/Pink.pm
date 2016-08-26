use Pink::Grammar;
use Pink::Preprocessor;
use Pink::Unit;
use Pink::Compiler;
use Pink::X;

sub parse(Str:D $code --> List:D) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Grammar.parse($code).made;
}

sub process(List:D $ast --> List:D) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Preprocessor.process($ast);
}

sub dump(List:D $ast, IO:D $io = $*ERR --> Nil) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Preprocessor.dump($ast, $io);
}

sub load(List:D $ast --> Pink::Unit:D) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Unit.load($ast);
}

sub link(*@units --> Pink::Unit:D) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Unit.link(@units);
}

sub write(Pink::Unit:D $unit, IO:D $io, Bool:D :$pretty = False --> Nil) {
    CATCH { when X::Pink { fail $_ } }
    $unit.write($io);
}

sub read(IO:D $io --> Pink::Unit:D) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Unit.read($io);
}

sub compile(Pink::Unit:D $unit --> Str:D) {
    CATCH { when X::Pink { fail $_ } }
    Pink::Compiler.compile($unit);
}

sub EXPORT(*@list) {
    my %stash := OUTER::;
    Map.new(
        'pink' => OUTER,
        @list.map({
            when %stash{"&$_"}:exists { "&$_" => %stash{"&$_"} }
            default { die "Cannot import unknown sub &$_ from Pink"}
        })
    );
}
