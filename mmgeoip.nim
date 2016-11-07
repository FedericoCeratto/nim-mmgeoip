##
##  Copyright (C) 2016 MaxMind, Inc.
##  Copyright (C) Federico Ceratto <federico.ceratto@gmail.com>
##
##  This library is free software; you can redistribute it and/or
##  modify it under the terms of the GNU Lesser General Public
##  License as published by the Free Software Foundation; either
##  version 2.1 of the License, or (at your option) any later version.
##
##  This library is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##  Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public
##  License along with this library; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
##

{.deadCodeElim: on.}

from strutils import `%`

const
  SEGMENT_RECORD_LENGTH* = 3
  LARGE_SEGMENT_RECORD_LENGTH* = 4
  STANDARD_RECORD_LENGTH* = 3
  ORG_RECORD_LENGTH* = 4
  MAX_RECORD_LENGTH* = 4
  NUM_DB_TYPES* = (38 + 1)
  geoip_fn* = "libGeoIP.so.1"

##  128 bit address in network order

type
  #geoipv6_t* = in6_addr
  geoipv6_t* = string
  time_t = int
  off_t = int

type
  GeoIPCtx* = object
    GeoIPDatabase*: ptr FILE
    file_path*: cstring
    cache*: ptr cuchar
    index_cache*: ptr cuchar
    databaseSegments*: ptr cuint
    databaseType*: char
    mtime*: time_t
    flags*: cint
    size*: off_t
    record_length*: char
    charset*: cint             ##  0 iso-8859-1 1 utf8
    record_iter*: cint         ##  used in GeoIP_next_record
    netmask*: cint             ##  netmask of last lookup - set using depth in _GeoIP_seek_record
    last_mtime_check*: time_t
    dyn_seg_size*: off_t       ##  currently only used by the cityconfidence database
    ext_flags*: cuint          ##  bit 0 teredo support enabled

  GeoIPLookup* = object
    netmask*: cint

  GeoIPExtFlags* {.size: sizeof(cint).} = enum
    GEOIP_TEREDO_BIT = 0

  GeoIPCharset* {.size: sizeof(cint).} = enum
    GEOIP_CHARSET_ISO_8859_1 = 0, GEOIP_CHARSET_UTF8 = 1

  GeoIPRegion* = object
    country_code*: array[3, char]
    region*: array[3, char]

  GeoIPOptions* {.size: sizeof(cint).} = enum
    STANDARD = 0, MEMORY_CACHE = 1, CHECK_CACHE = 2,
    INDEX_CACHE = 4, MMAP_CACHE = 8, SILENCE = 16

  GeoIPDBTypes* {.size: sizeof(cint).} = enum
    GEOIP_COUNTRY_EDITION = 1, GEOIP_CITY_EDITION_REV1 = 2,
    GEOIP_REGION_EDITION_REV1 = 3, GEOIP_ISP_EDITION = 4, GEOIP_ORG_EDITION = 5,
    GEOIP_CITY_EDITION_REV0 = 6, GEOIP_REGION_EDITION_REV0 = 7,
    GEOIP_PROXY_EDITION = 8, GEOIP_ASNUM_EDITION = 9, GEOIP_NETSPEED_EDITION = 10,
    GEOIP_DOMAIN_EDITION = 11, GEOIP_COUNTRY_EDITION_V6 = 12,
    GEOIP_LOCATIONA_EDITION = 13, GEOIP_ACCURACYRADIUS_EDITION = 14, GEOIP_CITYCONFIDENCE_EDITION = 15, ##  unsupported
    GEOIP_CITYCONFIDENCEDIST_EDITION = 16, ##  unsupported
    GEOIP_LARGE_COUNTRY_EDITION = 17, GEOIP_LARGE_COUNTRY_EDITION_V6 = 18, GEOIP_CITYCONFIDENCEDIST_ISP_ORG_EDITION = 19, ##  unsued, but gaps are not allowed
    GEOIP_CCM_COUNTRY_EDITION = 20, ##  unsued, but gaps are not allowed
    GEOIP_ASNUM_EDITION_V6 = 21, GEOIP_ISP_EDITION_V6 = 22, GEOIP_ORG_EDITION_V6 = 23,
    GEOIP_DOMAIN_EDITION_V6 = 24, GEOIP_LOCATIONA_EDITION_V6 = 25,
    GEOIP_REGISTRAR_EDITION = 26, GEOIP_REGISTRAR_EDITION_V6 = 27,
    GEOIP_USERTYPE_EDITION = 28, GEOIP_USERTYPE_EDITION_V6 = 29,
    GEOIP_CITY_EDITION_REV1_V6 = 30, GEOIP_CITY_EDITION_REV0_V6 = 31,
    GEOIP_NETSPEED_EDITION_REV1 = 32, GEOIP_NETSPEED_EDITION_REV1_V6 = 33,
    GEOIP_COUNTRYCONF_EDITION = 34, GEOIP_CITYCONF_EDITION = 35,
    GEOIP_REGIONCONF_EDITION = 36, GEOIP_POSTALCONF_EDITION = 37,
    GEOIP_ACCURACYRADIUS_EDITION_V6 = 38

  GeoIPProxyTypes* {.size: sizeof(cint).} = enum
    GEOIP_ANON_PROXY = 1, GEOIP_HTTP_X_FORWARDED_FOR_PROXY = 2,
    GEOIP_HTTP_CLIENT_IP_PROXY = 3

  GeoIPNetspeedValues* {.size: sizeof(cint).} = enum
    GEOIP_UNKNOWN_SPEED = 0, GEOIP_DIALUP_SPEED = 1, GEOIP_CABLEDSL_SPEED = 2,
    GEOIP_CORPORATE_SPEED = 3

