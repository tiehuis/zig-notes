const assert = @import("std").debug.assert;
const TypeId = @import("builtin").TypeId;

// This demonstrates an iterator similar in function to those found in Rust.
pub fn AscSeq(comptime T: type, comptime lo: T, comptime hi: T) -> type { struct {
    const Self = this;
    const Item = T;

    // Current loop index.
    current: T,

    // Construct a new iterator instance.
    pub fn new() -> Self {
        comptime {
            assert(lo <= hi);
            assert(@typeId(T) == TypeId.Int or @typeId(T) == TypeId.Float);
        }

        Self {
            .current = lo,
        }
    }

    // Return the next item of this iterator.
    pub fn next(it: &Self) -> ?Item {
        if (it.current >= hi) {
            null
        } else {
            const ret = it.current;
            it.current += 1;
            ret
        }
    }
}}

test "simple iterator" {
    var i = usize(0);

    // There is no explicit builtin support for specific iterators (i.e. via the Iter trait) but we
    // can get something fairly similar with an explicit initialization.
    var seq = AscSeq(usize, 0, 20).new();
    while (seq.next()) |item| {
        assert(item == i);
        i += 1;
    }
}
