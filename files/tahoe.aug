(* Tahoe module for Augeas

 Author: François Deppierraz <francois@ctrlaltdel.ch>

 This module was heavily based on puppet.aug.

 tahoe.cfg is a standard INI File.
*)

module Tahoe =
  autoload xfm

(************************************************************************
 * INI File settings
 *
 * tahoe.cfg only supports "# as commentary and "=" as separator
 *************************************************************************)
let comment    = IniFile.comment "#" "#"
let sep        = IniFile.sep "=" "="


(************************************************************************
 *                        ENTRY
 * tahoe.cfg uses standard INI File entries
 *************************************************************************)
let entry   = IniFile.indented_entry IniFile.entry_re sep comment


(************************************************************************
 *                        RECORD
 * tahoe.cfg uses standard INI File records
 *************************************************************************)
let title   = IniFile.indented_title IniFile.record_re
let record  = IniFile.record title entry


(************************************************************************
 *                        LENS & FILTER
 * tahoe.cfg uses standard INI File records
 *************************************************************************)
let lns     = IniFile.lns record comment

let filter = (incl "/etc/tahoe/tahoe.cfg")

let xfm = transform lns filter
