#
# Copyright 2015 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

# ===============================================
# Tcl/Tk wizard app framework
# ===============================================
# https://github.com/pointwise/Wizard
#
# Vnn: Release Date / Author
# v01: Jan 01, 2015 / David Garlisch
#
# ===============================================

if { [namespace exists pw::Wizard] } {
  return
}

global auto_path
lappend auto_path [file join [file dirname [info script]] {bwidget-1.9.8}]
package require BWidget


#####################################################################
#                       public namespace procs
#####################################################################
namespace eval pw::Wizard {
  namespace export addValidator
  namespace export getValidator
  namespace export replaceValidator
  namespace export page
  namespace export configure
  namespace export cget
  namespace export run
}


proc pw::Wizard::page { cmd args } {
  return [page_$cmd {*}$args]
}


proc pw::Wizard::addValidator { procName {valTypes {}} {allowReplace 0} } {
  variable vtorDb_
  if { {} == $procName } {
    error "addValidator: procName is null."
  } elseif { {} == [info procs $procName] } {
    puts "addValidator: Warning procName($procName) does not exist."
  }
  if { {} == $valTypes } {
    # force default valType
    set valTypes {@}
  }
  foreach valType $valTypes {
    if { [dict exists $vtorDb_ $valType] && !$allowReplace } {
      error "Duplicate validator ($valType --> proc $procName)."
    } else {
      if { {@} == $valType } {
        # Build default valType from the procName. If procName is
        # ::ns::subns::myProc, default valType to myProc
        set valType [namespace tail $procName]
      }
      dict set vtorDb_ $valType $procName
    }
  }
}


proc pw::Wizard::getValidator { {valType {}} } {
  variable vtorDb_
  set ret {}
  if { {} == $valType } {
    set ret [dict keys $vtorDb_]
  } elseif { [catch {dict get $vtorDb_ $valType} ret] } {
    set ret {}
  } else {
    set ret [namespace which $ret]
  }
  return $ret
}


proc pw::Wizard::replaceValidator { procName {valTypes {}} } {
  addValidator $procName $valTypes 1
}


proc pw::Wizard::configure { args } {
  # configure ?option? ?value option value ...?
  variable configDb_
  set ret {}
  set len [llength $args]
  if { 0 == $len } {
    set ret [dict keys $configDb_]
  } elseif { 1 == $len } {
    set ret [dict keys $configDb_ [lindex $args 0]]
  } elseif { 0 != $len % 2 } {
    # args len must be even
    error "Invalid number of configure args"
  } else {
    foreach {opt val} $args {
      if { {} == [dict keys $configDb_ $opt] } {
        error "Invalid configure option ($opt)"
      }
      dict set configDb_ $opt $val
    }
  }
  return $ret
}


proc pw::Wizard::cget { opt } {
  variable configDb_
  set ret {}
  if { {} == [dict keys $configDb_ $opt] } {
    error "Invalid cget option ($opt)"
  } elseif { [catch {dict get $configDb_ $opt} ret] } {
    set ret {}
  }
  return $ret
}


proc pw::Wizard::run { finishBody args } {
  variable w

  if { 0 == [llength $args] } {
    set cancelBody {}
  } elseif { 2 != [llength $args] } {
    error "Invalid number of arguments: [list $args]"
  } elseif { {cancel} != [lindex $args 0] } {
    error "Missing cancel keyword: [list $args]"
  } else {
    # cancelBody code
    set cancelBody [lindex $args 1]
  }

  initWidgets
  initPages
  checkFinish

  # don't allow window to resize
  #wm resizable . 0 0
  wm minsize . 600 300

  #$pw::Wizard::w(nb) compute_size
  $w(nb) raise [lindex [page_names] 0]

  tkwait variable pw::Wizard::status_
  wm withdraw .

  if { [getStatus] } {
    uplevel 1 $finishBody
  } else {
    uplevel 1 $cancelBody
  }

  exit
}


# Create pw::Wizard ensemble
namespace eval pw::Wizard {
  namespace ensemble create
}



#####################################################################
#                       private namespace procs
#####################################################################
namespace eval pw::Wizard {
  variable status_ null

  variable w
  set w(nb)       .nb
  set w(btnBar)   .btnBar
    set w(back)     $w(btnBar).back
    set w(next)     $w(btnBar).next
    set w(finish)   $w(btnBar).finish
    set w(cancel)   $w(btnBar).cancel

