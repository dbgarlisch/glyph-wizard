# glyph-wizard

This glyph library provides a framework for building a multiple page, wizard application.

![Wizard Banner Image](../master/docs/images/banner.png  "wizard banner Image")

This libray uses the `Notebook` Tk widget from the [BWidget ToolKit][BWidget].
Version 1.9.8 of the toolkit is bundled with this repository.


## Using The Library

To use this library to build a wizard application, you must include
`wizard.tcl` in your application script. Though not required, I suggest
wrapping your wizard application in a tcl namespace.

```Tcl
  source "/some/path/to/your/copy/of/wizard.tcl"

  namespace eval wizApp {
    # put your application code in here as shown below
  }
```

Declare and initialize the application's data values.

```Tcl
  variable extDist 1.0
  variable extSteps 10
  variable extDir {1 0 0}
```

Define the application's wizard pages using the
[`pw::Wizard page add`][WizAPI-page-add] command.

You can bind an application variable to an entry widget and the wizard data
validation mechanism using the [`wizentry`][WizAPI-wizentry] command.

```Tcl
  pw::Wizard page add pgExtDist {
    # configure the page
    setTabIcon [mkPhotoIcon {arrow-right.gif}]
    setTabText "Extrude Distance"
    # create page's widgets
    grid [label $pgFrame.lblExtDist -text "Extrude Distance" -anchor w] \
      -row 0 -column 0 -sticky we -pady 3 -padx 3
    grid [wizentry $pgFrame ::wizApp::extDist {double 1.0 5.0} -width 8] \
      -row 0 -column 1 -sticky w -pady 3 -padx 3
  }
```

Configure the wizard using the [`pw::Wizard configure`][WizAPI-configure] command.

```Tcl
  pw::Wizard configure -errorBgColor #eef -errorFgColor #00a
  pw::Wizard configure -varsCheckProc ::wizApp::varsChecker
```

Run the wizard application using the [`pw::Wizard run`][WizAPI-run] command.

```Tcl
  if { [pw::Wizard run] } {
    puts "wizard finished"
    puts "  extDist : '$extDist'"
    puts "  extSteps: '$extSteps'"
    puts "  extDir  : '$extDir'"
  }
```

See the [Wizard API Docs][WizAPI] for full library documentation.


## Disclaimer
Scripts are freely provided. They are not supported products of
Pointwise, Inc. Some scripts have been written and contributed by third
parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.


[BWidget]: http://www.sourceforge.net/projects/tcllib/
[WizAPI]: docs/Wizard_API.md
[WizAPI-page-add]: docs/Wizard_API.md#pwwizard-page-add-name-script
[WizAPI-wizentry]: docs/Wizard_API.md#wizentry-parentpath-varname-vartypespec-entryopts
[WizAPI-configure]: docs/Wizard_API.md#pwwizard-configure-option-value-option-value-
[WizAPI-run]: docs/Wizard_API.md#pwwizard-run
