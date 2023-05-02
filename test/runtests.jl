using GoogleTakeOuter
using Test

@testset "GoogleTakeOuter.jl" begin
    # Write your tests here.
    @testset "Extract timestamps from filename" begin
        @test isequal(GoogleTakeOuter.extract_date_from_filename("toto"),"000000")
        @test isequal(GoogleTakeOuter.extract_date_from_filename("MVIMG_20190406_172329.jpg"),"201904") 
    end

    @testset "Extract zipfile" begin
        @info "Current Directory: " * pwd()
        filepath = raw"..\data\takeout-20221106T204206Z-009.zip"
        output_folder = raw"..\data\out"
        GoogleTakeOuter.extract_media_from_zipfile(filepath, output_folder) 
    end
    
end
