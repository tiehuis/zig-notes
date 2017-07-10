const assert = @import("std").debug.assert;

test "for basics" {
    const items = []i32 { 4, 5, 3, 4, 0 };
    var sum: i32 = 0;

    // A for loop in zig is used for iterating over a slice.
    // A capture value is specified to bind to an identifier within the loop.
    for (items) |value| {
        // Break and continue are supported.
        if (value == 0) {
            continue;
        }
        sum += value;
    }
    assert(sum == 16);

    // To iterate over a portion of a slice, simply reslice
    for (items[0..1]) |value| {
        sum += value;
    }
    assert(sum == 20);

    // To access the index of iteration, specify a second capture value.
    // This is zero-indexed. The type of i is a `usize`.
    var sum2: i32 = 0;
    for (items) |value, i| {
        sum2 += i32(i);
    }
    assert(sum2 == 10);
}

test "for reference" {
    var items = []i32 { 3, 4, 2 };

    // Iteration over the slice by reference can be performed by
    // specifying that the capture value is a pointer.
    // NOTE: Why a *value and not &value?
    for (items) |*value| {
        *value += 1;
    }

    assert(items[0] == 4);
    assert(items[1] == 5);
    assert(items[2] == 3);
}

test "for else" {
    // For allows an else attached to it, the same as a while loop.
    var items = []?i32 { 3, 4, null, 5 };

    // For loops can also be used as expressions.
    var sum: i32 = 0;
    const result = for (items) |value| {
        if (value == null) {
            break 9;
        } else {
            sum += ??value;
        }
    }
    else {
        assert(sum == 7);
        sum
    };
}
