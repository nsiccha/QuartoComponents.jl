module PlotsExt

import Plots, QuartoComponents, Base64

const PLOTS_PATH = mktempdir()

QuartoComponents.pretty(x::Plots.Plot) = if QuartoComponents.isijulia()
    try
        io = IOBuffer()
        if QuartoComponents.islazy()
            iob64_encode = Base64.Base64EncodePipe(io)
            show(iob64_encode, MIME("text/html"), x)
            close(iob64_encode)
            encoded_html = String(take!(io))
            element_id = hash(encoded_html)
            """
<div id="$element_id" onclick="if(this.getElementsByTagName('script').length == 0){this.innerHTML = window.atob('$encoded_html');eval(this.getElementsByTagName('script')[0].innerText);}" onmouseover='this.click()'>
Click or hover to load!
</div>
            """
        else
            show(io, MIME("text/html"), x)
            "\n" * replace(strip(String(take!(io))), r"\n\s+"=>"\n") * "\n"
        end
    catch
        rethrow()
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