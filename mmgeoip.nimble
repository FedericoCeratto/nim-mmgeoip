# Package

version       = "0.1.0"
author        = "Federico Ceratto"
description   = "MaxMind GeoIP library"
license       = "LGPLv2.1"

# Dependencies

requires "nim >= 0.15.2"

task test, "basic test":
  exec "nim c -p:. -d:nimDebugDlOpen -d:release -r tests/basic_test.nim"
