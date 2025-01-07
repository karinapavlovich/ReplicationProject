module ReplicationProject

using DataFrames
using StatFiles
using Plots
using Statistics

const DEFAULTS = Dict(
    :root => "",
    :code_dir => "",
    :logs_dir => "",
    :data_dir => "",
    :tmp_dir => "",
    :results_main => "",
    :results_apx => ""
)

# Set root directory and initialize paths
function set_root_directory(path::String)
    DEFAULTS[:root] = "/Users/path/rtp/"
    DEFAULTS[:code_dir] = joinpath(path, "code/")
    DEFAULTS[:logs_dir] = joinpath(DEFAULTS[:code_dir], "logs/")
    DEFAULTS[:data_dir] = joinpath(path, "data/analysis/")
    DEFAULTS[:tmp_dir] = joinpath(path, "data/tmp/")
    DEFAULTS[:results_main] = joinpath(path, "results/main/")
    DEFAULTS[:results_apx] = joinpath(path, "results/appendix/")
    println("Directories initialized.")
end

# Carry forward missing values
function carryforward!(df::DataFrame, col::Symbol)
    for i in 2:size(df, 1)
        if ismissing(df[i, col])
            df[i, col] = df[i - 1, col]
        end
    end
end

# Handle empty or missing-only data
function safe_mean_skipmissing(v::AbstractVector)
    collected = collect(skipmissing(v))
    return isempty(collected) ? missing : mean(collected)
end

function preprocess_data(filename::String)::DataFrame
    filepath = joinpath(DEFAULTS[:data_dir], filename)
    if !isfile(filepath)
        error("The file $(filepath) does not exist. Please verify the file path.")
    end

    # Load data
   
    data = DataFrame(load(filepath))

    # Convert integer flags to Bool, coalescing missing to false
    data[!, :m_status_bool]  = coalesce.(data.m_status1 .== 2, false)
    data[!, :solar_hit_bool] = coalesce.(data.m_solar_hit .!= 0, false)
    data[!, :washer_hit_bool]= coalesce.(data.m_washer_hit .!= 0, false)
    data[!, :alum_hit_bool]  = coalesce.(data.m_alum_hit .!= 0, false)
    data[!, :eu_bool]        = coalesce.(data.eu .!= 0, false)


    # Create new columns

    data.m_target  = data.m_status_bool

    data.eventtime = data.mdate .- data.m_effective_mdate1

    # Tariff wave variables
    data.solar_stat = ifelse.(
        (data.m_target .== 1) .& (data.m_solar_hit .== 1),
        data.m_stattariff1,
        missing
    )

    data.washer_stat = ifelse.(
        (data.m_target .== 1) .& (data.washer_hit_bool .== 1),
        data.m_stattariff1,
        missing
    )

    data.alum_stat = ifelse.(
        (data.m_target .== 1) .& (data.m_alum_hit .== 1),
        data.m_stattariff1,
        missing
    )

    data.alum1_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_alum_hit, 0) .== 1) .&
        (coalesce.(data.eu, 0) .== 0) .&
        .!in(["CANADA", "MEXICO"], coalesce.(data.cty_name, "")),
        data.m_stattariff1,
        missing
    )

    data.alum2_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_alum_hit, 0) .== 1) .&
        (
            (coalesce.(data.eu, 0) .== 1) .|
            in(["CANADA", "MEXICO"], coalesce.(data.cty_name, ""))
        ),
        data.m_stattariff1,
        missing
    )

    data.steel_stat = ifelse.(
        (data.m_target .== 1) .& (data.m_steel_hit .== 1),
        data.m_stattariff1,
        missing
    )

    data.steel1_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_steel_hit, 0) .== 1) .&
        (coalesce.(data.eu, 0) .== 0) .&
        .!in(["CANADA", "MEXICO"], coalesce.(data.cty_name, "")),
        data.m_stattariff1,
        missing
    )

    data.steel2_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_steel_hit, 0) .== 1) .&
        (
            (coalesce.(data.eu, 0) .== 1) .|
            in(["CANADA", "MEXICO"], coalesce.(data.cty_name, ""))
        ),
        data.m_stattariff1,
        missing
    )

    data.china_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_china_hit, 0) .== 1) .&
        (coalesce.(data.cty_name, "") .== "CHINA"),
        data.m_stattariff1,
        missing
    )

    data.china1_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_china_hit, 0) .== 1) .&
        (coalesce.(data.cty_name, "") .== "CHINA") .&
        (coalesce.(data.m_effective_mdate1, -999.0) .== 703),
        data.m_stattariff1,
        missing
    )

    data.china2_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_china_hit, 0) .== 1) .&
        (coalesce.(data.cty_name, "") .== "CHINA") .&
        (coalesce.(data.m_effective_mdate1, -999.0) .== 704),
        data.m_stattariff1,
        missing
    )

    data.china3_stat = ifelse.(
        (coalesce.(data.m_target, 0) .== 1) .&
        (coalesce.(data.m_china_hit, 0) .== 1) .&
        (coalesce.(data.cty_name, "") .== "CHINA") .&
        (coalesce.(data.m_effective_mdate1, -999.0) .== 705),
        data.m_stattariff1,
        missing
    )

    # Convert relevant columns to Float

    float_columns = [
        :m_status1, :mdate, :m_effective_mdate1, :m_solar_hit,
        :m_washer_hit, :m_alum_hit, :eu, :m_stattariff1,
        :m_target, :eventtime, :solar_stat, :washer_stat,
        :alum1_stat, :alum2_stat,
        :alum_stat, :steel_stat, :steel1_stat, :steel2_stat,
        :china_stat, :china1_stat, :china2_stat, :china3_stat
    ]

    for col in float_columns
        if col in names(data)
            data[!, col] = float.(data[!, col]) 
        end
    end

 
    # Adjust for event time safely

    tariff_cols = [
        :solar_stat, :washer_stat, :alum1_stat, :alum2_stat,
        :alum_stat, :steel_stat, :steel1_stat, :steel2_stat,
        :china_stat, :china1_stat, :china2_stat, :china3_stat
    ]

    valid_idx_above = .!(ismissing.(data.eventtime)) .& (data.eventtime .>= 0)
    valid_idx_below = .!(ismissing.(data.eventtime)) .& (data.eventtime .< 0)
    
    for col in tariff_cols

        idx_above = findall(valid_idx_above)
        idx_below = findall(valid_idx_below)
    
        if !isempty(idx_above)
            mean_above_event = safe_mean_skipmissing(data[idx_above, col])
            data[idx_above, col] .= mean_above_event
        else
            data[idx_above, col] .= missing
        end
    
        if !isempty(idx_below)
            mean_below_event = safe_mean_skipmissing(data[idx_below, col])
            data[idx_below, col] .= mean_below_event
        else
            data[idx_below, col] .= missing
        end
    end

    return data
