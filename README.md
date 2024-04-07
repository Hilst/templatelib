# Templatelib

Templatelib is a elixir library that can parse any text an alter it based on general template principles

Meaning, it wold receive both data of any format and string format data and merge than into a consistent string format

V0 objective:

From:
```html
<p>
  This data{{ /documents/brazilian/cpf | asstring | padding direction=left with=0 until=11 | mask ###.###.###-## }} is formatted as a Brazilian identification CPF
</p>
```
and

```json
{
  "documents": {
    "brazilian": {
      "cpf": 1234567890
    }
  }
}
```
To:
```html
<p>This data 012.345.678-90 is formatted as a Brazilian identification CPF</p>
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `templatelib` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:templatelib, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/templatelib>.
