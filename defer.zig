const assert = @import("std").debug.assert;
const printf = @import("std").io.stdout.printf;

// defer will execute an expression at the end of the current scope.
fn deferExample() -> usize {
    var a: usize = 1;

    {
        defer a = 2;
        a = 1;
    }
    assert(a == 2);

    a = 5;
    a
}

test "defer basics" {
    assert(deferExample() == 5);
}

// If multiple defer statements are specified, they will be executed in
// the reverse order they were run.
fn deferUnwindExample() {
    %%printf("\n");

    defer {
        %%printf("1 ");
    }
    defer {
        %%printf("2 ");
    }
    if (false) {
        // defers are not run if they are never executed.
        defer {
            %%printf("3 ");
        }
    }
}

test "defer unwinding" {
    deferUnwindExample()
}

// The %defer keyword is similar to defer, but will only execute if the
// function returns with an error.
//
// This is especially useful in allowing a function to clean up properly
// on error, and replaces goto error handling tactics as seen in c.
error DeferError;
fn deferErrorExample(is_error: bool) -> %void {
    %%printf("\nstart of function\n");

    // This will always be executed on exit
    defer {
        %%printf("end of function\n");
    }

    %defer {
        %%printf("encountered an error!\n");
    }

    if (is_error) {
        return error.DeferError;
    }
}

test "%defer unwinding" {
    _ = deferErrorExample(false);
    _ = deferErrorExample(true);
}
