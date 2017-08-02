const assert = @import("std").debug.assert;

// Shortcomings: Due to the lack of true polymorphism, a design like this means we cannot write
// a genreic function over a BitSet of arbitrary sizes.
//
// A better strategy here is to instead take an allocator as normal, but substitute a fixed buffer
// backing allocator instead. This gives more flexibility on where the memory is stored as well.
//
// The downside is that a specific allocator is now required.
pub fn BitSet(comptime N: usize) -> type {
    struct {
        const Self = this;
        const item_count = (N >> 3) + 1;

        items: [item_count]u8,

        pub fn init() -> Self {
            Self {
                .items = []u8 {0} ** item_count,
            }
        }

        pub fn count(self: &Self) -> usize {
            var sum: usize = 0;
            var i: usize = 0;
            while (i < N) : (i += 1) {
                if (self.isSet(i)) {
                    sum += 1;
                }
            }
            sum
        }

        pub fn size(self: &Self) -> usize {
            N
        }

        pub fn isSet(self: &Self, bit: usize) -> bool {
            self.items[bit >> 3] & (1 << u8(bit & 7)) != 0
        }

        pub fn any(self: &Self) -> bool {
            var i: usize = 0;
            while (i < N) : (i += 1) {
                if (self.isSet(i)) {
                    return true;
                }
            }
            false
        }

        pub fn none(self: &Self) -> bool {
            !self.any()
        }

        pub fn all(self: &Self) -> bool {
            var i: usize = 0;
            while (i < N) : (i += 1) {
                if (!self.isSet(i)) {
                    return false;
                }
            }
            true
        }

        pub fn set(self: &Self, bit: usize) {
            self.items[bit >> 3] |= (1 << u8(bit & 7));
        }

        pub fn reset(self: &Self, bit: usize) {
            self.items[bit >> 3] &= ~(1 << u8(bit & 7));
        }

        pub fn flip(self: &Self, bit: usize) {
            self.items[bit >> 3] ^= (1 << u8(bit & 7));
        }
    }
}

test "bitset" {
    var bs = BitSet(128).init();

    assert(bs.count() == 0);
    assert(bs.size() == 128);
    assert(bs.none());
    assert(!bs.any());
    assert(!bs.all());

    assert(!bs.isSet(5));
    bs.set(5);
    assert(bs.isSet(5));
    assert(bs.any());
    assert(!bs.all());

    bs.reset(5);
    assert(!bs.isSet(5));

    bs.flip(5);
    assert(bs.isSet(5));

    var i: usize = 0;
    while (i < bs.size()) : (i += 1) {
        bs.set(i);
    }
    assert(bs.all());
    assert(bs.any());
    assert(!bs.none());
}