end

function collapse_data(data::DataFrame)::DataFrame
    tariff_cols = [
        :solar_stat, :washer_stat, :alum1_stat, :alum2_stat,
        :alum_stat, :steel_stat, :steel1_stat, :steel2_stat,
        :china_stat, :china1_stat, :china2_stat, :china3_stat
    ]

    tariff_cols_filtered = filter(c -> c in names(data) && 
                            count(!ismissing, data[!, c]) > 0,
                            tariff_cols)
    grouped = groupby(data, :mdate)
    collapsed = combine(
            grouped,
            [col => meanskipping for col in tariff_cols_filtered]...,
            :month => first,
            :year  => first
            )

    return collapsed
end

function plot_tariff_rates(data::DataFrame, output_path::String)
    p = plot()
    tariff_cols = [
        :solar_stat, :washer_stat, :alum1_stat, :alum2_stat,
        :alum_stat, :steel_stat, :steel1_stat, :steel2_stat,
        :china_stat, :china1_stat, :china2_stat, :china3_stat
    ]

    for col in tariff_cols
        plot!(p, data.mdate, data[!, col], label=string(col), lw=2)
    end

    xlabel!(p, "2018")
    ylabel!(p, "U.S. Import Tariff Rate (%)")
    savefig(p, output_path)
end

function run()
    if isempty(DEFAULTS[:root])
        error("Root directory is not set. Please run `set_root_directory(path)` first.")
    end

    # Preprocess and collapse data
    data = preprocess_data("m_flow_hs10_fm_new.dta")
    collapsed_data = collapse_data(data)

    # Plot import tariff rates
    output_path_imports = joinpath(DEFAULTS[:results_main], "fig_01a.pdf")
    plot_tariff_rates(collapsed_data, output_path_imports)

    # Preprocess export data
    export_data = preprocess_data("x_flow_hs10_fm_new.dta")
    collapsed_export_data = collapse_data(export_data)

    # Plot export tariff rates
    output_path_exports = joinpath(DEFAULTS[:results_main], "fig_01b.pdf")
    plot_tariff_rates(collapsed_export_data, output_path_exports)

    println("Plots saved to $(DEFAULTS[:results_main])")
end


end
