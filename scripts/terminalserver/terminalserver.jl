# this script basially only handles `Base.ARGS`

if "USE_REVISE" in Base.ARGS
    ENV["JULIA_REVISE"] = "auto"
end

Base.push!(LOAD_PATH, joinpath(@__DIR__, "..", "packages"))
using VSCodeServer
pop!(LOAD_PATH)

if "USE_REVISE" in Base.ARGS
    VSCodeServer.g_use_revise[] = true
    VSCodeServer.Revise.async_steal_repl_backend()
end

ENV["JULIA_REVISE"] = "manual"

atreplinit() do repl
    "USE_PLOTPANE" in Base.ARGS && Base.Multimedia.pushdisplay(VSCodeServer.InlineDisplay())
end

let
    conn_pipeline, telemetry_pipeline = Base.ARGS[1:2]
    VSCodeServer.serve(conn_pipeline; is_dev="DEBUG_MODE" in Base.ARGS, crashreporting_pipename=telemetry_pipeline)
end
