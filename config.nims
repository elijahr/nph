# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config

--stylecheck:error

# Workaround for cligen missing stdlib.h on Windows.
# Newer MinGW/gcc versions treat implicit declarations as errors by default (gcc 14+)
# First demote from error to warning, then suppress the warning
when defined(windows):
  switch("passC", "-Wno-error=implicit-function-declaration -Wno-implicit-function-declaration")
