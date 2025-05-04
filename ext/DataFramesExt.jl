module DataFramesExt

import DataFrames, QuartoComponents

QuartoComponents.html_preferred(x::DataFrames.DataFrame) = true
QuartoComponents.html_kwargs(x::DataFrames.DataFrame) = (;
    summary=false,
    eltypes=false,
    table_class="data-frame table table-sm table-striped small",
    show_row_number=false
)
QuartoComponents.pretty(x::DataFrames.DataFrame) = if QuartoComponents.isijulia()
    QuartoComponents.maybelazyhtml(x)
else
    display(x)
    "Dataframe(...)"
end

end
