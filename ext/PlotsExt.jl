module PlotsExt

import Plots, QuartoComponents

const PLOTS_PATH = mktempdir()

QuartoComponents.pretty(x::Plots.Plot) = if QuartoComponents.isijulia()
    try
        io = IOBuffer()
        show(io, MIME("text/html"), x)
        "\n" * replace(strip(String(take!(io))), r"\n\s+"=>"\n") * "\n"
    catch
        string(x)
    end
else
    try
        mkpath(PLOTS_PATH)
        png_path = mktemp(PLOTS_PATH)[1] * ".png"
        Plots.png(x, png_path)
        "\n![$png_path]($png_path)\n"
    catch
        string(x)
    end
end

end