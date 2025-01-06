using ReplicationProject

using Test
using DataFrames
using StatFiles

@testset "ReplicationProject.jl" begin
    @testset "preprocess_data Tests" begin
        input_data = DataFrame(
            m_status1 = [1, 2, 1],
            m_solar_hit = [0, 1, 0],
            m_stattariff1 = [5.0, 10.0, 0.0],
            mdate = [703, 704, 705],
            m_effective_mdate1 = [703, 704, 705]
        )

    write("test_data.dta", input_data)

    processed_data = preprocess_data("test_data.dta")

    @test :solar_stat in names(processed_data)
    @test :m_status_bool in names(processed_data)

    expected_solar_stat = [missing, 10.0, missing]
    @test processed_data.solar_stat == expected_solar_stat

    end

    @testset "collapse_data Tests" begin
        input_data = DataFrame(
            mdate = [703, 703, 704],
            solar_stat = [10.0, missing, 15.0],
            washer_stat = [5.0, 5.0, missing]
        )

    collapsed_data = collapse_data(input_data)

    @test :solar_stat in names(collapsed_data)
    @test :washer_stat in names(collapsed_data)

    @test collapsed_data.solar_stat == [10.0, 15.0]
    @test collapsed_data.washer_stat == [5.0, missing]
    end

    @testset "run() Tests" begin
        write("m_flow_hs10_fm_new.dta", DataFrame(
            m_status1 = [2],
            m_solar_hit = [1],
            m_stattariff1 = [5.0],
            mdate = [703],
            m_effective_mdate1 = [703]
        ))

        write("x_flow_hs10_fm_new.dta", DataFrame(
            m_status1 = [2],
            m_solar_hit = [1],
            m_stattariff1 = [5.0],
            mdate = [703],
            m_effective_mdate1 = [703]
        ))

    @testset "run Function Execution" begin
        try
            ReplicationProject.run()
            @test true  
        catch
            @test false 
        end
    end
end
end
