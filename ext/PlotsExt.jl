module PlotsExt

import Plots, QuartoComponents

QuartoComponents.html_preferred(x::Plots.Plot) = true
QuartoComponents.pretty(x::Plots.Plot) = if QuartoComponents.isijulia()
    QuartoComponents.maybelazyhtml(x)
else
    display(x)
    string(x)
end

end