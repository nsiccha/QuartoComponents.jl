# QuartoComponents.jl

Allows programmatically generating some [Quarto](https://quarto.org/) components, which may include GR or PlotlyJS plots. 
See [https://nsiccha.github.io/QuartoComponents.jl/#example](https://nsiccha.github.io/QuartoComponents.jl/#example) for an example.

## Current features

Allows defining the following elements:

* `Container(children)` (`children` should be iterable)
* `Heading(level, content)`
* `Div(header, content)`
* `Code(header, content)`
* `Tabset(content)`  (`content` should support `pairs(content)`)

Currently nothing gets exported.

## Current limitations

I'm sure there's a way around that, but for PlotlyJS plots to render, you have to potentially manually ensure that [`require.js`](https://requirejs.org/) is loaded. This can be done by adding the following to the Quarto YAML header, though I'm sure there's a better way to do it:

```yaml
format: 
    html:
        include-in-header:
            text: |
                <script src="https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js" integrity="sha512-c3Nl8+7g4LMSTdrm621y7kf9v3SDPnhxLNhcjFJbKECVnmZHTdo+IRO05sNLTH/D3vA6u1X32ehoLC7WFVdheg==" crossorigin="anonymous"></script>
```