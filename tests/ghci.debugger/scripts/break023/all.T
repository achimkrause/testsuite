setTestOpts(extra_run_opts('-ignore-dot-ghci'))
setTestOpts(if_compiler_profiled(skip))

test('break023', extra_clean(['A.hs']), ghci_script, ['break023.script'])
