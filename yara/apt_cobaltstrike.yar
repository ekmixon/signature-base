/*
   LICENSE
   Copyright (C) 2015 JPCERT Coordination Center. All Rights Reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following acknowledgments and disclaimers.
   2. Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following acknowledgments and disclaimers
      in the documentation and/or other materials provided with the distribution.
   3. Products derived from this software may not include "JPCERT Coordination
      Center" in the name of such derived product, nor shall "JPCERT
      Coordination Center"  be used to endorse or promote products derived
      from this software without prior written permission. For written
      permission, please contact pr@jpcert.or.jp.

   ACKNOWLEDGMENTS AND DISCLAIMERS
   Copyright (C) 2015 JPCERT Coordination Center

   This software is based upon work funded and supported by the Ministry of
   Economy, Trade and Industry.

   Any opinions, findings and conclusions or recommendations expressed in this
   software are those of the author(s) and do not necessarily reflect the views
   of the Ministry of Economy, Trade and Industry.

   NO WARRANTY. THIS JPCERT COORDINATION CENTER SOFTWARE IS FURNISHED ON
   AN "AS-IS" BASIS. JPCERT COORDINATION CENTER MAKES NO WARRANTIES OF
   ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT
   NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY,
   EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE SOFTWARE. JPCERT
   COORDINATION CENTER DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH
   RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.

   This software has been approved for public release and unlimited distribution.
*/

rule APT_CobaltStrike_Beacon_Indicator {
   meta:
      description = "Detects CobaltStrike beacons"
      author = "JPCERT"
      reference = "https://github.com/JPCERTCC/aa-tools/blob/master/cobaltstrikescan.py"
      date = "2018-11-09"
   strings:
      $v1 = { 73 70 72 6E 67 00 }
      $v2 = { 69 69 69 69 69 69 69 69 }
   condition:
      uint16(0) == 0x5a4d and filesize < 300KB and all of them
}

rule HKTL_CobaltStrike_Beacon_Strings {
   meta:
      author = "Elastic"
      description = "Identifies strings used in Cobalt Strike Beacon DLL"
      reference = "https://www.elastic.co/blog/detecting-cobalt-strike-with-memory-signatures"
      date = "2021-03-16"
   strings:
      $s1 = "%02d/%02d/%02d %02d:%02d:%02d"
      $s2 = "Started service %s on %s"
      $s3 = "%s as %s\\%s: %d"
   condition:
      2 of them
}

rule HKTL_CobaltStrike_Beacon_XOR_Strings {
   meta:
      author = "Elastic"
      description = "Identifies XOR'd strings used in Cobalt Strike Beacon DLL"
      reference = "https://www.elastic.co/blog/detecting-cobalt-strike-with-memory-signatures"
      date = "2021-03-16"
      /* Used for beacon config decoding in THOR */
      xor_s1 = "%02d/%02d/%02d %02d:%02d:%02d"
      xor_s2 = "Started service %s on %s"
      xor_s3 = "%s as %s\\%s: %d"
   strings:
      $s1 = "%02d/%02d/%02d %02d:%02d:%02d" xor(0x01-0xff)
      $s2 = "Started service %s on %s" xor(0x01-0xff)
      $s3 = "%s as %s\\%s: %d" xor(0x01-0xff)
   condition:
      2 of them
}

rule HKTL_CobaltStrike_Beacon_4_2_Decrypt {
   meta:
      author = "Elastic"
      description = "Identifies deobfuscation routine used in Cobalt Strike Beacon DLL version 4.2"
      reference = "https://www.elastic.co/blog/detecting-cobalt-strike-with-memory-signatures"
      date = "2021-03-16"
   strings:
      $a_x64 = {4C 8B 53 08 45 8B 0A 45 8B 5A 04 4D 8D 52 08 45 85 C9 75 05 45 85 DB 74 33 45 3B CB 73 E6 49 8B F9 4C 8B 03}
      $a_x86 = {8B 46 04 8B 08 8B 50 04 83 C0 08 89 55 08 89 45 0C 85 C9 75 04 85 D2 74 23 3B CA 73 E6 8B 06 8D 3C 08 33 D2}
   condition:
      any of them
}