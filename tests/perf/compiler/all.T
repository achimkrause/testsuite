def no_lint(opts):
   opts.compiler_always_flags = \
       filter(lambda opt: opt != '-dcore-lint' and opt != '-dcmm-lint', opts.compiler_always_flags)

setTestOpts(no_lint)


test('T1969',
     [if_wordsize(32,
          compiler_stats_num_field('peak_megabytes_allocated', 13,
                                                               19)),
                             # expected value: 14 (x86/Windows 17/05/10)
                             #                 15 (x86/OS X)
                             #                 19 (x86/OS X)
      if_wordsize(64,
          compiler_stats_num_field('peak_megabytes_allocated', 22,
                                                               28)),
                                             # expected value: 28 (amd64/Linux)
                                             # expected value: 34 (amd64/Linux)
                                             # 2012-09-20      23 (amd64/Linux)
                                             # 2012-10-03      25 (amd64/Linux if .hi exists)
      if_wordsize(32,
          compiler_stats_num_field('max_bytes_used', 4000000,
                                                     7000000)),
                             # expected value: 6707308 (x86/OS X)
                             #                 5717704 (x86/Windows 17/05/10)
                             #                 6149572 (x86/Linux, 31/12/09)
      if_wordsize(64,
          compiler_stats_range_field('max_bytes_used', 9000000, 20)),
                                  # looks like the peak is around 10M, but we're
                                  # unlikely to GC exactly on the peak.
                                  # varies quite a lot with CLEANUP and BINDIST,
                                  # hence 10% range.
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 303930948, 1)),
                        # expected value: 215582916 (x86/Windows)
                        #                 221667908 (x86/OS X)
                        #                 274932264 (x86/Linux)
                        # 2012-10-08:     303930948 (x86/Linux, new codegen)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 642594312, 1)),
                                    # 17/11/2009:     434,845,560 (amd64/Linux)
                                    # 08/12/2009:     459,776,680 (amd64/Linux)
                                    # 17/05/2010:     519,377,728 (amd64/Linux)
                                    # 05/08/2011:     561,382,568 (amd64/OS X)
                                    # 16/07/2012:     589,168,872 (amd64/Linux)
                                    # 20/07/2012:     595,936,240 (amd64/Linux)
                                    # 23/08/2012:     606,230,880 (amd64/Linux)
                                    # 29/08/2012:     633,334,184 (amd64/Linux)
                                    #                 (^ new codegen)
                                    # 18/09/2012:     641,959,976 (amd64/Linux)
                                    # 19/10/2012:     661,832,592 (amd64/Linux)
                                    #                 (^ -fPIC turned on)
                                    # 23/10/2012:     642,594,312 (amd64/Linux)
                                    #                 (^ -fPIC turned off again)
      only_ways(['normal']),
      extra_hc_opts('-dcore-lint -static')
          # Leave -dcore-lint on for this one test, so that we have something
          # that will catch a regression in -dcore-lint performance.
      ],
     compile,
     [''])

# This one tests for the space leak in the native code generator,
# where it holds onto the entire asm output until the end.  The space
# leak reappears from time to time, so it's a good idea to have a test
# for it.  The residency of this test will jump by 10MB to 40MB or so
# on x86-64 if the space leak appears.

# Only run this one if we have an NCG:
if 'optasm' in config.compile_ways:
   conf_3294 = only_ways(['normal'])
else:
   conf_3294 = skip

test('T3294',
     [if_wordsize(32,
          compiler_stats_num_field('max_bytes_used', 12000000,
                                                     20000000)),
                                   # expected value: 17725476 (x86/OS X)
				   #                 14593500 (Windows)
      if_wordsize(64,
          compiler_stats_range_field('max_bytes_used', 37724352, 15)),
                                   # prev:           25753192 (amd64/Linux)
                                   # 29/08/2012:     37724352 (amd64/Linux)
                                   #  (increase due to new codegen, see #7198)
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 1373514844, 5)),
                                   # previous:     815479800  (x86/Linux)
                                   # (^ increase due to new codegen, see #7198)
                                   # 2012-10-08:   1373514844 (x86/Linux)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 2717327208, 5)),
                                   # old:        1,357,587,088 (amd64/Linux)
                                   # 29/08/2012: 2,961,778,696 (amd64/Linux)
                                   # (^ increase due to new codegen, see #7198)
                                   # 18/09/2012: 2,717,327,208 (amd64/Linux)
      conf_3294
      ],
     compile,
     [''])

test('T4801',
     [ # expect_broken(5224),
       # temporarily unbroken (#5227)
      if_wordsize(32,
          compiler_stats_range_field('peak_megabytes_allocated', 30, 20)),

      if_wordsize(64,
          compiler_stats_range_field('peak_megabytes_allocated', 64, 20)),
                   # prev:       50 (amd64/Linux)
                   # 19/10/2012: 64 (amd64/Linux) (REASON UNKNOWN!)

      # expected value: 58 (amd64/OS X):
      if_platform('x86_64-apple-darwin',
          compiler_stats_num_field('peak_megabytes_allocated', 56, 60)),
      # expected value: 228286660 (x86/OS X)
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 185669232, 10)),

      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 392409984, 10)),
                   # prev:       360243576 (amd64/Linux)
                   # 19/10/2012: 447190832 (amd64/Linux) (-fPIC turned on)
                   # 19/10/2012: 392409984 (amd64/Linux) (-fPIC turned off)

      # expected value: 510938976 (amd64/OS X):
      if_platform('x86_64-apple-darwin',
          compiler_stats_num_field('bytes allocated', 490000000,
                                                      530000000)),

      if_wordsize(32,
      #                    expected value: x86/OS X:  9651948
          compiler_stats_num_field('max_bytes_used',  8000000,
                                                     12000000)),
      # expected value: 10290952 (windows)
      if_wordsize(64,
          compiler_stats_range_field('max_bytes_used', 18619912, 15)),
                # prev:       20486256 (amd64/OS X)
                # 30/08/2012: 17305600--20391920 (varies a lot)
                # 19/10/2012: 26882576 (-fPIC turned on)
                # 19/10/2012: 18619912 (-fPIC turned off)
      if_platform('x86_64-apple-darwin',
          compiler_stats_num_field('max_bytes_used', 20000000,
                                                     23000000)),
       only_ways(['normal']),
       extra_hc_opts('-static')
      ],
     compile,
     [''])

