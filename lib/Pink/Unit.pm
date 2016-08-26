unit class Pink::Unit;

class Pink::Unit::X is Exception {}

my class Dict {
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

sub dict { Dict.new(@_) }

my enum PrimitiveType <i8 i16 i32 i64 u8 u16 u32 u64 f32 f64 int uint ptr>;

my class StructMember {
    has $.name;
    has $.type;
}

my class StructType {
    has $.name;
    has $.members = dict;
}

has $.types = dict;
has $.roles = dict;

method load($ast) {
    given self.bless {
        .process(|$ast);
        $_;
    }
}

method process('unit', **@_) {
    for @_ {
        when :('struct', Str, **@) {
            my ($, $name, **@members) = @$_;
            $!types{$name} = StructType.new(
                :$name,
                :members(dict @members.map(-> (Str $type, Str $name) {
                    StructMember.new(:$name, :$type);
                }))
            );
        }
    }
}
