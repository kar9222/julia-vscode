# this script basially only handles `ARGS`


if "USE_REVISE" in Base.ARGS
    ENV["JULIA_REVISE"] = "auto"
end

Base.push!(LOAD_PATH, joinpath(@__DIR__, "..", "packages"))
using VSCodeServer
pop!(LOAD_PATH)

let
    args = [popfirst!(Base.ARGS) for _ in 1:5]
    # load Revise ?
    if "USE_REVISE=true" in args
        VSCodeServer.g_use_revise[] = true
        try
            @static if VERSION < v"1.5"
                Revise.async_steal_repl_backend()
            end
        catch err
        end
    end

    ENV["JULIA_REVISE"] = "manual"

    atreplinit() do repl
        "USE_PLOTPANE=true" in args && Base.Multimedia.pushdisplay(VSCodeServer.InlineDisplay())
    end

    conn_pipeline, telemetry_pipeline = args[1:2]
    VSCodeServer.serve(conn_pipeline; is_dev="DEBUG_MODE=true" in args, crashreporting_pipename=telemetry_pipeline)
end
