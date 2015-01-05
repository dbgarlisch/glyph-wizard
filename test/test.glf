#
# Copyright 2015 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

# ===============================================
# Tcl/Tk wizard framework TEST
# ===============================================
# https://github.com/pointwise/Wizard
#
# Vnn: Release Date / Author
# v01: Jan 01, 2015 / David Garlisch
#
# ===============================================

#package require PWI_Glyph
#pw::Script loadTk
set scriptDir [file dirname [info script]]
source [file join $scriptDir .. wizard.tcl]

proc mkPhotoIcon { gifFile } {
  global scriptDir
  if { ![file isfile $gifFile] } {
    set gifFile [file join $scriptDir $gifFile]
    if { ![file isfile $gifFile] } {
      set gifFile {}
    }
  }
  if { {} != $gifFile } {
    set ret [image create photo -file $gifFile]
  } else {
    set ret {}
  }
  return $ret
}


# ===============================================
# ===============================================
namespace eval wizApp {
  variable extDist 1.0
  variable extSteps 10
  variable extDir {1 0 0}

  # A custom data item validation proc that can be registered with a call to
  # addValidator or replaceValidator. Return 1/0 if $val is valid/invalid.
  proc myType { val args } {
    puts "[namespace which myType] \{ $val $args \}"
    # call a builtin validator
    return [pw::Wizard::vtor::int $val {*}$args]
  }


  # Custom data checking proc. Called after datatype checking completes for all
  # data values. This proc can be used to enforce more complex relationships
  # between data values. For example, {$val1 >= $val2 *3}.
  # valsOk is 1 if all values are valid; 0 otherwise. w is the entry widget
  # whose value changed and trigered this call.
  #
  proc varsChecker { valsOk w } {
    #variable extDist
    #variable extSteps
    #variable extDir
    #puts "[namespace which varsChecker] \{ $valsOk '$w' \}"
    #puts "  [namespace which -variable extDist] = '$extDist'"
    #puts "  [namespace which -variable extSteps] = '$extSteps'"
    #puts "  [namespace which -variable extDir] = '$extDir'"

    # return 0 if data is not valid
    return 1
  }


  proc run { } {
    variable extDist
    variable extSteps
    variable extDir

    # ===============================================
    # ===============================================
    pw::Wizard page add pgExtDist {
      # configure the page
      $page setTabIcon [mkPhotoIcon {arrow-right.gif}]
      $page setTabText "Extrude Distance"
      # create page's widgets
      grid [label $pgFrame.lblExtDist -text "Extrude Distance" -anchor w] \
        -row 0 -column 0 -sticky we -pady 3 -padx 3
      grid [wizentry $pgFrame ::wizApp::extDist {double 1.0 5.0} -width 8] \
        -row 0 -column 1 -sticky w -pady 3 -padx 3
    }

    # ===============================================
    # ===============================================
    pw::Wizard page add pgExtSteps {
      # configure the page
      $page setTabIcon [mkPhotoIcon {double-arrow.gif}]
      $page setTabText "Extrude Steps"
      # create page's widgets
      grid [label $pgFrame.lblExtSteps -text "Extrude Steps" -anchor w] \
        -row 0 -column 0 -sticky we -pady 3 -padx 3
      grid [wizentry $pgFrame ::wizApp::extSteps {integer 1 10} -width 8] \
        -row 0 -column 1 -sticky w -pady 3 -padx 3
    }

    # ===============================================
    # ===============================================
    pw::Wizard page add pgExtDir {
      # configure the page
      $page setTabIcon [mkPhotoIcon {arrow-left.gif}]
      $page setTabText "Extrude Direction"
      #setOnEnterCmd {
      #  puts "[namespace which onEnter] \{ $page $pgFrame \}"
      #}
      #setOnLeaveCmd {
      #  puts "[namespace which onLeave] \{ $page $pgFrame \}"
      #}

      # create page's widgets
      grid [label $pgFrame.lblExtDir -text "Extrude Dir" -anchor w] \
        -row 0 -column 0 -sticky we -pady 3 -padx 3
      grid [wizentry $pgFrame ::wizApp::extDir vec3 -width 30] \
        -row 0 -column 1 -sticky w -pady 3 -padx 3
    }

    #pw::Wizard configure -errorBgColor #eef -errorFgColor #00a
    pw::Wizard configure -varsCheckProc ::wizApp::varsChecker

    pw::Wizard addValidator ::wizApp::myType

    puts {}
    puts {Options:}
    foreach opt [pw::Wizard configure] {
      puts [format "%20.20s: %s" $opt [pw::Wizard cget $opt]]
    }

    puts {}
    puts {Validators:}
    foreach vtor [pw::Wizard getValidator] {
      puts [format "%10.10s: %s" $vtor [pw::Wizard getValidator $vtor]]
    }

    if { [pw::Wizard run] } {
      puts "wizard finished"
      puts "  extDist : '$extDist'"
      puts "  extSteps: '$extSteps'"
      puts "  extDir  : '$extDir'"
    }
  }
}


# ===============================================
# ===============================================

::wizApp::run
