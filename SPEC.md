# Language Specification #

⚠️ This repo is WIP and subject to changes

The examples are written in a hybrid C#-JavaScript-like language. All members are public.

## Keywords ##

In ASDML, all keywords are prefixed by `@`.

## Literals ##

### Null literal ###

Null means something has no valid value. In ASDML, the null keyword is `@null`.

### Logical literals ###

In most languages, this is `bool` or `boolean`. There are two logical keywords: `@true` and `@false`.

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

#### Simple text literals ####

*Simple text literal*s are *text literal*s. They:

* can not contain whitespace or the following characters: `"()[]{}`
* do not begin with a digit or the following characters: `@#+-.`

*Simple text literal*s do not have quotation marks: `Hello`

#### Multiline text literals ####

*Multiline text literal*s are specific *text literal*s can span across multiple lines. These are prefixed by `@` and written between quotation marks:

``` asdml
@"This is a
multiline text literal"
```

### Array literals ###

*Array literal*s are collections of objects. The items of an *array* are written between `[` and `]` characters and separated with whitespace characters from each other: `[4 2 42]`

Arrays can be multiline:

``` asdml
[
  4
  2
  42
]
```

## Basic syntax ##

### Groups ###

In ASDML, *group*s refer to objects or classes in programming languages. *Group* names must be *simple text literal*s. The *group* name is followed by `{` . Let's create an empty window class:

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

#### Anonymous groups ####

*Anonymous group*s are *group*s that don't have name:

``` asdml
{
}
```

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

In ASDML, *properties* start with a period character. *Property* names must be *simple text literal*s. Property names are followed by the property value. The `window` object looks like this in ASDML:

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

*Group*s can have *ID*s to reference them at multiple locations or find them easily. *ID*s must be *simple text literal*s. *ID*s are written after the *group* name prefixed by `#`

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
