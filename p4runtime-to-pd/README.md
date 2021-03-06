# p4runtime-to-pd

`p4c` provides native support for generating the control plane API for a P4
program using [P4Runtime](https://github.com/p4lang/PI). **All new P4 programs
should use the P4Runtime tooling.**

Some legacy P4-14 programs may have been written to work with the PD control
plane tooling provided by compilers like
[p4c-bm](https://github.com/p4lang/p4c-bm). While the best path in these cases
is to update the program to use P4Runtime, it may sometimes be helpful during
the transition to generate a PD frontend from `p4c`'s output. Generating a PD
frontend also allows us to run the same tests against both `p4c-bm` and `p4c`,
which is helpful for compiler developers.

`p4runtime-to-pd` is an **unsupported** tool designed for these use cases. It
reads a P4Runtime API configuration, as generated by `p4c`, and produces a PD
frontend that matches the P4Runtime API. Nothing is guaranteed, but in practice
`p4runtime-to-pd` manages to produce a PD frontend compatible with `p4c-bm`'s
output for some fairly complex programs. (However, see [caveats](#caveats)
below.)


## Compiling

`p4runtime-to-pd` is not included in the build by default. You can enable it by
passing the appropriate flag to `configure` (typically indirectly through
`bootstrap.sh`) and then rebuilding:

```bash
./bootstrap.sh --enable-p4runtime-to-pd
cd build
make -j4
```


## Usage

Compile your P4-14 program as usual, and generate a P4Runtime API configuration.

```bash
./p4c-bm2-ss switch.p4 --p4v 14 --p4runtime-file switch.p4runtime -o switch.bmv2json
```

Create a directory to hold the generated PD frontend. `p4runtime-to-pd` won't
automatically create the directory for you.

```bash
mkdir -p switch-pd-dir
```

Feed the P4Runtime API configuration to `p4runtime-to-pd`.

```bash
./p4runtime-to-pd switch.p4runtime --pd switch-pd-dir
```

You now have PD frontend code which you can use with the legacy PD tooling.


## Caveats

There are several known incompatibilities that may cause issues with some
programs:

- There is currently no support for registers. If your program uses them,
  they'll be omitted from the generated PD frontend.

- The numeric ids we generate for some control plane objects are assigned using
  P4Runtime's algorithm. This does not match the algorithm used by `p4c-bm`, and
  importantly, *it also does not match the algorithm used by `p4c-bm2-ss`*. This
  generally shouldn't matter, since the ids mostly don't appear in the PD
  frontend API. Unfortunately, they do matter for learning quanta, which is
  likely to prevent learning from working right even though we generate a PD API
  for it.

- P4-14 programs are converted to P4-16 internally by `p4c` before they're
  compiled and, importantly, before any P4Runtime API configuration is
  generated. That means that if your program uses names which conflict with
  names defined in `core.p4` or `v1model.p4`, or are otherwise invalid in P4-16,
  the PD API we generate will be incompatible. An important special case is that
  any action named `NoAction` will be unconditionally filtered out.
