# glyph-wizard API

### Table of Contents
* [The pw::Wizard Library](#the-pwwizard-library)
* [pw::Wizard Command Docs](#pwwizard-command-docs)
* [pw::Wizard Library Usage Example](#pwwizard-library-usage-example)
* [Creating Pages](#creating-pages)
* [Predefined Validators](#predefined-validators)
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


## pw::Wizard Command Docs

### **pw::Wizard page add** *name script*

The **page add** command is used to create a wizard page object.
<dl>
  <dt><em>name</em></dt>
  <dd>The page object name. Can be any valid tcl variable name.</dd>
  <dt><em>script</em></dt>
  <dd>The tcl/Tk script used to create the page widgets and layout. This script is 
  not executed immediately. It is executed later in the call to <em>pw::Wizard run</em>. 
  See the Creating Pages section for more details.</dd>
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
  <dd>The proc called to validate a value. The proc must use the call signature
  <code>{ val args }</code>.</dd>
  <dt><em>valTypes</em></dt>
  <dd>The list of type names that use this validator proc. If empty (the
  default), the value returned by <code>[namespace tail $procName]</code> is used. In the
  list, <em>@</em> is shorthand for <code>[namespace tail $procName]</code>.</dd>
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
  <dd>The proc called to validate a value. The proc must use the call signature
  <code>{ val args }</code>.</dd>
  <dt><em>valTypes</em></dt>
  <dd>The list of type names that use this validator proc. If empty (the
  default), the value returned by <code>[namespace tail $procName]</code> is used. In the
  list, <em>@</em> is shorthand for <code>[namespace tail $procName]</code>.</dd>
</dl>
<br/>


### **pw::Wizard configure** *?option? ?value option value ...?*

The **configure** command sets **pw::Wizard** attribute values. If called
without any options, a list of all valid options is returned.

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
*procName* must have the `{ status widgetPath }` call signature. This proc is
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
  <dd>One of the valid *configure* options.</dd>
</dl>
<br/>


### **pw::Wizard run**

The **run** starts the application, runs the page creation scripts, and displays the wizard dialog box.


## pw::Wizard Library Usage Example

```Tcl
  # TBD
```


## Creating Pages

Page creation scripts have access to two, wizard-defined variables, *page* 
and *pgFrame*. *page* is the same value as passed in the *name* argument. 
*pgFrame* is the page's frame widget path. The page's widget hierarchy 
should use this path as its root.
  
wizentry pgFrame varName varTypeSpec ?entryOpts?


## Predefined Validators

The following, predefined validators are added by **pw::Wizard**. The validation
procs are defined in the **pw::Wizard::vtor** namespace.

```Tcl
  addValidator vtor::double {@ real float}
  addValidator vtor::text {@ str string}
  addValidator vtor::int {@ integer}
  addValidator vtor::vec3 {@ real3 double3 float3 vector3}
  addValidator vtor::int3 {@ integer3}
  addValidator vtor::nop {@ any none}
  addValidator vtor::arr {@ array vec vector list}
```

### **int** *val ?minVal ?maxVal??*
### **double** *val ?minVal ?maxVal??*
### **text** *val*
### **vec3** *val*
### **int3** *val*
### **nop** *val*
### **arr** *val type ?minLen ?maxLen??*


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
