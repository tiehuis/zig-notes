const assert = @import("std").debug.assert;

test "switch simple" {
    const a: u64 = 10;
    const zz: u64 = 103;

    // A switch statement in zig is an expression. All branches must be able to
    // be coerced to a common type.
    //
    // Branches cannot fallthrough. If fallthrough behavior is desired, combine the cases
    // and use an if.
    const b = switch (a) {
        // Multiple cases can be combined via a ','
        1, 2, 3 => 0,

        // Ranges can be specified using the ... syntax. These are inclusive both ends.
        5 ... 100 => 1,

        // Branches can be arbitrarily complex.
        101 => {
            const c: u64 = 5;
            c * 2 + 1
        },

        // Switching on identifer values is allowed.
        zz => zz,

        // Switching on arbitrary expressions is also allowed as long as they can
        // evaluated completely at compiled.
        comptime {
            const d: u32 = 5;
            const e: u32 = 100;
            d + e
        } => 107,

        // The else branch catches everything not already captured.
        else => 9,
    };

    assert(b == 1);
}

test "switch enum" {
    const Item = enum {
        A: u32,
        C: struct { x: u8, y: u8 },
        D,
    };

    var a = Item.A { 3 };

    // Switching on more complex enums is allowed.
    const b = switch (a) {
        // A capture group is allowed on a match, and will return the enum value matched.
        Item.A => |item| item,

        // A reference to the matched value can be obtained using `*` syntax.
        Item.C => |*item| {
            (*item).x += 1;
            6
        },

        // No else is required if the types cases was exhaustively handled
        Item.D => 8,
    };

    assert(b == 3);
}
