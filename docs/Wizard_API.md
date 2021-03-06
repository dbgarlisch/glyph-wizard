# glyph-wizard API

### Table of Contents
* [The pw::Wizard Library](#the-pwwizard-library)
* [pw::Wizard Commands](#pwwizard-commands)
* [Page Commands](#page-commands)
* [Predefined Validators](#predefined-validators)
  * [Validator Helpers](#validator-helpers)
* [pw::Wizard Library Usage Example](#pwwizard-library-usage-example)
* [Disclaimer](#disclaimer)


## The pw::Wizard Library
This library is implemented as a command ensemble named **pw::Wizard**.

Calls to this library are made using the **pw::Wizard command args**
convention.

For example:
```Tcl
source "/some/path/to/your/copy/of/Wizard.glf"
pw::Wizard configure -errorBgColor #eef
```

See the script `test/test.glf` for a full example.


## pw::Wizard Commands
The following *pw::Wizard* commands are supported.

* [page add](#pwwizard-page-add-name-script)
* [page names](#pwwizard-page-names-pattern)
* [page size](#pwwizard-page-size)
* [addValidator](#pwwizard-addvalidator-procname-valtypes-allowreplace)
* [getValidator](#pwwizard-getvalidator-valtype)
* [replaceValidator](#pwwizard-replacevalidator-procname-valtypes)
* [configure](#pwwizard-configure-option-value-option-value-)
* [cget](#pwwizard-cget-option)
* [run](#pwwizard-run-finishcmd-cancel-cancelcmd)

### **pw::Wizard page add** *name script*
The **page add** command is used to create a wizard page object.
<dl>
  <dt><em>name</em></dt>
  <dd>The page object name. Can be any valid tcl variable name.</dd>
  <dt><em>script</em></dt>
  <dd>The tcl/Tk script used to create the page widgets and layout. This script
  is executed when the page's *onCreate* command is called. See the
  <em>Wizard Pages</em> section for more details.</dd>
</dl>
<br/>


### **pw::Wizard page names** *?pattern?*
The **page names** command is returns a list of page names matching *pattern*.
If *pattern* is not given, all page names are returned.
<dl>
  <dt><em>pattern</em></dt>
  <dd>The glob pattern.<br/>
  </dd>
</dl>
<br/>


### **pw::Wizard page size**
The **page size** command returns the number of pages added.
<dl>
</dl>
<br/>


### **pw::Wizard addValidator** *procName ?valTypes? ?allowReplace?*
The **addValidator** command adds a validator proc to the wizard's input
validation engine. See also [Predefined Validators](#predefined-validators).
<dl>
  <dt><em>procName</em></dt>
  <dd>The proc called to validate a value. The proc must use a call signature
    that accepts the value being validated as the first arg and an optional
    number of additional args: <code>val ?arg ...?</code>.</dd>
  <dt><em>valTypes</em></dt>
  <dd>The list of type names that use this validator proc. If empty (the
    default), the value returned by <code>[namespace tail $procName]</code> is
    used. In the list, <em>@</em> is shorthand for
    <code>[namespace tail $procName]</code>.</dd>
  <dt><em>allowReplace</em></dt>
  <dd>If 1, any existing value types are replaced. If 0 (the default), replacing
  an exisiting type name is an error.</dd>
</dl>
<br/>


### **pw::Wizard getValidator** *?valType?*
The **getValidator** command returns the validator proc associated with a given
*valType*.
<dl>
  <dt><em>valType</em></dt>
  <dd>An existing validator type name. If not specified (the default), a list
  of all defined validator types is returned.</dd>
</dl>
<br/>


### **pw::Wizard replaceValidator** *procName ?valTypes?*
The **replaceValidator** replaces an exisiting validator proc.

This proc is equivalent to calling:
   *pw::Wizard addValidator procName $valTypes 1*
<dl>
  <dt><em>procName</em></dt>
  <dd>The proc called to validate a value. The proc must use a call signature
    that accepts the value being validated as the first arg and an optional number
    of additional args: <code>val ?arg ...?</code>.</dd>
  <dt><em>valTypes</em></dt>
  <dd>The list of type names that use this validator proc. If empty (the
    default), the value returned by <code>[namespace tail $procName]</code> is
    used. In the list, <em>@</em> is shorthand for
    <code>[namespace tail $procName]</code>.</dd>
</dl>
<br/>


### **pw::Wizard configure** *?option? ?value option value ...?*
The **configure** command sets **pw::Wizard** attribute values. If called
without any options, a list of all valid options is returned.

The following *configure* options are supported.
* [-errorBgColor](#pwwizard-configure--errorbgcolor-color)
* [-errorFgColor](#pwwizard-configure--errorfgcolor-color)
* [-varsCheckProc](#pwwizard-configure--varscheckproc-procname)


#### **pw::Wizard configure -errorBgColor** *color*
Sets the background color displayed in *wizentry* widgets that contain invalid
values. The default is *#fee*.
<dl>
  <dt><em>color</em></dt>
  <dd>A tcl color value.</dd>
</dl>
<br/>

#### **pw::Wizard configure -errorFgColor** *color*
Sets the foreground color displayed in *wizentry* widgets that contain invalid
values. The default is *#a00*.
<dl>
  <dt><em>color</em></dt>
  <dd>A tcl color value.</dd>
</dl>
<br/>

#### **pw::Wizard configure -varsCheckProc** *procName*
Sets the application level data validation proc. The proc specified by
*procName* must use the `status widgetPath` call signature. This proc is
called by the validation engine after individual data validations are performed.
If *status* is 1, all validations passed. If *status* is 0, at least one value
failed validation. In all cases, the validation sequence was triggered by a
change to the value of *widgetPath*.</dd>
<dl>
  <dt><em>procName</em></dt>
  <dd>The name of an application defined data validation proc.</dd>
</dl>
<br/>


### **pw::Wizard cget** *option*
The **cget** command returns the current value of a **pw::Wizard** attribute
value.
<dl>
  <dt><em>option</em></dt>
  <dd>One of the valid <em>configure</em> options.</dd>
</dl>
<br/>


### **pw::Wizard run** *finishCmd ?cancel cancelCmd?*
The **run** command starts the wizard. Prior to the display of the wizard
dialog box, each page's *onCreate* proc is executed.
<dl>
  <dt><em>finishCmd</em></dt>
  <dd>Defines the script executed if the user presses the dialog's Finish
  button. The framework calls exit after this script finishes.</dd>
  <dt><em>cancel</em></dt>
  <dd>Command keyword. Required if a cancelCmd is specified.</dd>
  <dt><em>cancelCmd</em></dt>
  <dd>Defines the script executed if the user presses the dialog's Cancel
  button. The framework calls exit after this script finishes.</dd>
</dl>
<br/>


## Page Commands
Wizard page objects are created by calls to *pw::Wizard page add*. The page
object commands are defined below.

* [onCreate](#oncreate-page-pgframe)
* [onEnter](#onenter-page-pgframe)
* [onLeave](#onleave-page-pgframe)
* [setTabText](#settabtext-txt)
* [setTabIcon](#settabicon-tabicon)
* [wizentry](#wizentry-parentpath-varname-vartypespec-widgetopts)
* [wizcheckbutton](#wizcheckbutton-parentpath-varname-widgetopts)
* [wizradiobutton](#wizradiobutton-parentpath-varname-val-widgetopts)
* [wizlistbox](#wizlistbox-parentpath-varname-itemsvarname-widgetopts)
* [wizcombobox](#wizcombobox-parentpath-varname-comboitems-widgetopts)
* [wizicon](#wizicon-imagefile)
* [setOnEnterCmd](#setonentercmd-cmd)
* [setOnLeaveCmd](#setonleavecmd-cmd)

### **onCreate** *page pgFrame*
The **onCreate** command calls the *onCreateCmd* script specified when the page
object was created by *pw::Wizard page add*. This command should never be called
directly. This command is called when needed by **pw::Wizard::run** to create
the page's widgets.
<dl>
  <dt><em>page</em></dt>
  <dd>The page objects variable name. This is the same value passed to the
  <em>name</em> argument of the call to <em>pw::Wizard page add</em>.</dd>
  <dt><em>pgFrame</em></dt>
  <dd>The page's frame widget path. The page's widget hierarchy should use this
  path as its root.</dd>
</dl>
<br/>

### **onEnter** *page pgFrame*
The **onEnter** command is called by the wizard framework every time the page's
tab is raised (made visible). This command should never be called directly. This
command is called by the wizard framwork as needed. See the *setOnEnterCmd*
command.
<dl>
  <dt><em>page</em></dt>
  <dd>The page objects variable name.</dd>
  <dt><em>pgFrame</em></dt>
  <dd>The page's frame widget path.</dd>
</dl>
<br/>

### **onLeave** *page pgFrame*
The **onLeave** command is called by the wizard framework every time the page's
tab is lowered (made hidden). This command should never be called directly. This
command is called by the wizard framwork as needed. See the *setOnLeaveCmd*
command.
<dl>
  <dt><em>page</em></dt>
  <dd>The page objects variable name.</dd>
  <dt><em>pgFrame</em></dt>
  <dd>The page's frame widget path.</dd>
</dl>
<br/>

### **setTabText** *txt*
The **setTabText** command defines the text displayed on the page tab.
<dl>
  <dt><em>txt</em></dt>
  <dd>The tab text string. Any value can be used. However, shorter strings
  usually look better in the GUI.</dd>
</dl>
<br/>

### **setTabIcon** *tabIcon*
The **setTabIcon** command defines the icon displayed to the left of the page
tab text.
<dl>
  <dt><em>tabIcon</em></dt>
  <dd>The icon resource. Typically, this is a value returned from a call to
  <em>[image create ...]</em> or <em>wizicon</em>.</dd>
</dl>
<br/>

### **wizentry** *parentPath varName varTypeSpec ?widgetOpts...?*
The **wizentry** command creates a `tk::entry` widget that works properly with
the wizard's value validation framework.
<dl>
  <dt><em>parentPath</em></dt>
    <dd>The path of the parent widget's window.</dd>
  <dt><em>varName</em></dt>
    <dd>The name of the variable bound to this entry. If not global,
    <em>varName</em> should include its full namespace. For example,
    <code>::wizApp::extDist</code>.</dd>
  <dt><em>varTypeSpec</em></dt>
    <dd>The entry's value type specification. A spec consists of validator type
    and zero or more validator type arguments. See the Predefined Validators
    section for details.</dd>
  <dt><em>widgetOpts</em></dt>
    <dd>Additional standard <em>tk::entry</em> widget creation options. The widget
    framework uses the <em>-textvariable</em>, <em>-validate</em>, and
    <em>-validatecommand</em> options and should not be specified in
    <em>widgetOpts</em>.</dd>
</dl>
<br/>

### **wizcheckbutton** *parentPath varName ?widgetOpts...?*
The **wizcheckbutton** command creates a `tk::checkbutton` widget that works
properly with the wizard's value validation framework.
<dl>
  <dt><em>parentPath</em></dt>
    <dd>The path of the parent widget's window.</dd>
  <dt><em>varName</em></dt>
    <dd>The name of the variable bound to this widget. If not global,
    <em>varName</em> should include its full namespace. For example,
    <code>::wizApp::extDist</code>.</dd>
  <dt><em>widgetOpts</em></dt>
    <dd>Additional standard <em>tk::checkbutton</em> widget creation options. The
    widget framework uses the <em>-variable</em>, and <em>-command</em> options
    and should not be specified in <em>widgetOpts</em>.</dd>
</dl>
<br/>

### **wizradiobutton** *parentPath varName val ?widgetOpts...?*
The **wizradiobutton** command creates a `tk::radiobutton` widget that works
properly with the wizard's value validation framework.
<dl>
  <dt><em>parentPath</em></dt>
    <dd>The path of the parent widget's window.</dd>
  <dt><em>varName</em></dt>
    <dd>The name of the variable bound to this widget. If not global,
    <em>varName</em> should include its full namespace. For example,
    <code>::wizApp::extDist</code>.</dd>
  <dt><em>val</em></dt>
    <dd>The value assigned to <em>varName</em> when the radio button is
    selected.</dd>
  <dt><em>widgetOpts</em></dt>
    <dd>Additional standard <em>tk::radiobutton</em> widget creation options.
    The widget framework uses the <em>-variable</em>, <em>-value</em>,
    and <em>-command</em> options and should not be specified in
    <em>widgetOpts</em>.</dd>
</dl>
<br/>

### **wizlistbox** *parentPath varName itemsVarName ?widgetOpts...?*
The **wizlistbox** command creates a `tk::listbox` widget that works
properly with the wizard's value validation framework.
<dl>
  <dt><em>parentPath</em></dt>
    <dd>The path of the parent widget's window.</dd>
  <dt><em>varName</em></dt>
    <dd>The name of the variable bound to this widget. If not global,
    <em>varName</em> should include its full namespace. For example,
    <code>::wizApp::extDist</code>.</dd>
  <dt><em>itemsVarName</em></dt>
    <dd>The name of the list variable containing the items displayed in the list
    widget.</dd>
  <dt><em>widgetOpts</em></dt>
    <dd>Additional standard <em>tk::listbox</em> widget creation options.
    The widget framework uses the <em>-listvariable</em> option and should not
    be specified in <em>widgetOpts</em>.</dd>
</dl>
<br/>

### **wizcombobox** *parentPath varName comboItems ?widgetOpts...?*
The **wizcombobox** command creates a `ttk::combobox` widget that works
properly with the wizard's value validation framework.
<dl>
  <dt><em>parentPath</em></dt>
    <dd>The path of the parent widget's window.</dd>
  <dt><em>varName</em></dt>
    <dd>The name of the variable bound to this widget. If not global,
    <em>varName</em> should include its full namespace. For example,
    <code>::wizApp::extDist</code>.</dd>
  <dt><em>comboItems</em></dt>
    <dd>The list of items displayed in the list widget.</dd>
  <dt><em>widgetOpts</em></dt>
    <dd>Additional standard <em>ttk::combobox</em> widget creation options.
    The widget framework uses the <em>-listvariable</em> option and should not
    be specified in <em>widgetOpts</em>.</dd>
</dl>
<br/>

### **wizicon** *imageFile*
The **wizicon** command creates an icon resource from an image file.

Your Tcl installation may support many image formats. However, for maximum
compatability, it is best to only use <em>gif</em> files.
<dl>
  <dt><em>imageFile</em></dt>
  <dd>The icon image file. If <em>imageFile</em> cannot be found in the current
  directory, this command also looks for it in the application script
  directory.</dd>
</dl>
<br/>

### **setOnEnterCmd** *cmd*
The **setOnEnterCmd** command defines the script executed by the page object's
*onEnter* command. The *onEnter* command is called by the wizard framework every
time the page's tab is raised (made visible). The default script is {}.
<dl>
  <dt><em>cmd</em></dt>
  <dd>The onEnter command script. This script has access to the <em>page</em>
  and <em>pgFrame</em> arguments passed to <em>onEnter</em>.</dd>
</dl>
<br/>

### **setOnLeaveCmd** *cmd*
The **setOnLeaveCmd** command defines the script executed by the page object's
*onLeave* command. The *onLeave* command is called by the wizard framework every
time the page's tab is lowered (made hidden). The default script is {}.
<dl>
  <dt><em>cmd</em></dt>
  <dd>The onLeave command script. This script has access to the <em>page</em>
  and <em>pgFrame</em> arguments passed to <em>onLeave</em>.</dd>
</dl>
<br/>


## Predefined Validators
Some predefined validators are added by **pw::Wizard**. The associated
validation procs are defined in the **pw::Wizard::vtor** namespace.

* [pw::Wizard::vtor::int](#pwwizardvtorint-val-minval-maxval)
* [pw::Wizard::vtor::double](#pwwizardvtordouble-val-minval-maxval)
* [pw::Wizard::vtor::text](#pwwizardvtortext-val)
* [pw::Wizard::vtor::vec3](#pwwizardvtorvec3-val)
* [pw::Wizard::vtor::int3](#pwwizardvtorint3-val)
* [pw::Wizard::vtor::nop](#pwwizardvtornop-val)
* [pw::Wizard::vtor::arr](#pwwizardvtorarr-val-type-minlen-maxlen)

Each validator has a specific signature when used as a *varTypeSpec* in a
**wizentry** call. The built in validator signatures are defined in the
following sections.

Any application defined validators added with a call to *pw::Wizard addValidator*
will have their own signatures and are not covered here.

### **pw::Wizard::vtor::int** *val ?minVal ?maxVal??*
Validates an integer value with an optional range.
Aliases: `integer`.
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
  <dt><em>minVal</em></dt>
  <dd>If defined, <em>val</em> must be greater than or equal to this value. If
  set to <b>inf</b>, <em>minVal</em> is not enforced.</dd>
  <dt><em>maxVal</em></dt>
  <dd>If defined, <em>val</em> must be less than or equal to this value. If
  set to <b>inf</b>, <em>maxVal</em> is not enforced.</dd>
</dl>
<br/>

### **pw::Wizard::vtor::double** *val ?minVal ?maxVal??*
Validates a floating point value with an optional range.
Aliases: `real`, `float`.
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
  <dt><em>minVal</em></dt>
  <dd>If defined, <em>val</em> must be greater than or equal to this value. If
  set to <b>inf</b>, <em>minVal</em> is not enforced.</dd>
  <dt><em>maxVal</em></dt>
  <dd>If defined, <em>val</em> must be less than or equal to this value. If
  set to <b>inf</b>, <em>maxVal</em> is not enforced.</dd>
</dl>
<br/>

### **pw::Wizard::vtor::text** *val*
Validates a string value as not empty.
Aliases: `str`, `string`.
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
</dl>
<br/>

### **pw::Wizard::vtor::vec3** *val*
Validates an array of three floating point values.
Aliases: `real3`, `double3`, `float3`, `vector3`.

This type is equivalent to *pw::Wizard::vtor::arr $val double 3 3*
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
</dl>
<br/>

### **pw::Wizard::vtor::int3** *val*
Validates an array of three integer values.
Aliases: `integer3`.

This type is equivalent to *pw::Wizard::vtor::arr $val int 3 3*
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
</dl>
<br/>

### **pw::Wizard::vtor::nop** *val*
Accepts any value without restriction.
Aliases: `any`, `none`.
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
</dl>
<br/>

### **pw::Wizard::vtor::arr** *val type ?minLen ?maxLen??*
Validates an array of same-typed values with an optional array length.
Aliases: `array`, `vec`, `vector`, `list`.
<dl>
  <dt><em>val</em></dt>
  <dd>The entry value being validated.</dd>
  <dt><em>type</em></dt>
  <dd>The array item type. This should be one of the registered validator
  types such as <em>int</em> or <em>double</em>.</dd>
  <dt><em>minLen</em></dt>
  <dd>If defined, the number of items in <em>val</em> must be greater than or
  equal to this value. If set to <b>inf</b>, <em>minLen</em> is not
  enforced.</dd>
  <dt><em>maxLen</em></dt>
  <dd>If defined, the number of items in <em>val</em> must be less than or equal
  to this value. If set to <b>inf</b>, <em>maxLen</em> is not enforced.</dd>
</dl>
<br/>

### Validator Helpers
The following helper procs are defined in the **pw::Wizard::vtor** namespace.
Custom validator can use these procs to implement their validation logic.

*  [pw::Wizard::vtor::listValIsLen](#pwwizardvtorlistvalislen-val-minlen-maxlen)
*  [pw::Wizard::vtor::valIsTypeArray](#pwwizardvtorvalistypearray-val-arrtype-minlen-maxlen)
*  [pw::Wizard::vtor::numInRange](#pwwizardvtornuminrange-val-minval-maxval)

#### **pw::Wizard::vtor::listValIsLen** *val minLen maxLen*
Returns true if *val* is a list with the specified number of items.
<dl>
  <dt><em>val</em></dt>
  <dd>The value being validated.</dd>
  <dt><em>minLen</em></dt>
  <dd>The number of items in <em>val</em> must be greater than or equal to this
  value. If set to <b>inf</b>, <em>minLen</em> is not enforced.</dd>
  <dt><em>maxLen</em></dt>
  <dd>The number of items in <em>val</em> must be less than or equal to this
  value. If set to <b>inf</b>, <em>maxLen</em> is not enforced.</dd>
</dl>
<br/>

#### **pw::Wizard::vtor::valIsTypeArray** *val arrType minLen maxLen*
Returns true if *val* is a list with the specified number of items of the
given type.
<dl>
  <dt><em>val</em></dt>
  <dd>The value being validated.</dd>
  <dt><em>arrType</em></dt>
  <dd>The array item type. This should be one of the registered validator
  types such as <em>int</em> or <em>double</em>.</dd>
  <dt><em>minLen</em></dt>
  <dd>The number of items in <em>val</em> must be greater than or equal to this
  value. If set to <b>inf</b>, <em>minLen</em> is not enforced.</dd>
  <dt><em>maxLen</em></dt>
  <dd>The number of items in <em>val</em> must be less than or equal to this
  value. If set to <b>inf</b>, <em>maxLen</em> is not enforced.</dd>
</dl>
<br/>

#### **pw::Wizard::vtor::numInRange** *val minVal maxVal*
Returns true if *val* is a list with the specified number of items.
<dl>
  <dt><em>val</em></dt>
    <dd>The value being validated.</dd>
  <dt><em>minVal</em></dt>
    <dd><em>val</em> must be greater than or equal to this value. If set to
    <b>inf</b>, <em>minVal</em> is not enforced.</dd>
  <dt><em>maxVal</em></dt>
    <dd><em>val</em> must be less than or equal to this value. If set to
    <b>inf</b>, <em>maxVal</em> is not enforced.</dd>
</dl>
<br/>


## pw::Wizard Library Usage Example

```Tcl
  # TBD
```


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
