import unittest
from strutils import `%`
from times import epochTime

import mmgeoip

suite "geoip":

  test "GeoIP.dat":
    let g = GeoIP("/usr/share/GeoIP/GeoIP.dat")
    assert g.country_code3_by_addr("8.8.8.8") == "USA"
    assert g.country_code_by_addr("8.8.8.8") == "US"
    assert g.country_name_by_addr("8.8.8.8") == "United States"
    assert g.id_by_addr("8.8.8.8") == 225

    var mask: GeoIPLookup = GeoIPLookup(netmask:0)
    let code = g.id_by_addr_gl("8.8.8.8", addr mask)
    assert GeoIP_code_by_id(code) == "US"

    let t0 = epochTime()
    for _ in 0..100_000:
      discard g.country_code_by_addr("8.8.8.8")
    echo "country_code_by_addr avg time: $# us" % $((epochTime() - t0) * 10)

    g.delete()

  test "GeoIP.dat MEMORY_CACHE":
    let g = GeoIP("/usr/share/GeoIP/GeoIP.dat", MEMORY_CACHE)
    assert g.country_code3_by_addr("8.8.8.8") == "USA"

    var t0 = epochTime()
    for _ in 0..1_000_000:
      discard g.country_code_by_addr("8.8.8.8")
    echo "country_code_by_addr in memory avg time: $# us" % $((epochTime() - t0))

    g.delete()

  test "GeoLiteCity.dat":
    let g = GeoIP("/usr/share/GeoIP/GeoLiteCity.dat")
    let r = g.record_by_addr("8.8.8.8")
    assert r.city == "Mountain View"
    assert r.latitude == 37.38600158691406
    assert $r.longitude ==  "-122.0838012695312"
    assert r.area_code == 650
    assert r.country_code == "US"
    assert r.country_code3 == "USA"
    assert r.postal_code == "94035"
    assert r.region == "CA"
    g.delete()

  test "GeoLiteCity.dat":
    let g = GeoIP("/usr/share/GeoIP/GeoLiteCity.dat", MEMORY_CACHE)
    var t0 = epochTime()
    for _ in 0..1_000_000:
      discard g.record_by_addr("8.8.8.8")
    echo "record_by_addr in memory avg time: $# us" % $((epochTime() - t0))
    g.delete()

  test "GeoIPASNum.dat":
    let g = GeoIP("/usr/share/GeoIP/GeoIPASNum.dat")
    assert g.org_by_addr("8.8.8.8") == "AS15169 Google Inc."
    g.delete()

  test "GeoIPASNumv6.dat":
    let g = GeoIP("/usr/share/GeoIP/GeoIPASNumv6.dat")
    assert g.org_by_addr_v6("2a00:1450:400b:c03::8b") == "AS15169 Google Inc."
    g.delete()
