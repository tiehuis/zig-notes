const assert = @import("std").debug.assert;
const mem = @import("std").mem;

// Declare an enum.
const Type = enum {
    Ok,
    NotOk,
};

// Enums are sum types, and can hold more complex data of different types.
const ComplexType = enum {
    Ok: u8,
    NotOk: void,
};

// Declare a specific instance of the enum variant.
const c = ComplexType.Ok { 0 };

// The ordinal value of a simple enum with no data members can be
// retrieved by a simple cast.
// The value starts from 0, counting up for each member.
const Value = enum {
    Zero,
    One,
    Two,
};
test "enum ordinal value" {
    assert(usize(Value.Zero) == 0);
    assert(usize(Value.One) == 1);
    assert(usize(Value.Two) == 2);
}

// Enums can have methods, the same as structs.
// Enum methods are not special, they are only namespaced
// functions that you can call with dot syntax.
const Suit = enum {
    Clubs,
    Spades,
    Diamonds,
    Hearts,

    pub fn ordinal(self: &const Suit) -> u8 {
        u8(*self)
    }
};
test "enum method" {
    const p = Suit.Spades;
    assert(p.ordinal() == 1);
}

// An enum variant of different types can be switched upon.
// The associated data can be retrieved using `|...|` syntax.
//
// A void type is not required on a tag-only member.
const Foo = enum {
    String: []const u8,
    Number: u64,
    None,
};
test "enum variant switch" {
    const p = Foo.Number { 54 };
    const what_is_it = switch (p) {
        // Capture by reference
        Foo.String => |*x| {
            "this is a string"
        },

        // Capture by value
        Foo.Number => |x| {
            "this is a number"
        },

        Foo.None => {
            "this is a none"
        }
    };
}

// The @enumTagName and @memberCount builtin functions can be used to
// the string representation and number of members respectively.
const BuiltinType = enum {
    A: f32,
    B: u32,
    C,
};

test "enum builtins" {
    assert(mem.eql(u8, @enumTagName(BuiltinType.A { 0 }), "A"));
    assert(mem.eql(u8, @enumTagName(BuiltinType.C), "C"));
    assert(@memberCount(BuiltinType) == 3);
}
