module GoogleTakeOuter

# Write your package code here.
using ZipFile
using Logging

function extract_date_from_filename(filename::String)
    datepattern = r"(?<year>(19|20)\d\d)(?<month>0[1-9]|1[012])(?<day>0[1-9]|[12][0-9]|3[01])"
    m = match(datepattern, filename)
    if (m === nothing)
        return "000000"
    else
        return m[:year] * m[:month]
    end
end


function extract_media_from_zipfile(zip_filepath::String, output_folder::String)
    @info "Extracting data from " * abspath(zip_filepath)
    zip = ZipFile.Reader(abspath(zip_filepath))

    for f in zip.files
        filename = String(last(split(f.name,'/')))

        target_folder = extract_date_from_filename(filename)
        folder_path = abspath(output_folder, target_folder)
        mkpath(folder_path)

        new_filepath = abspath(folder_path, filename)
        @info String( filename * " => " * new_filepath)
        # tada = read(f._io)
        write(new_filepath, read(f._io))
    end
end

@info "Current Directory: " * pwd()
filepath = raw".\GoogleTakeOuter\data\takeout-20221106T204206Z-009.zip"
output_folder = raw".\GoogleTakeOuter\data\out"
extract_media_from_zipfile(filepath, output_folder) 

# using ImageMagick
# jpeg = raw"C:/Dev/julia/GoogleTakeOuter/data/takeout-20221106T204206Z-009/Takeout/Google Photos/Photos from 2019/00000IMG_00000_BURST20190404192247596_COVER.jpg"
# d = ImageMagick.magickinfo(jpeg,( "exif:DateTime"))
# C:\Dev\julia\GoogleTakeOuter\data\takeout-20221106T204206Z-009.zip
end # module