  variable pageDb_ [dict create]
  variable vtorDb_ [dict create]
  variable configDb_ [dict create \
    -errorBgColor #fcc \
    -errorFgColor SystemWindowText \
    -varsCheckProc {} \
  ]

  proc initWidgets {} {
    variable w
    NoteBook $w(nb) -arcradius 6 -tabbevelsize 6 -tabpady {6 8} -width 800 -height 200
    frame $w(btnBar) -relief sunken
    button $w(back)   -text "Back"   -width 10 -bd 2 -command "pw::Wizard::onPrevPage"
    button $w(next)   -text "Next"   -width 10 -bd 2 -command "pw::Wizard::onNextPage"
    button $w(finish) -text "Finish" -width 10 -bd 2 -command "pw::Wizard::onFinish"
    button $w(cancel) -text "Cancel" -width 10 -bd 2 -command "pw::Wizard::onCancel"

    pack $w(nb) -fill both -expand true  -pady {6 0}  -padx 10
    pack $w(cancel)                      -pady 0      -padx {6 0} -side right
    pack $w(finish)                      -pady 0      -padx {18 0} -side right
    pack $w(next) $w(back)               -pady 0      -padx {6 0} -side right
    pack $w(btnBar) -fill x -side bottom -pady {10 6} -padx 10 -anchor s
  }

  proc initPages { } {
    variable w
    variable pageDb_
    set prevPage {}
    foreach page [page_names] {
      if { {} != $prevPage } {
        dict set pageDb_ $prevPage NEXTPAGE $page
      }
      dict set pageDb_ $page PREVPAGE $prevPage
      # will be updated on next pass if there is one
      dict set pageDb_ $page NEXTPAGE {}
      # cache page name for next pass
      set prevPage $page

      # ask notebook for the name of the page's frame widget
      set pgFrame [$w(nb) getframe $page]
      dict set pageDb_ $page FRAME $pgFrame

      # Append a new notebook page
      $w(nb) insert end $page \
        -createcmd "pw::Wizard::onCreate $page $pgFrame" \
        -leavecmd "pw::Wizard::onLeave $page $pgFrame" \
        -raisecmd "pw::Wizard::onEnter $page $pgFrame" \
        -state normal

      # Sets default tab text
      ::$page setTabText
    }

    # in reverse order, force each page to call its onCreate proc
    foreach page [lreverse  [page_names]] {
      $w(nb) raise $page
    }
  }

  proc checkFinish { {wid {}} } {
    variable w
    set state disabled
    if { 0 == [getErrCount] } {
      if { [cgetCallProc -varsCheckProc 1 $wid] } {
        set state normal
      }
    } else {
      # Notify app that validation failed - ignore return value
      cgetCallProc -varsCheckProc 0 $wid
    }
    $w(finish) configure -state $state
  }

  proc callProc { procName args } {
    if { {} == [info procs $procName] } {
      error "callProc '$procName' does not exist."
    }
    return [$procName {*}$args]
  }

  proc cgetCallProc { opt args } {
    set ret 1
    set procName [cget $opt]
    #puts "[namespace which cgetCallProc] { $opt $args } --> $procName"
    if { {} != $procName } {
      set ret [callProc $procName {*}$args]
    }
    return $ret
  }

  proc onNextPage { } {
    variable w
    variable pageDb_
    set curPage [$w(nb) raise]
    set nextPage [dict get $pageDb_ $curPage NEXTPAGE]
    if { {} != $nextPage } {
      $w(nb) raise $nextPage
    }
  }

  proc onPrevPage { } {
    variable w
    variable pageDb_
    set curPage [$w(nb) raise]
    set prevPage [dict get $pageDb_ $curPage PREVPAGE]
    if { {} != $prevPage } {
      $w(nb) raise $prevPage
    }
  }

  proc onFinish { } {
    variable status_
    set status_ 1
  }

  proc onCancel { } {
    variable status_
    set status_ 0
  }

  proc getStatus { } {
    variable status_
    return $status_
  }

  proc onCreate { page pgFrame } {
    ${page}::onCreate $page $pgFrame
  }

  proc onLeave { page pgFrame } {
    # Call the page's onLeave proc
    ${page}::onLeave $page $pgFrame
  }

  proc onEnter { page pgFrame } {
    variable w
    variable pageDb_

    # Call the page's onEnter proc
    ${page}::onEnter $page $pgFrame

    if { [lindex [dict keys $pageDb_] 0] == $page } {
      $w(back) configure -state disabled
    } else {
      $w(back) configure -state normal
    }
    if { [lindex [dict keys $pageDb_] end] == $page } {
      $w(next) configure -state disabled
    } else {
      $w(next) configure -state normal
    }
  }


