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

comming soon

### Profiler<br />

comming soon

### Monitor<br />

comming soon.

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
* Samuel Baptista
* Alexander Hohlov

And others submiting issues/feedback so far.
