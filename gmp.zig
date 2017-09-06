// Conversion of https://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=gcc&id=1
//
// Performance is identical.
//
// Compile with zig build_exe --release-fast gmp.zig --library c --library gmp

// NOTE: Compiler can't yet deduce a typedef to a single element array properly.
// We can work around this by converting the single element array type into a pointer explicitly.
// This is technically a result of C being pretty loose with its array to pointer coercion and is
// more because zig is more proper in this respect that it doesn't work.


// We can import an entire header into the current namespace using the `use` keyword.
//
// This is useful for some c libraries which already do extensive namespacing of their own.
pub use @cImport({@cInclude("gmp.h")});

var tmp1: mpz_t = undefined;
var tmp2: mpz_t = undefined;
var  acc: mpz_t = undefined;
var  den: mpz_t = undefined;
var  num: mpz_t = undefined;

fn extractDigit(nth: usize) -> usize {
    mpz_mul_ui(&tmp1[0], &num[0], nth);
    mpz_add(&tmp2[0], &tmp1[0], &acc[0]);
    mpz_tdiv_q(&tmp1[0], &tmp2[0], &den[0]);
    // NOTE: mpz_get_ui is defined inline in GMP 6.1 and parsec is not sufficient enough
    // to cope with parsing.
    //
    // mpz_get_si is not defined inline so fall back to using that.
    usize(mpz_get_si(&tmp1[0]))
}

fn eliminateDigit(d: usize) {
    mpz_submul_ui(&acc[0], &den[0], d);
    mpz_mul_ui(&acc[0], &acc[0], 10);
    mpz_mul_ui(&num[0], &num[0], 10);
}

fn nextTerm(k: usize) {
    const k2 = k * 2 + 1;

    mpz_addmul_ui(&acc[0], &num[0], 2);
    mpz_mul_ui(&acc[0], &acc[0], k2);
    mpz_mul_ui(&den[0], &den[0], k2);
    mpz_mul_ui(&num[0], &num[0], k);
}

pub fn main() -> %void {
    const std = @import("std");
    const printf = std.io.stdout.printf;

    const arg_1 = if (std.os.args.count() > 1) { std.os.args.at(1) } else "10";
    const n = std.fmt.parseUnsigned(u32, arg_1, 10) %% 10;

    mpz_init(&tmp1[0]);
    mpz_init(&tmp2[0]);
    mpz_init_set_ui(&acc[0], 0);
    mpz_init_set_ui(&den[0], 1);
    mpz_init_set_ui(&num[0], 1);

    var i: usize = 0;
    var k: usize = 1;

    // We can create an expression nearly anywhere using a block.
    while (i < n) : (k += 1) {
        nextTerm(k);
        if (mpz_cmp(&num[0], &acc[0]) > 0) {
            continue;
        }

        const d = extractDigit(3);
        if (d != extractDigit(4)) {
            continue;
        }

        i += 1;
        %%printf("{c}", '0' + u8(d));
        if (i % 10 == 0) {
            %%printf("\t{}\n", i);
        }
        eliminateDigit(d);
    }
}