  #####################################################################
  # The data error procs
  #####################################################################

  variable errors_ [dict create]

  proc getErrCount { } {
    variable errors_
    return [dict size $errors_]
  }

  proc getErrWidgets { } {
    variable errors_
    return [dict keys $errors_]
  }

  # clear error flag on widget w
  proc clearError { w } {
    if { $w != {} } {
      variable errors_
      dict unset errors_ $w
      $w configure -background SystemWindow
      $w configure -foreground SystemWindowText
    }
  }

  # set error flag on widget w
  proc setError { w } {
    if { $w != {} } {
      variable errors_
      dict set errors_ $w 1
      $w configure -foreground [cget -errorFgColor]
      $w configure -background [cget -errorBgColor]
    }
  }

  proc validate { valType action newVal oldVal w v } {
    #puts "pw::Wizard::validate valType($valType) action($action) newVal($newVal) oldVal($oldVal) '$w' '$v'"
    if { -1 != $action || {forced} == $v} {
      if { [callValidator $valType $newVal] } {
        clearError $w
      } else {
        setError $w
      }
      callCheckFinish $w
    }
    return 1
  }

  proc onCheckButton { w varName } {
    #puts "onCheckButton $w $varName=[set $varName]"
    callCheckFinish $w
  }

  proc onRadioButton { w varName } {
    #puts "onRadioButton $w $varName=[set $varName]"
    callCheckFinish $w
  }

  proc onListBox { w varName itemsVarName } {
    set items [set $itemsVarName]
    set $varName {}
    foreach ndx [$w curselection] {
      lappend $varName [lindex $items $ndx]
    }
    #puts "onListBox $w $varName=[list [set $varName]] $itemsVarName"
    callCheckFinish $w
  }

  proc onComboBox { w varName } {
    #puts "onComboBox $w $varName=[list [set $varName]]"
    callCheckFinish $w
  }

  proc callValidator { valType val } {
    variable vtorDb_
    set ret 0
    # valType can be a list: {type ?arg ...?}
    # split into: valType={type} args={?arg ...?}
    set args [lassign $valType valType]
    if { [dict exists $vtorDb_ $valType] } {
      set procName [dict get $vtorDb_ $valType]
      set ret [callProc $procName $val {*}$args]
    } else {
      error "Could not find validator($valType)."
    }
    return $ret
  }

  proc callCheckFinish { w } {
    # cancel any pending checkFinish calls for $w
    after cancel pw::Wizard::checkFinish $w

    # Schedule a call to pw::Wizard::checkFinish for AFTER the tk entry-widget
    # value validation mechanism has finished. We cannot call checkFinish here
    # because the widget's associated -textvariable has not been updated yet!
    after idle pw::Wizard::checkFinish $w
  }


  #####################################################################
  # The "proc pw::Wizard::page cmd" implementations.
  #####################################################################

  proc page_names { {globPattern {}} } {
    variable pageDb_
    return [dict keys $pageDb_ {*}$globPattern]
  }

  proc page_size { } {
    variable pageDb_
    return [dict size $pageDb_]
  }

