test "optional" {
    // An Optional type is one which may or may not exist.
    //
    // null is used to refer to the empty state.
    //
    // The `?` sigil is used to denote an optional.
    var x: ?u8 = null;

    // We can set the variable to have an actual value as well.
    x = 5;

    // To unwrap a nullable, we use the ?? operator.
    const y: u8 = ??x;

    var z: u8 = undefined;

    // Usually one will want to test if the value is null or not. We can test and unwrap if it
    // matches using the following syntax.
    if (x) |unwrapped_x| {
        z = unwrapped_x;
    } else {
        // Set a default instead
        z = 5;
    }

    // This is simply sugar for the following.
    if (x != null) {
        const unwrapped_x = ??x;
        z = unwrapped_x;
    } else {
        z = 5;
    }

    // This can be simplified with the following syntax, which says unwrap y, and return its inner
    // value if unset else the default of 5.
    var a: u8 = x ?? 5;
}
