module QuartoComponents

using Markdown, CRC32c, Base64

abstract type Object end
struct Container <: Object
    content
end
struct Heading <: Object 
    level
    content
end
struct Div <: Object
    header
    content
end
struct Code <: Object 
    header
    content
end
struct Tabset <: Object
    content
end
isijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited
islazy() = parse(Bool, get(ENV, "QUARTOCOMPONENTS_LAZY", "false"))
islazy!(val) = ENV["QUARTOCOMPONENTS_LAZY"] = val
prettyprint(io, args...) = print(io, pretty(args)...)
pretty(x::Union{Vector,Tuple}) = begin
    rv = []
    for xi in x
        rvi = pretty(xi)
        isa(rvi, Vector) ? append!(rv, rvi) : push!(rv, rvi)
    end
    rv
end
pretty(x::String) = x
pretty(x::Symbol) = "`$x`"
pretty(x::Object) = string(x)
pretty(x) = if isijulia() && html_preferred(x)
    maybelazyhtml(x)
else
    string(x)
end
html_preferred(x) = false
hash_function(x) = crc32c
html_kwargs(x) = (;)
maybelazyhtml(x; kwargs...) = if QuartoComponents.islazy()
    lazyhtml(x; kwargs...)
else
    io = IOBuffer()
    show(io, MIME("text/html"), x; html_kwargs(x)..., kwargs...)
    "\n" * replace(strip(String(take!(io))), r"\n\s+"=>"\n") * "\n"
end
lazyhtml(x; kwargs...) = begin 
    io = IOBuffer()
    iob64_encode = Base64.Base64EncodePipe(io)
    show(iob64_encode, MIME("text/html"), x; html_kwargs(x)..., kwargs...)
    close(iob64_encode)
    encoded_html = String(take!(io))
    element_hash = string(hash_function(x)(encoded_html))
    absolute_path = joinpath(ENV["QUARTO_PROJECT_ROOT"], ".QuartoComponents", "$element_hash.js")
    quarto_path = "/.QuartoComponents/$element_hash.js"
    if !isfile(absolute_path)
        mkpath(dirname(absolute_path))
        open(absolute_path, "w") do io
            write(io, """
document.getElementById("$element_hash").innerHTML = window.atob("$encoded_html");
for(let s of document.getElementById("$element_hash").getElementsByTagName('script')){eval(s.innerText);}
""")
        end
    end
    """
    <div id="$element_hash" onclick="
        this.onclick = '';
        this.innerHTML = 'Loading...';
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = '$quarto_path';
        this.appendChild(script);
    " onmouseover='this.click()'>
    Click or hover to load ($(Base.format_bytes(filesize(absolute_path))))[!]($quarto_path)
    </div>
    """
end

Base.show(io::IO, m::MIME"text/markdown", x::Object) = print(io, Markdown.parse(string(x)))
Base.show(io::IO, x::Code) = prettyprint(io, "\n```", x.header, "\n", x.content, "\n```\n")
Base.show(io::IO, x::Container) = for child in x.content
    prettyprint(io, child, "\n")
end
Base.show(io::IO, x::Heading) = prettyprint(io, repeat("#", x.level), " ", x.content, "\n\n")
Base.show(io::IO, x::Div) = begin 
    prettyprint(io, "\n::: ", x.header, "\n\n")
    prettyprint(io, x.content)
    prettyprint(io, "\n:::\n")
end
Base.show(io::IO, x::Tabset) = begin
    prettyprint(io, Div("{.panel-tabset}", Container([
        Container([
            Heading(1, key),
            value
        ])
        for (key, value) in pairs(x.content)
    ])))
end

end # module QuartoComponents
