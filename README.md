# Boxer

Wraps a terminal message in boxes.

## Add to rebar.config

```erlang

{deps, [
	...,
	boxer %% <- add this right here
]}.
```

## Functions

### Printing and Formatting

* `boxer:print(Msg)`: Prints a message with the default box style (single-line)
* `boxer:print(Msg, LineDef)`: Prints a message with the specified `LineDef`
  (by default, supported are the atoms `single`, `double`, and `hash`).
* `boxer:wrap(Msg)`: Returns a unicode string list wrapped in the default box
  style (`single-line`).
* `boxer:wrap(Msg, LineDef)`: Returns a unicode string list wrapped in the
  specified `LineDef`.

## Customization

You can customize the box-style by creating new definitions (or changing the existing ones)

### Formatting the custom definitions

A Line Definition (Box Style) consists of the following information:

* A name (like `double` or `single`)
* A map with the following fields:

```erlang
#{
	chars =>
		[Horiz, Vert, TopLeft, TopRight, BottomRight, BottomLeft],
	h_padding =>
		HorizontalPadding,
	v_padding =>
		VerticalPadding
}
```

For example, the `single` line definition looks like this:

```erlang
#{
	chars => "─│┌┐┘└",
	h_padding => 0,
	v_padding => 0
}
```

### Adding via the Erlang shell

Here's how to add a sample definition that makes a simple border using just periods (dots).

```erlang
Def = #{chars=>"......", h_padding=>1},
boxer:add_line_def(dots, Def).
```

### Adding via configuration

To add the above dot example via config, add the following to your `app.config`:

```erlang

[
	{boxer, [
		{boxer_line_defs, [
			{dots, #{chars=>"......", h_padding=>1}}
		]}
	]}
].
```

## Comments and Contribution

Pull requests and Issues welcome!

Thanks!

## License and Copyright

Copyright 2024 [Jesse Gumm](http://jessegumm.com)

Licensed under the Apache 2.0 License
