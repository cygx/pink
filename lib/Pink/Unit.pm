use Pink::Dict;
use Pink::Types;

class Pink::Unit {
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
                        StructMember.new(
                            :$name,
                            type => PrimitiveType::{$type} // die
                        );
                    }))
                );
            }
        }
    }

    method write($io, :$pretty) {}
}
