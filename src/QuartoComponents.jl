module QuartoComponents

using Markdown

abstract type Object end
struct Container <: Object
    children
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
prettyprint(io, args...) = print(io, pretty(args)...)
# pretty(x::Expr) = if x.head == :macrocall
#     pretty(x.args[2:end])
# else
#     Expr(x.head, pretty(x.args)...)
# end
# pretty(::LineNumberNode) = []
pretty(x::Union{Vector,Tuple}) = begin
    rv = []
    for xi in x
        rvi = pretty(xi)
        isa(rvi, Vector) ? append!(rv, rvi) : push!(rv, rvi)
    end
    rv
end
pretty(x::String) = x
pretty(x::Object) = string(x)
pretty(x) = if isijulia()
    try
        io = IOBuffer()
        show(io, MIME("text/html"), x)
        "\n" * replace(strip(String(take!(io))), r"\n\s+"=>"\n") * "\n"
    catch
        string(x)
    end
else
    string(x)
end
Base.show(io::IO, m::MIME"text/markdown", x::Object) = print(io, Markdown.parse(string(x)))
Base.show(io::IO, x::Code) = prettyprint(io, "\n```", x.header, "\n", x.content, "\n```\n")
Base.show(io::IO, x::Container) = for child in x.children
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