  proc page_add { page onCreateCmd } {
    variable pageDb_
    dict lappend pageDb_ $page PREVPAGE {}
    dict lappend pageDb_ $page NEXTPAGE {}

    namespace eval $page [list \
      proc onCreate { page pgFrame } $onCreateCmd ]

    # add NOP default procs
    namespace eval $page [list proc onEnter { page pgFrame } {} ]
    namespace eval $page [list proc onLeave { page pgFrame } {} ]

    namespace eval $page {
      namespace export setTabText
      proc setTabText { {txt {}} } {
        set page [namespace tail [namespace current]]
        if { {} == $txt } {
          set txt $page
        }
        $::pw::Wizard::w(nb) itemconfigure $page -text "$txt"
      }

      namespace export setTabIcon
      proc setTabIcon { tabIcon } {
        set page [namespace tail [namespace current]]
        $::pw::Wizard::w(nb) itemconfigure $page -image $tabIcon
      }

      namespace export setOnEnterCmd
      proc setOnEnterCmd { cmd } {
        set ns [namespace current]
        namespace eval $ns [list proc onEnter { page pgFrame } $cmd]
      }

      namespace export setOnLeaveCmd
      proc setOnLeaveCmd { cmd } {
        set ns [namespace current]
        namespace eval $ns [list proc onLeave { page pgFrame } $cmd]
      }

      proc wizentry { parentPath varName varTypeSpec args } {
        set w "$parentPath.[string map {:: _} $varName]"
        entry $w {*}$args -textvariable $varName -validate key \
          -validatecommand \
            "pw::Wizard::validate [list $varTypeSpec] %d %P %s %W %V"
        return $w
      }

      proc wizcheckbutton { parentPath varName args } {
        set w "$parentPath.[string map {:: _} $varName]"
        checkbutton $w {*}$args -variable $varName \
          -command "pw::Wizard::onCheckButton $w $varName"
        return $w
      }

      proc wizradiobutton { parentPath varName val args } {
        set n 0
        set w "$parentPath.[string map {:: _} $varName]-rad$n"
        while { [winfo exists $w] } {
          set w "$parentPath.[string map {:: _} $varName]-rad[incr n]"
        }
        radiobutton $w {*}$args -variable $varName -value $val \
          -command "pw::Wizard::onRadioButton $w $varName"
        return $w
      }

      proc wizlistbox { parentPath varName itemsVarName args } {
        set w "$parentPath.[string map {:: _} $varName]"
        listbox $w {*}$args -listvariable $itemsVarName
        bind $w <<ListboxSelect>> \
          "pw::Wizard::onListBox $w $varName $itemsVarName"
        return $w
      }

      proc wizcombobox { parentPath varName comboItems args } {
        set w "$parentPath.[string map {:: _} $varName]"
        ttk::combobox $w {*}$args -values $comboItems -textvariable $varName
        bind $w <<ComboboxSelected>> "pw::Wizard::onComboBox $w $varName"
        return $w
      }

      proc wizicon { gifFile } {
        if { ![file isfile $gifFile] } {
          set gifFile [file join [file dirname [info script]] $gifFile]
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
    }

    # Create page instance namespace ensemble
    namespace eval $page [list namespace ensemble create -command ::$page]
  }


  #####################################################################
  # The data validation handlers.
  #####################################################################

  namespace eval vtor {
    proc valIsType { val type } {
      return [string is $type -strict $val]
    }

    proc listValIsLen { val minLen maxLen } {
      set valLen [llength $val]
      if { $minLen <= 0 } {
        set minLen $valLen
      }
      if { $maxLen <= 0 } {
        set maxLen $valLen
      }
      return [expr {$minLen <= $valLen && $maxLen >= $valLen}]
    }

    proc valIsTypeArray { val arrType minLen maxLen } {
      set ret 0
      if { [listValIsLen $val $minLen $maxLen] } {
        set ret 1
        foreach v $val {
          if { ![pw::Wizard::callValidator $arrType $v] } {
            set ret 0
            break
          }
        }
      }
      return $ret
    }

    proc numInRange { val minVal maxVal } {
      set ret 1
      if { $minVal != {inf} && $val < $minVal } {
        set ret 0
      } elseif { $maxVal != {inf} && $val > $maxVal } {
        set ret 0
      }
      return $ret
    }

    proc int { val args } {
      lappend args inf inf
      lassign $args minVal maxVal
      return [expr {[valIsType $val integer] &&
        [numInRange $val $minVal $maxVal]}]
    }

    proc double { val args } {
      lappend args inf inf
      lassign $args minVal maxVal
      return [expr {[valIsType $val double] && \
        [numInRange $val $minVal $maxVal]}]
    }

    proc text { val args } {
      return [valIsType $val alnum]
    }

    proc arr { val args } {
      # args: {type ?minLen? ?maxLen?}
      lappend args 0 0
      lassign $args arrType minLen maxLen
      return [pw::Wizard::valIsTypeArray $val $arrType $minLen $maxLen]
    }

    proc vec3 { val args } {
      return [valIsTypeArray $val double 3 3]
    }

    proc int3 { val args } {
      return [valIsTypeArray $val integer 3 3]
    }

    proc nop { val args } {
      return 1
    }
  }

  #####################################################################
  # one time Wizard init
  #####################################################################
  addValidator vtor::double {@ real float}
  addValidator vtor::text {@ str string}
  addValidator vtor::int {@ integer}
  addValidator vtor::vec3 {@ real3 double3 float3 vector3}
  addValidator vtor::int3 {@ integer3}
  addValidator vtor::nop {@ any none}
  addValidator vtor::arr {@ array vec vector list}

  configure -errorBgColor #fee
  configure -errorFgColor #a00
}

# END SCRIPT

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT. TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
