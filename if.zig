// An if statement has uses in zig.
const assert = @import("std").debug.assert;

test "if simple" {
    // The first use is simply to test general boolean expressions against true.
    const a: u32 = 5;
    const b: u32 = 4;
    if (a != b) {
        assert(true);
    } else if (a == 9) {
        unreachable
    } else {
        unreachable
    }

    // If statements are used in place of the C ternary statement, since they
    // themselves are expressions.
    const result = if (a != b) 47 else 3089;
    assert(result == 47);
}

test "if try" {
    // The second use is as a test statement, comparing a possibly
    // null optional value for existence.

    const a: ?u32 = 0;
    if (a) |value| {
        assert(value == 0);
    } else {
        unreachable;
    }

    const b: ?u32 = null;
    if (b) |value| {
        unreachable;
    } else {
        assert(true);
    }

    // The else is not strictly required.
    if (a) |value| {
        assert(value == 0);
    }

    // To test against null only, just use the simple if case.
    if (b == null) {
        assert(true);
    }

    // We can access the value by reference using a * capture.
    var c: ?u32 = 3;
    if (c) |*value| {
        *value = 2;
    }

    if (c) |value| {
        assert(value == 2);
    }
}

error BadValue;
error LessBadValue;
test "if test" {
    // The third use is as a try statement, checking a possibly
    // bad error value.

    // This is the same as the test statement, but the error has a capture
    // group on the else branch.
    const a: %u32 = 0;
    if (a) |value| {
        assert(value == 0);
    } else |err| {
        unreachable
    }

    const b: %u32 = error.BadValue;
    if (b) |value| {
        unreachable
    } else |err| {
        assert(err == error.BadValue);
    }

    // The else is strictly required.
    // NOTE: The compiler could work this out based on the type of a.
    if (a) |value| {
        assert(value == 0);
    } else |_| {}

    // If wanting to check only the error value, use an empty block expression.
    if (b) |_| {} else |err| {
        assert(err == error.BadValue);
    }

    // We can access the value by reference using a * capture, same as the
    // test expression case.
    var c: %u32 = 3;
    if (c) |*value| {
        *value = 9;
    } else |err| {}

    if (c) |value| {
        assert(value == 9);
    } else |err| {}
}
