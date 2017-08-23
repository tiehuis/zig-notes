const std = @import("std");
const io = std.io;
const math = std.math;
const mem = std.mem;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

/// A simple sieve of eratosthenes.
const Sieve = struct {
    allocator: &mem.Allocator,
    data: []bool,

    pub fn init(allocator: &mem.Allocator, n: u64) -> %Sieve {
        var data = %return allocator.alloc(bool, n + 1);
        mem.set(bool, data, true);

        var i = usize(2);
        while (i * i <= n) : (i += 1) {
            if (data[i]) {
                var j = 2 * i;
                while (j <= n) : (j += i) {
                    data[j] = false;
                }
            }
        }

        Sieve {
            .allocator = allocator,
            .data = data,
        }
    }

    pub fn isPrime(self: &const Sieve, n: u64) -> bool {
        if (n < 2) {
            false
        } else {
            self.data[usize(n)]
        }
    }

    pub fn deinit(self: &Sieve) {
        self.allocator.free(self.data);
    }
};

var al = @import("allocators.zig");

test "simple eratosthenes" {
    const sieve = %%Sieve.init(&al.c_allocator, 1000);

    assert(sieve.isPrime(2));
    assert(sieve.isPrime(3));
    assert(sieve.isPrime(5));
    assert(sieve.isPrime(7));
    assert(sieve.isPrime(97));
    assert(!sieve.isPrime(96));
}

