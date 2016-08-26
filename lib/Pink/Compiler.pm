use Pink::Types;
use Uni63;

my &mangle := &Uni63::enc;

class Pink::Compiler {
    method compile($unit) {
        [~] $unit.types.map: {
            when StructType {
                qq:to/END/;
                struct pink_{mangle .name} \{
                    {
                        .members.map({
                            ctype(.type) ~ ' m_' ~ mangle(.name);
                        }).join("\n    ");
                    }
                };
                END
            }
            default { die .^name }
        }
    }
}
