const std = @import("std");
const mem = std.mem;

// Memory allocators in zig are much more up front than in most other languages.
//
// The data structures in the standard library do not have a default allocator, one must be provided
// when initializing the structure.
//
// This provides more flexibility when allocating memory and makes things such as using multiple
// allocators in a single unit of code much easier, at the cost of a slightly more involved
// setup.

test "debug allocator" {
    // The standard library has a debug allocator available which is simply backed by an array
    // of memory in the program. This is useful when testing small things but shouldn't be used in
    // a general purpose application.
    //
    // Most languages the standard allocator would be fixed and would not be easily replacable.
    var arr = std.ArrayList(i32).init(&std.debug.global_allocator);
    defer arr.deinit();
    %%arr.append(5);
}

// We can create our own allocator by creating an instance of a `std.mem.Allocator` struct.
//
// This requires us to implement a alloc, realloc and free function.
//
// This example wraps the default c system allocator.
pub var c_allocator = mem.Allocator {
    .allocFn = cAlloc,
    .reallocFn = cRealloc,
    .freeFn = cFree,
};

error NoMem;

const c = @cImport({@cInclude("stdlib.h")});

// The C stdlib returns a pointer to memory `&c_void` so we reinterpret the data as a u8 slice with
// an implicit length before giving it back to the user.
fn cAlloc(self: &mem.Allocator, n: usize) -> %[]u8 {
    @ptrCast(&u8, c.malloc(c.size_t(n)) ?? return error.NoMem)[0..n]
}

fn cRealloc(self: &mem.Allocator, old_mem: []u8, new_size: usize) -> %[]u8 {
    // Zig currently allows implementors to call realloc on an empty slice. This causes a slight
    // issue when interfacing with C since there will be no existing pointer to memory we can use.
    if (old_mem.len == 0) {
        cAlloc(self, new_size)
    } else {
        const old_ptr = @ptrCast(&c_void, &old_mem[0]);
        @ptrCast(&u8, c.realloc(old_ptr, c.size_t(new_size)) ?? return error.NoMem)[0..new_size]
    }
}

fn cFree(self: &mem.Allocator, old_mem: []u8) {
    // Same deal as realloc. If the length of the memory is zero, then we won't be able to get a
    // pointer to any data.
    if (old_mem.len != 0) {
        c.free(@ptrCast(&c_void, &old_mem[0]));
    }
}

test "custom allocator" {
    // Our usage of an ArrayList is exactly the same, except now we are backed by the C system
    // allocator!
    var arr = std.ArrayList(i32).init(&c_allocator);
    defer arr.deinit();
    %%arr.append(5);
}