type
  INNER_C_UNION_2028757829* = object {.union.}
    metro_code*: cint          ##  metro_code is a alias for dma_code
    dma_code*: cint

  GeoIPRecord* = object
    country_code*: cstring
    country_code3*: cstring
    country_name*: cstring
    region*: cstring
    city*: cstring
    postal_code*: cstring
    latitude*: cfloat
    longitude*: cfloat
    ano_962705139*: INNER_C_UNION_2028757829
    area_code*: cint
    charset*: cint
    continent_code*: cstring
    netmask*: cint


var GeoIPDBFileName* {.importc: "GeoIPDBFileName", dynlib: geoip_fn.}: cstringArray

var GeoIPDBDescription* {.importc: "GeoIPDBDescription", dynlib: geoip_fn.}: array[
    NUM_DB_TYPES, cstring]

var GeoIP_custom_directory* {.importc: "GeoIP_custom_directory", dynlib: geoip_fn.}: cstring

##  Warning: do not use those arrays as doing so may break your
##  program with newer GeoIP versions

var GeoIP_country_code* {.importc: "GeoIP_country_code", dynlib: geoip_fn.}: array[256,
    array[3, char]]

var GeoIP_country_code3* {.importc: "GeoIP_country_code3", dynlib: geoip_fn.}: array[256,
    array[4, char]]

var GeoIP_country_name* {.importc: "GeoIP_country_name", dynlib: geoip_fn.}: array[256,
    cstring]

var GeoIP_utf8_country_name* {.importc: "GeoIP_utf8_country_name", dynlib: geoip_fn.}: array[
    256, cstring]

var GeoIP_country_continent* {.importc: "GeoIP_country_continent", dynlib: geoip_fn.}: array[
    256, array[3, char]]

proc GeoIP_setup_custom_directory*(dir: cstring) {.cdecl,
    importc: "GeoIP_setup_custom_directory", dynlib: geoip_fn.}

proc GeoIP_open_type*(`type`: cint; flags: cint): ptr GeoIPCtx {.cdecl,
    importc: "GeoIP_open_type", dynlib: geoip_fn.}

proc GeoIP_new*(flags: cint): ptr GeoIPCtx {.cdecl, importc: "GeoIP_new", dynlib: geoip_fn.}

proc GeoIP_open*(filename: cstring; flags: cint): ptr GeoIPCtx {.cdecl,
    importc: "GeoIP_open", dynlib: geoip_fn.}

