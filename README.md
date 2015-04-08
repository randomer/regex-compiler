# regex-compiler

## The problem
For something like "colou?r" regular expressions are neat. However, they get cumbersome and unwieldy pretty quickly when you try to do something more serious, like verify a user's nickname or URL: they become unreadable, non-maintainable and hard-to-edit programmatically.

## The solution
With this module you can describe regular expressions using singleton objects. Let's describe a phone number:

```coffee
phoneNumRegex = new Pattern
    pattern: 'nnn-nnnn'
    nnn:
        chars: '0..9'
        length: '3'
    nnnn:
        chars: '0..9'
        length: '4'
    .getRegex()
```

As you can see, there are two "variables" inside this pattern (`nnn` and `nnnn`) and the hyphen is translated literally. The rest is pretty self-explanatory: both variables have to be numbers from 0 to 9 (`x..x` translates to `x-x` in regex), the length of the first one has to be exactly 3 characters, and the second one is 4. Then we call the 'getRegex' method which returns a regular expression that matches the pattern we just described.

Since it's a simple object, everything can be passed as a variable and is easy to alter. On top of that, the verbosity makes it maintainable.

Let's try something else:

```coffee
fileRegex = new Pattern
    pattern: 'filename.ext'
    filename:
        chars: 'A..z 0..9 \\s _ ' # Here the \s means include spaces (no tabs or anything else)
        length: '1+' # One or more characters
    ext:
        chars: 'A..z'
        length: '1-3'
    .getRegex()
```

As you can see, the pattern here is a little more complicated, but still easily understandable: 'filename' can have letters, numbers, spaces and underscores and the length should be 1 or more characters for the filename, and from 1 to 3 for the extension.

You can find more documentation inside the [wiki](../../wiki).

# Note
This project is still work in progress — there will most likely be some breaking changes since I'm still deciding on the syntax and naming of the properties. Testing different patterns is encouraged, not recommended for production (yet ;-)
