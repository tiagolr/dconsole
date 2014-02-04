# Game Console

Game Console is a real-time console that allows you to:

* View or edit variables.
* Call methods.
* Log messages.
* Monitor variables.
* Monitor methods.
* Customize appearence with themes.
* Profile your app (soon).
* Add your own commands by extending this lib.
* Autocomplete (in progress).

Notes and changes:<br />

V 2.00<br />

* AutoAlias - If no alias is passed, an alias is generated based on the class name. <br />
* Message logging can now be colored. <br />
* Can now register objects and access its methods and functions(eg: set registeredMC.x 20)
* AutoComplete works for one level of depth (does not work yet for object.object.field).
* Arguments autocomplete by A.Pecheney. (toggle arguments key = "F1" atm)

V 1.10<br />

* Gconsole works with flash and neko targets without nme lib.<br />
* Flash, cpp and neko targets have been tested and working fine.<br />
* If you're not using Windows, default font may look bad, use GameConsole.setConsoleFont() in that case.<br />
* The main interface has been renamed from GC to GameConsole.

____________

### Example

Using gconsole is very straightforward:

```js
    import pgr.gconsole.GameConsole;

    GameConsole.init();
    GameConsole.log("This text will be logged.");
    GameConsole.registerVariable(object, "variable name"); 
    GameConsole.registerFunction(object, "function name");
	GameConsole.registerObject(object);
```

Now while running your game or app, press **TAB**, then type **"help"** or **"commands"**
to see what commands or keys are availible.

For more help and check the [Wiki](https://github.com/ProG4mr/gconsole/wiki) (may not be up-to-date) and/or see the comments in GameConsole.hx.

### Screenshots<br />

A screen shot of gconsole running on Adam's Atomic Mode game.<br />
![ss3](http://i1148.photobucket.com/albums/o562/ProG4mr/ss3.png "Using Mode game")<br /><br />

### In the future:

* Better sintax using object.field = x and object.function() instead of get function and set field.
* Better autocomplete behaviour (similar to blender console).
* No depth restrictions autocomplete and object fields and methods access. (can do object.object.object.x = value)
* Profiler.

### Suggestions / Comments / Bugs 

[Email me](mailto:prog4mr@gmail.com) any suggestions, comments, bug reports etc.. you have.<br />
Or create a new issue (even better). 


Thank you, enjoy.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ProG4mr/gameconsole/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
