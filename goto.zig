const assert = @import("std").debug.assert;

// goto is present, but should typically not be used.
// error-handling should instead be performed via defer.
test "goto" {
    var value = false;
    goto label;
    value = true;

label:
    assert(value == false);
}