test('T3064',
     [# expect_broken( 3064 ),
      # expected value: 14 (x86/Linux 28-06-2012):
      if_wordsize(32,
          compiler_stats_range_field('peak_megabytes_allocated', 14, 30)),
      # expected value: 18 (amd64/Linux):
      if_wordsize(64,
          compiler_stats_num_field('peak_megabytes_allocated', 20, 28)),
      # expected value: 56380288 (x86/Linux) (28/6/2011)
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 124952112, 10)),
      # expected value: 73259544 (amd64/Linux) (28/6/2011):
      if_wordsize(64,
          compiler_stats_num_field('bytes allocated', 200000000,
                                                      280000000)),
      # expected value: 2247016 (x86/Linux) (28/6/2011):
      if_wordsize(32,
          compiler_stats_range_field('max_bytes_used', 5511604, 20)),
      # expected value: 4032024 (amd64/Linux, intree) (28/6/2011):
      if_wordsize(64,
          compiler_stats_num_field('max_bytes_used', 8000000,
                                                     14000000)),
       only_ways(['normal'])
      ],
     compile,
     [''])

test('T4007',
     normal,
     run_command,
     ['$MAKE -s --no-print-directory T4007'])

test('T5030',
     [
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 259547660, 10)),
                     # previous:    196457520
                     # 2012-10-08:  259547660 (x86/Linux, new codegen)
      # expected value: 346750856 (amd64/Linux):
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 530000000, 10)),
       only_ways(['normal'])
      ],
     compile,
     ['-fcontext-stack=300'])

test('T5631',
     [if_wordsize(32, # sample from x86/Linux
          compiler_stats_range_field('bytes allocated', 392904228, 10)),
      # expected value: 774,595,008 (amd64/Linux):
      if_wordsize(64,
          compiler_stats_num_field('bytes allocated', 600000000,
                                                      900000000)),
       only_ways(['normal'])
      ],
     compile,
     [''])

test('parsing001',
     [# expected value: ?
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 274000576, 10)),
      # expected value: 587079016 (amd64/Linux):
      if_wordsize(64,
          compiler_stats_num_field('bytes allocated', 540000000,
                                                      620000000)),
       only_ways(['normal']),
      ],
     compile_fail, [''])


test('T783',
     [ only_ways(['normal']),  # no optimisation for this one
      # expected value: 175,569,928 (x86/Linux)
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 226907420, 10)),
                           # 2012-10-08: 226907420 (x86/Linux)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 436927840, 10)),
                           # prev:       349,263,216 (amd64/Linux)
                           # 07/08/2012: 384,479,856 (amd64/Linux)
                           # 29/08/2012: 436,927,840 (amd64/Linux)
      extra_hc_opts('-static')
      ],
      compile,[''])

test('T5321Fun',
     [ only_ways(['normal']),  # no optimisation for this one
      # sample from x86/Linux
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 344416344, 10)),
                                         # prev:       300000000
                                         # 2012-10-08: 344416344
                                         #  (increase due to new codegen)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 713385808, 10))
                                         # prev:       585,521,080
                                         # 29/08/2012: 713,385,808
                                         #  (increase due to new codegen)
      ],
      compile,[''])

test('T5321FD',
     [ only_ways(['normal']),  # no optimisation for this one
      if_wordsize(32,
          compiler_stats_range_field('bytes allocated', 240302920, 10)),
                                         # prev:       213380256
                                         # 2012-10-08: 240302920 (x86/Linux)
                                         #  (increase due to new codegen)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 492905640, 10))
                                         # prev:       418,306,336
                                         # 29/08/2012: 492,905,640
                                         #  (increase due to new codegen)
      ],
      compile,[''])

test('T5642',
     [ only_ways(['normal']),
      if_wordsize(32, # sample from x86/Linux
          compiler_stats_range_field('bytes allocated',  650000000, 10)),
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 1300000000, 10))
      ],
      compile,['-O'])

test('T5837',
     [ only_ways(['normal']),
      if_wordsize(32, # sample from x86/Linux
          compiler_stats_range_field('bytes allocated', 40000000, 10)),

      # sample: 3926235424 (amd64/Linux, 15/2/2012)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 81879216, 10))
	  				   # 2012-10-02 81879216
                                           # 2012-09-20 87254264 amd64/Linux
      ],
      compile_fail,['-fcontext-stack=50'])

test('T6048',
     [ only_ways(['optasm']),
      if_wordsize(32, # sample from x86/Linux
          compiler_stats_range_field('bytes allocated', 48887164, 10)),
                                           # prev:       38000000
                                           # 2012-10-08: 48887164 (x86/Linux)
      if_wordsize(64,
          compiler_stats_range_field('bytes allocated', 97247032, 10))
                                           # 18/09/2012 97247032 amd64/Linux
      ],
      compile,[''])
