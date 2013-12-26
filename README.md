# Game Console

This fork of [Game Console](https://github.com/ProG4mr/gameconsole) introduces autocompletion. Documentation about Game Console usage not concerned with autocompletion see on original project's page.

## Features

* Autocomplete commands and registered functions
* Cyclic switch between all available options
* Autocomplete function arguments within options defined by user (see examples).

## Changes

* Default console toggle hotkey was changed to `. Tab used for cycling autocompletion options.
* call command was removed from console. Registered functions can be called directly by name.

## Usage

Type something in the console and press tab until you get desired option. While you press tab console will switch options for part entered manually. After you press any other key whole completed string will be treated as new beginning for completion. If You want to start completing arguments you need have full funcion name in the input and at least one space after it.
Autocompletion for function's name enabled by default just after registration. The way of completion function arguments you can define in a function given as last argument of GameConsole.registerFunction():

```js
    GameConsole.registerFunction(object, "function name", "function alias", completionFunction);
```
completionFunction takes string of part entered manually as a parameter and should  return array of available options for current beginning.

## Examples

Cycle arguments from given list ignoring all placed after  name of the function:
```js
GameConsole.registerFunction(this, "emptyFunc", "empty",
		function(s:String) {
			return ["foo", "bar"];
		});
```

Cycle options with respect to beginning placed after name of the function:

```js
GameConsole.registerFunction(this, "traceArg", "lust", true, function(s:String) {
            return ["bar", "foo"].filter(
                function(val:String) {
                    if (s == "") return true;
                    return val.indexOf(s) == 0 ;
                });
        });
```
Place mouse cursor position after function:
```js
GameConsole.registerFunction(this, "traceArg", "lust", true, function(s:String) {
            return [""+ Lib.current.stage.mouseX  + " " + Lib.current.stage.mouseY ];
        });
```