proc GeoIP*(filename: string; flags = GeoIPOptions.STANDARD): ptr GeoIPCtx =
  ## Open a DB file and create a GeoIPCtx context
  GeoIP_open(filename.cstring, flags.cint)

##
##  WARNING: GeoIP_db_avail() checks for the existence of a database
##  file but does not check that it has the requested database revision.
##  For database types which have more than one revision (including Region,
##  City, and Cityv6), this can lead to unexpected results. Check the
##  return value of GeoIP_open_type() to find out whether a particular
##  database type is really available.
##

proc GeoIP_db_avail*(`type`: cint): cint {.cdecl, importc: "GeoIP_db_avail",
                                       dynlib: geoip_fn.}

proc delete*(gi: ptr GeoIPCtx) {.cdecl, importc: "GeoIP_delete", dynlib: geoip_fn.}

proc country_code_by_addr_gl*(gi: ptr GeoIPCtx; `addr`: cstring;
                                   gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code_by_addr_gl", dynlib: geoip_fn.}

proc country_code_by_name_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_country_code_by_name_gl", dynlib: geoip_fn.}

proc country_code3_by_addr_gl*(gi: ptr GeoIPCtx; `addr`: cstring;
                                    gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_addr_gl", dynlib: geoip_fn.}

proc country_code3_by_name_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_country_code3_by_name_gl", dynlib: geoip_fn.}

proc country_name_by_addr_gl*(gi: ptr GeoIPCtx; `addr`: cstring;
                                   gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_name_by_addr_gl", dynlib: geoip_fn.}

proc country_name_by_name_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_country_name_by_name_gl", dynlib: geoip_fn.}

proc country_name_by_ipnum_gl*(gi: ptr GeoIPCtx; ipnum: culong; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_country_name_by_ipnum_gl", dynlib: geoip_fn.}

proc country_code_by_ipnum_gl*(gi: ptr GeoIPCtx; ipnum: culong; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_country_code_by_ipnum_gl", dynlib: geoip_fn.}

proc country_code3_by_ipnum_gl*(gi: ptr GeoIPCtx; ipnum: culong;
                                     gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_ipnum_gl", dynlib: geoip_fn.}
##

proc country_name_by_ipnum_v6_gl*(gi: ptr GeoIPCtx; ipnum: geoipv6_t;
                                       gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_name_by_ipnum_v6_gl", dynlib: geoip_fn.}

proc country_code_by_ipnum_v6_gl*(gi: ptr GeoIPCtx; ipnum: geoipv6_t;
                                       gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code_by_ipnum_v6_gl", dynlib: geoip_fn.}

proc country_code3_by_ipnum_v6_gl*(gi: ptr GeoIPCtx; ipnum: geoipv6_t;
                                        gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_ipnum_v6_gl", dynlib: geoip_fn.}

proc country_code_by_addr_v6_gl*(gi: ptr GeoIPCtx; `addr`: cstring;
                                      gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code_by_addr_v6_gl", dynlib: geoip_fn.}

proc country_code_by_name_v6_gl*(gi: ptr GeoIPCtx; host: cstring;
                                      gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code_by_name_v6_gl", dynlib: geoip_fn.}

proc country_code3_by_addr_v6_gl*(gi: ptr GeoIPCtx; `addr`: cstring;
                                       gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_addr_v6_gl", dynlib: geoip_fn.}

proc country_code3_by_name_v6_gl*(gi: ptr GeoIPCtx; host: cstring;
                                       gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_name_v6_gl", dynlib: geoip_fn.}

proc country_name_by_addr_v6_gl*(gi: ptr GeoIPCtx; `addr`: cstring;
                                      gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_name_by_addr_v6_gl", dynlib: geoip_fn.}

proc country_name_by_name_v6_gl*(gi: ptr GeoIPCtx; host: cstring;
                                      gl: ptr GeoIPLookup): cstring {.cdecl,
    importc: "GeoIP_country_name_by_name_v6_gl", dynlib: geoip_fn.}

proc id_by_addr_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): cint {.
    cdecl, importc: "GeoIP_id_by_addr_gl", dynlib: geoip_fn.}

proc id_by_name_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): cint {.
    cdecl, importc: "GeoIP_id_by_name_gl", dynlib: geoip_fn.}

proc id_by_ipnum_gl*(gi: ptr GeoIPCtx; ipnum: culong; gl: ptr GeoIPLookup): cint {.
    cdecl, importc: "GeoIP_id_by_ipnum_gl", dynlib: geoip_fn.}

proc id_by_addr_v6_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): cint {.
    cdecl, importc: "GeoIP_id_by_addr_v6_gl", dynlib: geoip_fn.}

proc id_by_name_v6_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): cint {.
    cdecl, importc: "GeoIP_id_by_name_v6_gl", dynlib: geoip_fn.}

proc id_by_ipnum_v6_gl*(gi: ptr GeoIPCtx; ipnum: geoipv6_t; gl: ptr GeoIPLookup): cint {.
    cdecl, importc: "GeoIP_id_by_ipnum_v6_gl", dynlib: geoip_fn.}

proc region_by_addr_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_addr_gl", dynlib: geoip_fn.}

proc region_by_name_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_name_gl", dynlib: geoip_fn.}

proc region_by_ipnum_gl*(gi: ptr GeoIPCtx; ipnum: culong; gl: ptr GeoIPLookup): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_ipnum_gl", dynlib: geoip_fn.}

proc region_by_addr_v6_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_addr_v6_gl", dynlib: geoip_fn.}

proc region_by_name_v6_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_name_v6_gl", dynlib: geoip_fn.}

proc region_by_ipnum_v6_gl*(gi: ptr GeoIPCtx; ipnum: geoipv6_t; gl: ptr GeoIPLookup): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_ipnum_v6_gl", dynlib: geoip_fn.}
##  Warning - don't call this after GeoIP_assign_region_by_inetaddr calls

proc GeoIPRegion_delete*(gir: ptr GeoIPRegion) {.cdecl,
    importc: "GeoIPRegion_delete", dynlib: geoip_fn.}

proc assign_region_by_inetaddr_gl*(gi: ptr GeoIPCtx; inetaddr: culong;
                                        gir: ptr GeoIPRegion; gl: ptr GeoIPLookup) {.
    cdecl, importc: "GeoIP_assign_region_by_inetaddr_gl", dynlib: geoip_fn.}

proc assign_region_by_inetaddr_v6_gl*(gi: ptr GeoIPCtx; inetaddr: geoipv6_t;
    gir: ptr GeoIPRegion; gl: ptr GeoIPLookup) {.cdecl,
    importc: "GeoIP_assign_region_by_inetaddr_v6_gl", dynlib: geoip_fn.}
##  Used to query GeoIP Organization, ISP and AS Number databases

proc name_by_ipnum_gl*(gi: ptr GeoIPCtx; ipnum: culong; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_name_by_ipnum_gl", dynlib: geoip_fn.}

proc name_by_addr_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_name_by_addr_gl", dynlib: geoip_fn.}

proc name_by_name_gl*(gi: ptr GeoIPCtx; host: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_name_by_name_gl", dynlib: geoip_fn.}

proc name_by_ipnum_v6_gl*(gi: ptr GeoIPCtx; ipnum: geoipv6_t; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_name_by_ipnum_v6_gl", dynlib: geoip_fn.}

proc name_by_addr_v6_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_name_by_addr_v6_gl", dynlib: geoip_fn.}

proc name_by_name_v6_gl*(gi: ptr GeoIPCtx; name: cstring; gl: ptr GeoIPLookup): cstring {.
    cdecl, importc: "GeoIP_name_by_name_v6_gl", dynlib: geoip_fn.}
## * return two letter country code

proc GeoIP_code_by_id*(id: cint): cstring {.cdecl, importc: "GeoIP_code_by_id",
                                        dynlib: geoip_fn.}
## * return three letter country code

proc GeoIP_code3_by_id*(id: cint): cstring {.cdecl, importc: "GeoIP_code3_by_id",
    dynlib: geoip_fn.}
## * return full name of country in utf8 or iso-8859-1

proc country_name_by_id*(gi: ptr GeoIPCtx; id: cint): cstring {.cdecl,
    importc: "GeoIP_country_name_by_id", dynlib: geoip_fn.}
## * return full name of country

proc GeoIP_name_by_id*(id: cint): cstring {.cdecl, importc: "GeoIP_name_by_id",
                                        dynlib: geoip_fn.}
## * return continent of country

proc GeoIP_continent_by_id*(id: cint): cstring {.cdecl,
    importc: "GeoIP_continent_by_id", dynlib: geoip_fn.}
## * return id by country code *

proc GeoIP_id_by_code*(country: cstring): cint {.cdecl, importc: "GeoIP_id_by_code",
    dynlib: geoip_fn.}
## * return return number of known countries

proc GeoIP_num_countries*(): cuint {.cdecl, importc: "GeoIP_num_countries",
                                  dynlib: geoip_fn.}

proc database_info*(gi: ptr GeoIPCtx): cstring {.cdecl,
    importc: "GeoIP_database_info", dynlib: geoip_fn.}

proc database_edition*(gi: ptr GeoIPCtx): cuchar {.cdecl,
    importc: "GeoIP_database_edition", dynlib: geoip_fn.}

proc GeoIP_charsetFIXME*(gi: ptr GeoIPCtx): cint {.cdecl, importc: "GeoIP_charset",
                                      dynlib: geoip_fn.}

proc set_charset*(gi: ptr GeoIPCtx; charset: cint): cint {.cdecl,
    importc: "GeoIP_set_charset", dynlib: geoip_fn.}

proc enable_teredo*(gi: ptr GeoIPCtx; true_false: cint): cint {.cdecl,
    importc: "GeoIP_enable_teredo", dynlib: geoip_fn.}

proc teredo*(gi: ptr GeoIPCtx): cint {.cdecl, importc: "GeoIP_teredo", dynlib: geoip_fn.}

proc range_by_ip_gl*(gi: ptr GeoIPCtx; `addr`: cstring; gl: ptr GeoIPLookup): cstringArray {.
    cdecl, importc: "GeoIP_range_by_ip_gl", dynlib: geoip_fn.}

proc GeoIP_range_by_ip_delete*(`ptr`: cstringArray) {.cdecl,
    importc: "GeoIP_range_by_ip_delete", dynlib: geoip_fn.}
##  Convert region code to region name

proc GeoIP_region_name_by_code*(country_code: cstring; region_code: cstring): cstring {.
    cdecl, importc: "GeoIP_region_name_by_code", dynlib: geoip_fn.}
##  Get timezone from country and region code

proc GeoIP_time_zone_by_country_and_region*(country_code: cstring;
    region_code: cstring): cstring {.cdecl, importc: "GeoIP_time_zone_by_country_and_region",
                                  dynlib: geoip_fn.}
##  some v4 helper functions as of 1.4.7 exported to the public API

proc GeoIP_addr_to_num*(`addr`: cstring): culong {.cdecl,
    importc: "GeoIP_addr_to_num", dynlib: geoip_fn.}

proc GeoIP_num_to_addr*(ipnum: culong): cstring {.cdecl,
    importc: "GeoIP_num_to_addr", dynlib: geoip_fn.}
##  Internal function -- convert iso to utf8; return a malloced utf8 string.

proc GeoIP_iso_8859_1_utf8*(iso: cstring): cstring {.cdecl,
    importc: "_GeoIP_iso_8859_1__utf8", dynlib: geoip_fn.}
##  Cleans up memory used to hold file name paths. Returns 1 if successful; otherwise 0.
##

proc GeoIP_cleanup*(): cint {.cdecl, importc: "GeoIP_cleanup", dynlib: geoip_fn.}
##  Returns the library version in use. Helpful if your loading dynamically.

proc GeoIP_lib_version*(): cstring {.cdecl, importc: "GeoIP_lib_version",
                                  dynlib: geoip_fn.}
##  deprecated

proc country_code_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code_by_addr", dynlib: geoip_fn.}

proc country_code_by_name*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code_by_name", dynlib: geoip_fn.}

proc country_code3_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_addr", dynlib: geoip_fn.}

proc country_code3_by_name*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_name", dynlib: geoip_fn.}

proc country_name_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_country_name_by_addr", dynlib: geoip_fn.}

proc country_name_by_name*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_country_name_by_name", dynlib: geoip_fn.}

proc country_name_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): cstring {.cdecl,
    importc: "GeoIP_country_name_by_ipnum", dynlib: geoip_fn.}

proc country_code_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): cstring {.cdecl,
    importc: "GeoIP_country_code_by_ipnum", dynlib: geoip_fn.}

proc country_code3_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_ipnum", dynlib: geoip_fn.}

proc country_name_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): cstring {.cdecl,
    importc: "GeoIP_country_name_by_ipnum_v6", dynlib: geoip_fn.}

proc country_code_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): cstring {.cdecl,
    importc: "GeoIP_country_code_by_ipnum_v6", dynlib: geoip_fn.}

proc country_code3_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): cstring {.
    cdecl, importc: "GeoIP_country_code3_by_ipnum_v6", dynlib: geoip_fn.}

proc country_code_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code_by_addr_v6", dynlib: geoip_fn.}

proc country_code_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code_by_name_v6", dynlib: geoip_fn.}

proc country_code3_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_addr_v6", dynlib: geoip_fn.}

proc country_code3_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_country_code3_by_name_v6", dynlib: geoip_fn.}

proc country_name_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_country_name_by_addr_v6", dynlib: geoip_fn.}

proc country_name_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_country_name_by_name_v6", dynlib: geoip_fn.}

proc id_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cint {.cdecl,
    importc: "GeoIP_id_by_addr", dynlib: geoip_fn.}

proc id_by_name*(gi: ptr GeoIPCtx; host: cstring): cint {.cdecl,
    importc: "GeoIP_id_by_name", dynlib: geoip_fn.}

proc id_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): cint {.cdecl,
    importc: "GeoIP_id_by_ipnum", dynlib: geoip_fn.}

proc id_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cint {.cdecl,
    importc: "GeoIP_id_by_addr_v6", dynlib: geoip_fn.}

proc id_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): cint {.cdecl,
    importc: "GeoIP_id_by_name_v6", dynlib: geoip_fn.}

proc id_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): cint {.cdecl,
    importc: "GeoIP_id_by_ipnum_v6", dynlib: geoip_fn.}

proc region_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): ptr GeoIPRegion {.cdecl,
    importc: "GeoIP_region_by_addr", dynlib: geoip_fn.}

proc region_by_name*(gi: ptr GeoIPCtx; host: cstring): ptr GeoIPRegion {.cdecl,
    importc: "GeoIP_region_by_name", dynlib: geoip_fn.}

proc region_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): ptr GeoIPRegion {.cdecl,
    importc: "GeoIP_region_by_ipnum", dynlib: geoip_fn.}

proc region_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): ptr GeoIPRegion {.cdecl,
    importc: "GeoIP_region_by_addr_v6", dynlib: geoip_fn.}

proc region_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): ptr GeoIPRegion {.cdecl,
    importc: "GeoIP_region_by_name_v6", dynlib: geoip_fn.}

proc region_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): ptr GeoIPRegion {.
    cdecl, importc: "GeoIP_region_by_ipnum_v6", dynlib: geoip_fn.}

