my class Dict is export {
    also does Iterable;
    also does Positional;
    also does Associative;

    has @!keys handles <elems>;
    has %!hash;

    method gist { "dict{ self.pairs.gist }" }
    method perl { "Dict.new({ self.pairs>>.perl.join(', ') })" }

    method of { Any }
    method AT-POS(Int $pos) { %!hash{@!keys[$pos]} }

    method AT-KEY(Str $key) is rw {
        Proxy.new(
            FETCH => { %!hash{$key} },
            STORE => -> $, $value {
                die "Cannot overwrite dict entry '$key'"
                    if $key ~~ %!hash;
                @!keys.push($key);
                %!hash{$key} = $value;
            }
        );
    }

    method pairs { @!keys.map({ $_ => %!hash{$_} }) }
    method kv { @!keys.map({ slip $_, %!hash{$_} }) }
    method keys { @!keys.Seq }

    multi method add(Pair $_) {
        self{.key} = .value;
    }

    multi method add($key, $value) {
        self{$key} = $value;
    }

    multi method add($_) {
        die unless .^can("name");
        self{.name} = $_;
    }

    method new(*@_) {
        my $dict = self.bless;
        $dict.add($_) for @_;
        $dict;
    }

    my class DictIterator {
        has $.dict;
        has int $!i = 0;
        method pull-one {
            $!i < $!dict.elems
                ?? $!dict[$!i++]
                !! IterationEnd;
        }
    }

    method iterator {
        DictIterator.new(dict => self);
    }
}

sub dict is export { Dict.new(@_) }
