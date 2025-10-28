# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config

--stylecheck:error

# Workaround for cligen missing stdlib.h on Windows.
# Newer MinGW/gcc versions are stricter about implicit declarations
when defined(windows):
  switch("passC", "-Wno-implicit-function-declaration")
