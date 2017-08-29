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

// This is a better implementation with runtime values and an optional step value. It also better
// handles edge cases on integer ranges.
pub fn Seq(comptime T: type) -> type { struct {
    const Self = this;
    const Item = T;

    current: T,
    step: T,
    a: T,
    b: T,
    consumed: bool,

    pub fn initWithStep(a: T, b: T, step: T) -> Self {
        comptime assert(@typeId(T) == TypeId.Int);
        assert(step != 0);

        Self {
            .current = a,
            .consumed = if (a == b) true else false,
            .a = a,
            .b = b,
            // A negative step is treated the same as a positive. This ensures we always step in
            // the correct direction.
            .step = if (step < 0) -step else step,
        }
    }

    pub fn init(a: T, b: T) -> Self {
        initWithStep(a, b, 1)
    }

    pub fn next(it: &Self) -> ?Item {
        if (it.consumed) {
            null
        } else {
            const result = it.current;

            if (it.a < it.b) {
                if (@addWithOverflow(T, it.current, it.step, &it.current) or it.current > it.b) {
                    it.consumed = true;
                }
            } else {
                if (@subWithOverflow(T, it.current, it.step, &it.current) or it.current < it.b) {
                    it.consumed = true;
                }
            }

            result
        }
    }
}}

test "better iterator" {
    // Would usually overflow with a usual loop statement.
    var seq_desc = Seq(u8).init(5, 0);
    var i: u8 = 6;
    while (seq_desc.next()) |item| {
        assert(item == i - 1);
        i -= 1;
    }

    var seq_asc = Seq(i16).initWithStep(-40, -189, 23);
    var j: i16 = -40;
    while (seq_asc.next()) |item| {
        assert(item == j);
        j -= 23;
    }

    // NOTE: comptime does not work for this iterator. Issue with while on a nullable sequence at
    // compile-time?
    //comptime {
        var seq_ct = Seq(i16).initWithStep(40, 50, 4);
        var k: i32 = 0;
        while (seq_ct.next()) |item| {
            k += item;
        }
        assert(k == 40 + 44 + 48);
    //}

    // NOTE: We could add a float iterator as well but would require a different addWithOverflow
    // detection for edge cases and also would require subnormal handling possibly.
    // var seq_float = Seq(f32).initWithStep(0, 5, 0.34);
    // var l: f32 = 0;
    // while (seq_float.next()) |item| {
    //     assert(l == item);
    //     l += 0.34;
    // }
}
