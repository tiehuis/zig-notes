// An error in zig is simply an error code and does not carry any extra information with it.
// It is analogous to how error codes are used in C, except it is built in to the language and
// does not require planning usable ranges of output values and other messy details.
//
// These must be declared at the top-level.
error BadError;

const printf = @import("std").io.stdout.printf;

test "result" {
    // A result type contains either a value, or one of many different error types.
    //
    // The `%` sigil is used to denote a result.
    var x: %u8 = 0;

    // We can set a result type to any error we want.
    x = error.BadError;

    // We can test for the prescence of an error value in a similar way as we can with an optional
    // value. The main difference here is that the else case (error) we can get the unwrapped error
    // value as well.
    if (x) |unwrapped_x| {
        // X was not an error.
    } else |err| {
        // error.BadError!
    }

    // A current limitation is that we require the else to determine that this is evaluation an
    // error condition.
    // TODO: Shouldn't be a requirement.
    if (x) |ok| {
        %%printf("{}\n", ok);
    } else |err| {
        // Errors can be printed and their text representation will be shown.
        // We can get the string representation directly using the @errorName builtin.
        %%printf("{}\n", err);
    }

    // We currently cannot switch an error but we will be able to do this in order to determine
    // the specific type of error sometime.
    // switch (x) {
    //     error.BadError => (),
    //     else => {},
    // }

    if (x) {
    } else |err| {
        // Errors can be compared in this way if needed.
        if (err == error.BadError) {
            %%printf("was bad\n");
        }
    }

    // Still cannot compare against an error union directly however, similar to switch.
    // if (x == error.BadError) {
    // }
}
