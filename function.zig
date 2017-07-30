const assert = @import("std").debug.assert;

// Functions are declared like this
// The last expression in the function can be used as the return value.
pub fn add(a: i8, b: i8) -> i8 {
    if (a == 0) {
        // You can still return manually if needed.
        return b;
    }

    a + b
}

// Functions can be made to use the C abi by using the export specifier.
export fn sub(a: i8, b: i8) -> i8 { a - b }

// The pub specifier allows the function to be visible when importing.
pub fn sub2(a: i8, b: i8) -> i8 { a - b }

// Functions can be passed to other functions, the same as C function pointers.
const call2_op = fn (a: i8, b: i8) -> i8;
fn do_op(fn_call: call2_op, op1: i8, op2: i8) -> i8 {
    fn_call(op1, op2)
}

test "function" {
    assert(do_op(add, 5, 6) == 11);
    assert(do_op(sub2, 5, 6) == -1);
}