proc assign_region_by_inetaddr*(gi: ptr GeoIPCtx; inetaddr: culong;
                                     gir: ptr GeoIPRegion) {.cdecl,
    importc: "GeoIP_assign_region_by_inetaddr", dynlib: geoip_fn.}

proc assign_region_by_inetaddr_v6*(gi: ptr GeoIPCtx; inetaddr: geoipv6_t;
                                        gir: ptr GeoIPRegion) {.cdecl,
    importc: "GeoIP_assign_region_by_inetaddr_v6", dynlib: geoip_fn.}

proc name_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): cstring {.cdecl,
    importc: "GeoIP_name_by_ipnum", dynlib: geoip_fn.}

proc name_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_name_by_addr", dynlib: geoip_fn.}

proc name_by_name*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_name_by_name", dynlib: geoip_fn.}

proc name_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): cstring {.cdecl,
    importc: "GeoIP_name_by_ipnum_v6", dynlib: geoip_fn.}

proc name_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_name_by_addr_v6", dynlib: geoip_fn.}

proc name_by_name_v6*(gi: ptr GeoIPCtx; name: cstring): cstring {.cdecl,
    importc: "GeoIP_name_by_name_v6", dynlib: geoip_fn.}
## * GeoIP_last_netmask is deprecated - it is not thread safe

