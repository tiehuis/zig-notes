const std = @import("std");
const io = std.io;
const math = std.math;
const mem = std.mem;
const assert = std.debug.assert;
const ArrayList = std.ArrayList;

/// A simple sieve of eratosthenes.
// TODO: Demonstrate a bitsieve here.
const Sieve = struct {
    allocator: &mem.Allocator,
    data: []bool,
    limit: u64,

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
            .limit = n,
        }
    }

    pub fn isPrime(self: &const Sieve, n: u64) -> bool {
        if (n < 2 or n > self.limit) {
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

test "eratosthenes sieve" {
    var sieve = %%Sieve.init(&al.c_allocator, 200);
    defer sieve.deinit();

    const primes = []const u8 {
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59,
        61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131,
        137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199
    };

    for (primes) |p| {
        assert(sieve.isPrime(p));
    }

    // Out of range values always return false.
    assert(!sieve.isPrime(997));
}

/// A segmented sieve implementation.
// TODO: Handle lo value non-zero case + explain and cleanup more.
const SegmentedSieve = struct {
    allocator: &mem.Allocator,
    // Unlike the eratosthenes sieve, this stores the actual prime values.
    data: ArrayList(u64),
    hi: u64,
    lo: u64,

    pub fn init(allocator: &mem.Allocator, _lo: u64, hi: u64) -> %SegmentedSieve {
        assert(hi >= _lo);

        // List of resulting primes.
        var data = ArrayList(u64).init(allocator);
        %defer data.deinit();
        %return data.append(2);

        const hi_sqrt = u64(math.sqrt(f64(hi)));
        const segment_size = math.max(hi_sqrt, u64(8192));   // Use L1 cache size

        // Base primes used for marking.
        var ps = %return Sieve.init(allocator, hi_sqrt);
        defer ps.deinit();

        // Sieving marker values.
        var sieve = %return allocator.alloc(bool, segment_size);
        defer allocator.free(sieve);

        var base_primes = ArrayList(u64).init(allocator);
        defer base_primes.deinit();

        // Offsets of base primes into the current segment.
        var next_primes = ArrayList(u64).init(allocator);
        defer next_primes.deinit();

        // Initial prime position
        var s = u64(3);
        var n = u64(3);

        // Sieve across a single segment and determine primes within.
        var lo = _lo;
        while (lo <= hi) : (lo += segment_size) {
            mem.set(bool, sieve, true);

            const segment_hi = math.min(lo + segment_size - 1, hi);

            // Add new primes to sieve which are not in list
            while (s * s <= segment_hi) : (s += 2) {
                if (ps.isPrime(s)) {
                    %return base_primes.append(s);
                    // Store the next offset into the next segment for this prime.
                    %return next_primes.append(s * s - lo);
                }
            }

            // Perform the sieving for this segment
            for (next_primes.toSlice()) |*p, i| {
                const k = 2 * base_primes.toSliceConst()[i];
                var j = *p;
                while (j < segment_size) : (j += k) {
                    sieve[j] = false;
                }

                // Compute the offset for this prime for the next segment
                *p = j - segment_size;
            }

            // Do something with the recently found primes of this segment
            while (n <= segment_hi) : (n += 2) {
                if (sieve[n - lo]) {
                    %return data.append(n);
                }
            }
        }

        SegmentedSieve {
            .allocator = allocator,
            .data = data,
            .lo = lo,
            .hi = hi,
        }
    }

    /// Return a slice to the prime values stored.
    pub fn primes(self: &const SegmentedSieve) -> []const u64 {
        self.data.toSliceConst()
    }

    pub fn deinit(self: &SegmentedSieve) {
        self.data.deinit();
    }
};

test "segmented sieve" {
    var reference = %%Sieve.init(&al.c_allocator, 10000);
    defer reference.deinit();

    var segmented = %%SegmentedSieve.init(&al.c_allocator, 0, 10000);
    defer segmented.deinit();

    for (segmented.primes()) |p| {
        assert(reference.isPrime(p));
    }
}
