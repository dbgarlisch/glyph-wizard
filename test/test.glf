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

# ===============================================
# ===============================================
namespace eval wizApp {
  variable extDist 1.0
  variable extSteps 10
  variable extDir {1 0 0}
  variable lights 0
  variable camera 1
  variable action 0
  variable axis y
  variable lbox {your}
  variable cbox {list}
  namespace eval priv {
    variable lbItems {choose your option wisely}
  }

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
    #puts "[namespace which varsChecker] \{ $valsOk '$w' \}"
    #set vars [lsort [info vars ::wizApp::*]]
    #foreach var $vars {
    #  puts [format "  %-20.20s = %s" [namespace which -variable $var] \
    #                                 [set $var]]
    #}
    # return 0 if data is not valid
    return 1
  }


  proc run { } {
    # ===============================================
    pw::Wizard page add pgExtDist {
      # configure the page
      setTabIcon [wizicon {arrow-right.gif}]
      setTabText "Extrude Distance"
      # create page's widgets
      grid [label $pgFrame.lblExtDist -text "Extrude Distance" -anchor w] \
        -row 0 -column 0 -sticky we -pady 3 -padx 3
      grid [wizentry $pgFrame ::wizApp::extDist {double 1.0 5.0} -width 8] \
        -row 0 -column 1 -sticky w -pady 3 -padx 3

      grid [labelframe $pgFrame.lbl -text "Steps: "] \
        -row 1 -column 0 -columnspan 2 -sticky we -pady 3 -padx 3
      pack [wizcheckbutton $pgFrame ::wizApp::lights -text Lights] \
           [wizcheckbutton $pgFrame ::wizApp::camera -text Camera] \
           [wizcheckbutton $pgFrame ::wizApp::action -text Action!] \
           -in $pgFrame.lbl -padx 5 -anchor w
    }

    # ===============================================
    pw::Wizard page add pgExtSteps {
      # configure the page
      setTabIcon [wizicon {double-arrow.gif}]
      setTabText "Extrude Steps"
      # create page's widgets
      grid [label $pgFrame.lblExtSteps -text "Extrude Steps" -anchor w] \
        -row 0 -column 0 -sticky we -pady 3 -padx 3
      grid [wizentry $pgFrame ::wizApp::extSteps {integer 1 10} -width 8] \
        -row 0 -column 1 -sticky w -pady 3 -padx 3

      grid [labelframe $pgFrame.lbl -text "Axis: "] \
        -row 1 -column 0 -columnspan 2 -sticky we -pady 3 -padx 3
      pack [wizradiobutton $pgFrame ::wizApp::axis x -text {x axis}] \
           [wizradiobutton $pgFrame ::wizApp::axis y -text {y axis}] \
           [wizradiobutton $pgFrame ::wizApp::axis z -text {z axis}] \
           -in $pgFrame.lbl -padx 5 -anchor w
    }

    # ===============================================
    pw::Wizard page add pgExtDir {
      # configure the page
      setTabIcon [wizicon {arrow-left.gif}]
      setTabText "Extrude Direction"
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
      grid [wizlistbox $pgFrame ::wizApp::lbox ::wizApp::priv::lbItems \
        -width 30 -height 0] -row 1 -column 0 -columnspan 2 -sticky we \
        -pady 3 -padx 3
      set cbItems {another list of items}
      grid [wizcombobox $pgFrame ::wizApp::cbox $cbItems -width 30 -state readonly] \
        -row 2 -column 0 -columnspan 2 -sticky we -pady 3 -padx 3
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

    pw::Wizard run {
      # This required script is invoked when the Finish button is pressed.
      puts "wizard finished"
      set vars [lsort [info vars ::wizApp::*]]
      foreach var $vars {
        puts [format "  %-20.20s = %s" \
          [namespace which -variable $var] \
          [set $var]]
      }
    } cancel {
      # This optional script is invoked when the Cancel button is pressed.
      puts "wizard canceled"
    }
  }
}


# ===============================================
# ===============================================

::wizApp::run