proc last_netmask*(gi: ptr GeoIPCtx): cint {.cdecl, importc: "GeoIP_last_netmask",
    dynlib: geoip_fn.}

proc range_by_ip*(gi: ptr GeoIPCtx; `addr`: cstring): cstringArray {.cdecl,
    importc: "GeoIP_range_by_ip", dynlib: geoip_fn.}


# # City

proc record_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): ptr GeoIPRecord {.cdecl,
    importc: "GeoIP_record_by_ipnum", dynlib: geoip_fn.}

proc record_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): ptr GeoIPRecord {.cdecl,
    importc: "GeoIP_record_by_addr", dynlib: geoip_fn.}

proc record_by_name*(gi: ptr GeoIPCtx; host: cstring): ptr GeoIPRecord {.cdecl,
    importc: "GeoIP_record_by_name", dynlib: geoip_fn.}

proc record_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): ptr GeoIPRecord {.
    cdecl, importc: "GeoIP_record_by_ipnum_v6", dynlib: geoip_fn.}

proc record_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): ptr GeoIPRecord {.cdecl,
    importc: "GeoIP_record_by_addr_v6", dynlib: geoip_fn.}

proc record_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): ptr GeoIPRecord {.cdecl,
    importc: "GeoIP_record_by_name_v6", dynlib: geoip_fn.}

