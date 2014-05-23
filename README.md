# Game Console

Game Console is a real-time console that allows you to:

* View or edit variables.
* Call methods.
* Log messages.
* Monitor variables.
* Monitor methods.
* Customize appearence with themes.
* Profile your app
* Add your own commands by extending this lib.
* Use basic autocomplete


V 3.0.0

* API changes - GameConsole renamed to GC, registerFunction changed, registerFieldRemoved etc..
* Monitor improved and refactored.
* Print command added.
* Profiler added
* Added unit tests to ensure core working with neko, cpp and flash targets.

For more changes or other versions, check CHANGELOG file.

____________

### Example

Using GameConsole is very straightforward:

```js
    import pgr.gconsole.GC;

    GC.init();
    GC.log("This text will be logged.");
    GC.registerFunction(this.testFunction, "functionAlias");
	GC.registerObject(this, "objectAlias");
```

Now while running your game or app, press **TAB**, then type **"help"** or **"commands"**
to see what commands or keys are availible.

For more help and check the [Wiki](https://github.com/ProG4mr/gconsole/wiki) (may not be up-to-date) and/or see the comments in GC.hx.

### Screenshots<br />

A screen shot of gconsole running on Adam's Atomic Mode game.<br />

![ss](http://i1148.photobucket.com/albums/o562/ProG4mr/gameconsole_zpsca86ae2d.jpg "ss")
<br /> <br />
comming soon

### Monitor<br />

Allows to follow the values of registered fields, (including private fields and with getter methods)<br />

For example, to monitor player x position:
```js
CG.monitorField(player, "x", "playerX")  
```

Thats it! Press **CTRL + TAB** to bring the monitor up inside the game <br />
![monitor](http://i1148.photobucket.com/albums/o562/ProG4mr/monitor_zps1cba1388.jpg "monitor")
<br /> <br />


### Profiler<br />

GCProfiler is lightweight and portable, it allows to know in runtime:

* What code is taking more cpu
* How many times is some code executed inside other code block.
* How much time code takes to execute (benchmark)
* Other statistics not displayed (absolute elapsed, min, max, totalInstances etc..)

To profile a block simply do:
```js
GC.beginProfile("SampleName");
GC.endProfile("SampleName");
```
To toggle the profiler use **SHIFT + TAB**. <br />
The screenshot below shows multiple nested samples, idents are used to show the samples hierarchy.<br />

![profiler](http://i1148.photobucket.com/albums/o562/ProG4mr/profiler_zps30be5bb6.jpg "profiler")
<br /> 
* **EL** elapsed milliseconds)
* **AVG** average elapsed milliseconds)
* **EL(%)** elapsed percentage
* **AVG(%)** average elapsed percentage
* **#** Occurrences of sample inside root sample
* **Name** Sample name
<br />

More documentation and examples comming soon.



### Suggestions / Comments / Bugs 

[Email me](mailto:prog4mr@gmail.com) any suggestions, comments, bug reports etc.. you have.<br />
Or create a new issue (even better). 

### Contributions

Make sure tests work with your changes by running tests/testFlash.bat, testNeko.bat, testWindows.bat
Update tests or write new ones if necessary, the objective is to garantee the console works in all targets
as its supposed to.

#### Contributors

Thanks to:

* Artem Pecheny
* Jesse Talavera
* Samuel Batista
* Alexander Hohlov

And others submiting issues/feedback so far.
