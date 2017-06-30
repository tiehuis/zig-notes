// Fifo RingBuffer usable as some sort of input-queue.
//
// Fixed stack-allocation is specified at compile-time. A suitable purpose for a structure like this
// could for something like a uart input communication line.
//
// An efficient deque is implemented in a similar way, instead of being cyclic it would perform
// some smart resizing and shuffling of data/indices.
pub fn RingBuffer(comptime T: type, comptime size: usize) -> type {
    struct {
        // We must bind the explicit struct to a separate variable since we cannot instantiate a
        // struct directly using the this value.
        const Self = this;

        // Can define constant and vars statically for all instances of a struct.
        // The only difference here is these are namespaced for the struct type itself.
        const capacity = size;

        // Member variables of the struct are not preceeded by a binding type.
        items: [size]T,
        head: usize,
        len: usize,

        pub fn init() -> Self {
            Self {
                .items = undefined,
                .head = 0,
                .len = 0,
            }
        }

        pub fn offset(self: &const Self, index: usize) -> usize {
            (self.head + index) % capacity
        }

        pub fn append(self: &Self, value: T) {
            self.items[self.offset(self.len)] = value;
            self.len += 1;
        }

        pub fn peek(self: &Self) -> ?T {
            if (self.len > 0) self.items[self.offset(self.len - 1)] else null
        }

        pub fn next(self: &Self) -> ?T {
            if (self.len == 0) {
                return null;
            }

            const value = self.items[self.offset(0)];
            self.head = self.offset(1);
            value
        }
    }
}

var rb = RingBuffer(u8, 128).init();

pub fn main() -> %void {
    const printf = @import("std").io.stdout.printf;

    rb.append(5);

    %%printf("{}\n", rb.peek());    // 5

    {
        var i: u8 = 0;
        while (i < 10) : (i += 1) {
            rb.append(2 * i);
        }
    }

    {
        // Can perform a read-only pass using the offset function.
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            %%printf("{} ", rb.items[rb.offset(i)]);
        }
        %%printf("\n");
    }

    %%printf("{}\n", rb.next());    // 5
    %%printf("{}\n", rb.next());    // 0
    %%printf("{}\n", rb.next());    // 2

    {
        // Can add an 'infinite' number of items.
        var i: usize = 0;
        while (i < 1000) : (i += 1) {
            // Use overflowing multiplication operator since this will otherwise exceed the u8 range.
            // Also use the @truncate builtin to take just the bits that will fit in a u8, discarding
            // the rest.
            const in = 3 *% @truncate(u8, i);
            rb.append(in);
        }

        // The output here will be completely different. Our original head is overwriten (4).
        %%printf("{}\n", rb.next());
    }
}
