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

Notes:<br />

* Gconsole needs nme installed.<br />
* Flash and Cpp targets tested and working fine.<br />
* If you're not using Windows, default font may look bad, use GC.setFont() in that case.
____________

### Example

Using gconsole is very straightforward:

```js
    GC.init();
    GC.log("This text will be logged.");
    GC.registerVariable(object, "variable name", "variable alias");
    GC.registerFunction(object, "function name", "function alias");
```

Now while running your game or app, press **TAB**, then type **"help"** or **"commands"**
to see what commands or keys are availible.

For more detailed information and examples visit:<br />
Wiki link<br />
For api documentation go to:<br />
haxelib docs link<br />

### Screenshots<br />

A screen shot of gconsole running on Adam's Atomic Mode game.<br />
![ss3](http://i1148.photobucket.com/albums/o562/ProG4mr/ss3.png "Using Mode game")<br /><br />

For more screenshots, configuration tips etc.. check (again) wiki link<br />  

### Suggestions / Comments / Bugs 

[Email me](mailto:prog4mr@gmail.com) any suggestions, comments, bug reports etc.. you have.<br />
Or create a new issue (better for some cases). 


Thank you, enjoy.