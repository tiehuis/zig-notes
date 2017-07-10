const assert = @import("std").debug.assert;

test "while basics" {
    // while loops work the same as in other languages
    while (false) {
        // Break and continue work as expected.
        if (true) {
            break;
        }
        if (true) {
            continue;
        }
    }

    // Since for loops are different than most other C-like
    // languages, we typically use a while loop for similar behavior.
    //
    // for (int i = 0; i < 10; i++) becomes the following
    { var i: usize = 0; while (i < 10) : (i += 1) {
        const my_i = i;
    }}

    // note the precondition, this runs after each run of the
    // while body. More complex blocks can be used as an expression.
    var i1: usize = 1;
    var j1: usize = 1;
    while (i1 * j1 < 2000) : ({ i1 *= 2; j1 *= 3; }) {
        const my_ij1 = i1 * j1;
    }
}

test "while else" {
    // An else statement on a while loop is executed after the loop
    // has finished executing successfully.
    var i: usize = 0;
    while (i < 10) : (i += 1) {

    }
    else {
        i = 30;
    }
    assert(i == 30);

    // On abnormal exit, the else branch will not be executed.
    var j: usize = 0;
    while (j < 10) : (j += 1) {
        if (j == 5) {
            break;
        }
    }
    else {
        j = 20;
    }

    assert(j == 5);
}

test "while null capture" {
    // A while loop also supports capturing a stream of values until a
    // nullable is encounted.
    var sum1: u32 = 0;
    numbers_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum1 += value;
    }
    assert(sum1 == 3);

    // The else branch is allowed on nullable iteration. In this case, it will
    // be executed on the first invalid result encountered.
    var sum2: u32 = 0;
    numbers_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum2 += value;
    }
    else {
        assert(sum1 == 3);
    }

    // This is more useful on an error sequence, and allows capturing the
    // error value.
    var sum3: u32 = 0;
    numbers_left = 3;
    while (eventuallyErrorSequence()) |value| {
        sum3 += value;
    }
    else |err| {
        assert(err == error.ReachedZero);
    }
}

var numbers_left: u32 = undefined;
fn eventuallyNullSequence() -> ?u32 {
    return if (numbers_left == 0) {
        null
    } else {
        numbers_left -= 1;
        numbers_left
    }
}
error ReachedZero;
fn eventuallyErrorSequence() -> %u32 {
    return if (numbers_left == 0) {
        error.ReachedZero
    } else {
        numbers_left -= 1;
        numbers_left
    }
}

test "while expression" {
    // One notable difference to be aware of is that while is an expression
    // itself. A value can be given to a break statement and the else prong
    // and captured by a variable.
    var i: usize = 0;
    const r = while (i < 10) : (i += 1) {
        if (i == 4) {
            break i;
        }
    } else {
        usize(5)
    };

    assert(r == 4);
}