proc record_id_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cint {.cdecl,
    importc: "GeoIP_record_id_by_addr", dynlib: geoip_fn.}

proc record_id_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cint {.cdecl,
    importc: "GeoIP_record_id_by_addr_v6", dynlib: geoip_fn.}

proc init_record_iter*(gi: ptr GeoIPCtx): cint {.cdecl,
    importc: "GeoIP_init_record_iter", dynlib: geoip_fn.}
##  returns 0 on success, 1 on failure

proc next_record*(gi: ptr GeoIPCtx; gir: ptr ptr GeoIPRecord; record_iter: ptr cint): cint {.
    cdecl, importc: "GeoIP_next_record", dynlib: geoip_fn.}

proc GeoIPRecord_delete*(gir: ptr GeoIPRecord) {.cdecl,
    importc: "GeoIPRecord_delete", dynlib: geoip_fn.}
##  NULL on failure otherwise a malloced string in utf8
##  char * GeoIP_iso_8859_1__utf8(const char *);


proc org_by_addr*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_org_by_addr", dynlib: geoip_fn.}

proc org_by_name*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_org_by_name", dynlib: geoip_fn.}

proc org_by_ipnum*(gi: ptr GeoIPCtx; ipnum: culong): cstring {.cdecl,
    importc: "GeoIP_org_by_ipnum", dynlib: geoip_fn.}

proc org_by_addr_v6*(gi: ptr GeoIPCtx; `addr`: cstring): cstring {.cdecl,
    importc: "GeoIP_org_by_addr_v6", dynlib: geoip_fn.}

proc org_by_name_v6*(gi: ptr GeoIPCtx; host: cstring): cstring {.cdecl,
    importc: "GeoIP_org_by_name_v6", dynlib: geoip_fn.}

proc org_by_ipnum_v6*(gi: ptr GeoIPCtx; ipnum: geoipv6_t): cstring {.cdecl,
    importc: "GeoIP_org_by_ipnum_v6", dynlib: geoip_fn.}


proc `$`(r: ptr GeoIPRecord): string =
  ## GeoIPRegion string representation
  "<GeoIPRecord area_code: $# charset: $# city: $# continent_code: $# country_code: $# country_code3: $# country_name: $# latitude: $# longitude: $# netmask: $# postal_code: $# region: $#>" % [ $r.area_code, $r.charset, $r.city, $r.continent_code, $r.country_code,
  $r.country_code3, $r.country_name, $r.latitude, $r.longitude,
  $r.netmask, $r.postal_code, $r.region]
