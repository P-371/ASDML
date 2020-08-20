# Language Specification #

![Specification: v2.0.0](https://img.shields.io/badge/Specification-v2.0.0-blue)

The examples are written in a hybrid C#-JavaScript-like language. All members are public.

## Keywords ##

In ASDML, all keywords are prefixed by `@`.

## Literals ##

### Null literal ###

Null means something has no valid value. In ASDML, the null keyword is `@null` in any case. Therefore both `@Null` and `@NuLl` are valid for example.

### Logical literals ###

In most languages, this is `bool` or `boolean`. There are two logical keywords: `@true` and `@false`. The case does not matter just like at `@null`

### Number literals ###

Numbers are character sequences matching `^[\+-]?\d+(\.\d+)?([Ee][\+-]\d+)?$` regular expression. Try it on [RegExr](https://regexr.com/56lm8). This means:

* An optional `+` or `-` sign
* One or more digits
* Optional
  * Character `.` (decimal point)
  * One or more digits
* Optional (the previous number multiplied by a power of 10)
  * Character `E` or `e`
  * One `+` or `-` sign
  * One or more digits

### Text literals ###

In most languages, *text literal*s refer to `string`s. *Text literal*s are written between quotation marks: `"Hello World"`.

#### Escape sequences ####

| Escape sequence | Character        |
|-----------------|------------------|
| `\"`            | `"`              |
| `\#`            | `#`              |
| `\\`            | `\`              |
|                 |                  |
| `\0`            | Null character   |
| `\a`            | Alert            |
| `\b`            | Backspace        |
| `\f`            | Form feed        |
| `\n`            | Line feed        |
| `\r`            | Carriage return  |
| `\t`            | Horizontal tab   |
| `\v`            | Vertical tab     |
|                 |                  |
| `\x??` *        | Hexadecimal form |
| `\u????` *      | Unicode sequence |

\* replace `?`s with numbers

#### Simple text literals ####

*Simple text literal*s are *text literal*s. They:

* can contain only letters, digits and following characters: `._+-`
* begin with a letter or the following characters: `_`
* do not contain `\` or escape sequence

*Simple text literal*s do not have quotation marks: `Hello`

#### Multiline text literals ####

*Multiline text literal*s are specific *text literal*s can span across multiple lines. These are prefixed by `@` and written between quotation marks:

``` asdml
@"This is a
Multiline Text Literal"
```

### Array literals ###

*Array literal*s are collections of objects. The items of an *array* are written between `@[` and `]` characters and separated with whitespace characters from each other: `@[4 2 42]`

Arrays of ASDML Primitives should not specify types.

Arrays can be multiline:

``` asdml
@[
  4
  2
  42
]
```

Arrays can be empty: `@[]`

Arrays can have types. Arrays with types omit `@`

``` csharp
class Fruit {
}
class Pear : Fruit {
}

Fruit[] fruits = new Fruit[] { new Fruit(), new Fruit() };
Pear[] pears = new Pear[] { new Pear(), new Pear() };
```

These *array*s look like this in ASDML with types:

``` asdml
Fruit [
  Fruit { }
  Fruit { }
]
Pear [
  Pear { }
  Pear { }
]
```

...and without types:

``` asdml
@[
  Fruit { }
  Fruit { }
]
@[
  Pear { }
  Pear { }
]
```

Things start to get interesting in the following case:

``` csharp
class Fruit {
}
class Pear : Fruit {
}

Fruit[] fruits = new Pear[] { new Pear(), new Pear() };
```

One can't put a fruit in `fruits` because it's an array of pears! One can tell the actual array type in ASDML, but it isn't necessary. If the type isn't given, the type information will be unknown.

## Language elements ##

### Groups ###

In ASDML, *group*s refer to objects or classes in programming languages. *Group* names must be *simple text literal*s (see [naming conventions](#naming-conventions)). The *group* name is followed by `{` and the *group* is closed by `}`. Let's create an empty window class:

``` csharp
class Window {
}

Window window = new Window();
```

This very basic window looks like this in ASDML:

``` asdml
Window {
}
```

#### Generic groups ###

*Group*s can have generic parameters, like a generic dictionary:

``` csharp
class Dictionary<Key, Value> {
}

Dictionary<Key, Value> dictionary = new Dictionary<Key, Value>();
```

Generic parameters are written between `<` and `>` characters and separated with whitespace characters from each other, so the `dictionary` object looks like this in ASDML:

``` asdml
Dictionary<Key Value> {
}
```

#### Anonymous groups ####

*Anonymous group*s are *group*s that don't have name, a `@` is written instead:

``` asdml
@{
}
```

*Anonymous group*s can't be generic and can't have constructor.

In this case, the type is unknown. It can be a problem, when the type defined is abstract or is an interface. It is the parser's job to find a suitable type.

### Properties ###

Classes have *properties*. *Properties* have values. Let's add some *properties* to the window class:

``` csharp
class Window {
  int Width;
  int Height;
}

Window window = new Window();
window.Width = 800;
window.Height = 600;
```

In ASDML, *properties* start with a `.` character. *Property* names must be *simple text literal*s (see [naming conventions](#naming-conventions)). Property names are followed by the property value. The `window` object looks like this in ASDML:

``` asdml
Window {
  .Width 800
  .Height 600
}
```

Classes can have non-primitive *properties*. Let's add an OK button:

``` csharp
class Window {
  int Width;
  int Height;
  Button OkButton;
}
class Button {
  string Text;
}

Window window = new Window();
window.Width = 800;
window.Height = 600;
Button button = new Button();
button.Text = "Click me";
window.OkButton = button;
```

Non-primitive *properties* are like primitives, but in place the primitive value, a *group* is written:

``` asdml
Window {
  .Width 800
  .Height 600
  .OkButton Button {
    .Text "Click me"
  }
}
```

#### Top-level properties ####

*Top-level properties* are *properties* that aren't located in a *group*:

``` asdml
.TopLevel1 "This is a top-level property"
.TopLevel2 "This is another"

Group {
  .Property1 "This isn't a top-level property"
  .Property2 "Neither is this"
}
```

*Top-level properties* have special meanings. This can control, for example, how the parser or transpiler works, lets one import things and so on. See [special top-level properties](#special-top-level-properties)

### Nested content ###

Some objects can have children or items (for example, a GUI window, arrays, lists, IEnumerable in C#, Iterable in Java).

In ASDML, *group*s can have nested content (*nested objects*). *Nested objects* have no prefix. A *group* can have arbitrary number of *nested objects*. Let's create a list and add some objects to it:

``` asdml
List {
  Hello
  There
  "General Kenobi"
}
```

*Group*s can also be added as nested content. Let's add some controls to the window:

``` csharp
class Window {
  int Width;
  int Height;
  void Add(Control control);
}
interface Control {
}
class TextBox : Control {
  string Text;
}
class Button : Control {
  string Text;
}

Window window = new Window();
window.Width = 800;
window.Height = 600;
TextBox textBox = new TextBox();
textBox.Text = "Hello";
window.Add(textBox);
Button button = new Button();
button.Text = "Click me";
window.Add(button);
```

For example, a window containing a `TextBox` and a `Button` looks like this in ASDML:

``` asdml
Window {
  .Width 800
  .Height 600
  TextBox {
    .Text Hello
  }
  Button {
    .Text "Click me"
  }
}
```

### IDs ###

*Group*s can have *ID*s to reference them at multiple locations or find them easily. *ID*s must be *simple text literal*s (see [naming conventions](#naming-conventions)). *ID*s are written after the *group* name prefixed by `#`

``` asdml
Window #win {
}
```

Let's create a window and a button. Add the button to the window and also set as the OK button:

``` csharp
class Window {
  int Width;
  int Height;
  Button OkButton;
  void Add(Button button);
}
class Button {
  string Text;
}

Window window = new Window();
window.Width = 800;
window.Height = 600;
Button button = new Button();
button.Text = "Click me";
window.Add(button);
window.OkButton = button;
```

Give `#ok` *ID* to the button and reference it at the `OkButton` property:

``` asdml
Window {
  .Width 800
  .Height 600
  .OkButton #ok
  Button #ok {
    .Text "Click me"
  }
}
```

The button can also be created at the `OkButton` property and added as nested content. Writing `#ok` as a *nested object* is perfectly valid:

``` asdml
Window {
  .Width 800
  .Height 600
  .OkButton Button #ok {
    .Text "Click me"
  }
  #ok
}
```

The button also can be created outside the window object:

``` asdml
Window {
  .Width 800
  .Height 600
  .OkButton #ok
  #ok
}
Button #ok {
  .Text "Click me"
}
```

Primitives and *anonymous group*s can't have *ID*s because the *ID* would add the *group* with that *ID* as a *nested object* there instead of giving the *ID* to the primitive/*anonymous group*

### Constructors ###

``` csharp
class Window {
  constructor(int width, int height, string title);
}

Window window = new Window(800, 600, "Hello world");
```

Constructor *parameters* are written after the *group* name in parenthesis, separated with whitespace characters from each other. The *ID* can be written after the constructor *parameters*:

``` asdml
Window (800 600 "Hello World") #win {
}
```

*Anonymous group*s can't have constructors

## Special top-level properties ##

Special top-level properties are case-insensitive but should follow [naming conventions](#naming-conventions)

### Imports ###

Syntax: `.Imports @[ "/path/to/first.asdml" "/path/to/second.asdml" ]`

Type: `Text[]` (array type shouldn't be specified)

Other ASDML files can be imported and used. This allows one to access references and groups in imported files. Array items can be relative path, absolute path or URI and are case-sensitive.

## Whitespace and tabulation ##

In ASDML, whitespace characters are separator characters. ASDML doesn't care about:

* The tabulation
* The amount or kind of whitespace characters
* Line breaks: every word can be written in their own lines or in one line

But there are some rules to keep in mind:

| Position                                  | Whitespace character  | Required |
|-------------------------------------------|-----------------------|----------|
| Before `@`                                | Any                   | Yes      |
| After `@`                                 | None                  | -        |
| Before `[`                                | Any                   | No       |
| After `[`                                 | Any                   | No       |
| Before `]`                                | Any                   | No       |
| After `]`                                 | Any                   | No       |
| Between array items                       | Any                   | Yes      |
| Before `{`                                | Any                   | No       |
| After `{`                                 | Any                   | No       |
| Before `}`                                | Any                   | No       |
| After `}`                                 | Any                   | No       |
| Before `<`                                | Any                   | No       |
| After `<`                                 | Any                   | No       |
| Before `>`                                | Any                   | No       |
| After `>`                                 | Any                   | No       |
| Between generic parameters                | Any                   | Yes      |
| Before `.`                                | Any                   | Yes      |
| After `.`                                 | None                  | -        |
| Between property name and property value  | Any                   | Yes      |
| Between nested objects                    | Any                   | Yes      |
| Between property name and nested objects  | Any                   | Yes      |
| Between property value and nested objects | Any                   | Yes      |
| Before `#`                                | Any                   | Yes      |
| After  `#`                                | None                  | -        |
| Before `(`                                | Any                   | No       |
| After `(`                                 | Any                   | No       |
| Before `)`                                | Any                   | No       |
| After `)`                                 | Any                   | No       |
| Between constructor parameters            | Any                   | Yes      |

## Naming conventions ##

* *Property* names and *Group* names should be PascalCase
* *ID*s should be camelCase
