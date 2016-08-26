use Pink::Grammar;
use Pink::Preprocessor;
use Pink::Unit;
use Pink::Compiler;

sub parse(Str:D $code --> List:D)
is export {
    CATCH { when Pink::Grammar::X { fail $_ } }
    Pink::Grammar.parse($code).made;
}

sub process(List:D $ast --> List:D)
is export {
    CATCH { when Pink::Preprocessor::X { fail $_ } }
    Pink::Preprocessor.process($ast);
}

sub load(List:D $ast --> Pink::Unit:D)
is export {
    CATCH { when Pink::Unit::X { fail $_ } }
    Pink::Unit.load($ast);
}

sub link(*@units --> Pink::Unit:D)
is export {
    CATCH { when Pink::Unit::X { fail $_ } }
    Pink::Unit.link(@units);
}

sub write(Pink::Unit:D $unit, IO:D $io, Bool:D :$pretty = False --> Nil)
is export {
    CATCH { when Pink::Unit::X { fail $_ } }
    $unit.write($io);
}

sub read(IO:D $io --> Pink::Unit:D)
is export {
    CATCH { when Pink::Unit::X { fail $_ } }
    Pink::Unit.read($io);
}

sub compile(Pink::Unit:D $unit --> Str:D)
is export {
    CATCH { when Pink::Compiler::X { fail $_ } }
    Pink::Compiler.compile($unit);
}
