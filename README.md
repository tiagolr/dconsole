# DConsole

**DConsole** or **The Console** is a real-time console that allows to:
 
* Run scripts.
* Access and modify fields and objects.
* Call registered functions.
* Monitor fields.
* Customize appearence.
* Profile the app in realtime.
* Register new commands that respond to user input.



**Major Changes**
V 4.0.0
* Renamed GameConsole/GConsole to TheConsole or DConsole
* Lib classes starting with GC renamed to DC
* Switched to hscript as default interp
* Added command registering
* Small fixes and improvements
* Aliases are sanitized and guaranteed to be unique
* Autocomplete removed temporarily.

For more changes or other versions, see CHANGELOG. <br/><br/>
The console uses **openfl** and supports multiple targets (**flash**, **cpp** and **neko**).<br/>
Multiple rendering devices and html5 may be availibe in time.

____________

### Install

```
haxelib install dconsole
```

### Getting Started

Using dconsole is very straightforward and it can be setup in a few steps:

```actionscript
import pgr.dconsole.DC;

DC.init();
DC.log("This text will be logged.");
DC.registerFunction(this.testFunction, "myfunction");
DC.registerObject(this, "myobject");
```

Now while running your application, press **TAB** to show the console and type **"help"** or **"commands"**
to see what commands are availible, **"objects"** and **"functions"** are useful to show registered objects and functions.

![help](http://i1148.photobucket.com/albums/o562/ProG4mr/dconsole1_zps2287758b.png "help")

The console can now be used to control your application, access and modify data in realtime
without having to re-compile.

Since hscript replaced the original basic parser, its now possible to evaluate complex expressions and scripts using haxe sintax.

![example](http://i1148.photobucket.com/albums/o562/ProG4mr/dconsole2_zpsa362d475.png "example")

Its even possible to do maths, students homework will never be the same.

### Monitor<br />

The console allows you to register fields and monitor them in real time.
For example, to monitor a display object x position:
```js
DG.monitorField(player, "x", "playerX");  
```

Pressing **CTRL + TAB** brings up the monitor that shows the variable updated in real time
![monitor](http://i1148.photobucket.com/albums/o562/ProG4mr/monitor_zps1cba1388.jpg "monitor")
The screenshot shows monitor being used in Adam Atomic's Mode demo.

### Profiler<br />

The profiler is lightweight and portable and allows to know: 

* What code is taking more cpu
* How many times is some code executed inside other code block.
* How much time code takes to execute (benchmark)
* Other statistics that are not included like absolute elapsed, min, max, totalInstances etc..

To profile a block simply do:
```js
DC.beginProfile("SampleName");
DC.endProfile("SampleName");
```
Now toggling the profiler with **SHIFT + TAB** shows real-time statistics that are updated according to refresh rate. <br />

![profiler](http://i1148.photobucket.com/albums/o562/ProG4mr/profiler_zps30be5bb6.jpg "profiler")
The screenshot shows the profiler using multiple nested samples, idents are used to vizualize the samples hierarchy.<br />

* **EL** elapsed milliseconds)
* **AVG** average elapsed milliseconds)
* **EL(%)** elapsed percentage
* **AVG(%)** average elapsed percentage
* **#** Occurrences of sample inside root sample
* **Name** Sample name
<br />

### Tips<br />

* Console can have fullscreen using DC.init(1) where 1 means 100% screen height.
* Registering commands allows to add new behavior to the console based on user input (see other registered commands).
* Profiler can be configured to display other statistics, see DCProfiler.writeOutput()
* Profiler and Monitor refresh rate are also configurable.
* Private functions, private fields and fields with getter and setter can also be accessed.
* Using DCCommands.evaluate() can be used to evaluate a string directly.
* To expose more classes to the interpreter (other than Math) use DCCommands.hscriptInterp.variables.set("name", Class)

### Suggestions / Comments / Bugs 

[Email me](mailto:prog4mr@gmail.com) suggestions, comments, bug reports etc..<br />
Or create a new issue (even better). 

### Contributions

Bug reports and feedback are very welcomed.

To contribute code make sure tests work by running tests/testFlash.bat, testNeko.bat and testWindows.bat. Update tests or write new ones if necessary, the goal is to make sure the console basic functionality 
is likely to be working on all targets.

**Big thanks** to every one contributing to this project so far!

