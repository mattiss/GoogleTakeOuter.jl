module GoogleTakeOuter

const UNKNOWN_DATE = "00000000"

# Write your package code here.
using ZipFile
using Logging
using NativeFileDialog
using ImageMagick

function extract_date_from_filename(filename::String)
    datepattern = r"(?<year>(19|20)\d\d)(?<month>0[1-9]|1[012])(?<day>0[1-9]|[12][0-9]|3[01])"
    m = match(datepattern, filename)
    if (m === nothing)
        return UNKNOWN_DATE
    else
        return m[:year] * m[:month] * m[:day]
    end
end


function extract_date_from_exif(file::IO)
    exif = UNKNOWN_DATE
    infos = ImageMagick.magickinfo(file,( "exif:DateTime"))
    exif = infos["exif:DateTime"]    
    datepattern = r"(?<year>(19|20)\d\d):(?<month>0[1-9]|1[012]):(?<day>0[1-9]|[12][0-9]|3[01])"
    m = match(datepattern, exif)
    if (m === nothing)
        return UNKNOWN_DATE
    else
        return m[:year] * m[:month] * m[:day]
    end
end

function extract_media_from_zipfile(zip_filepath::String, output_folder::String)
    @info "Extracting data from " * abspath(zip_filepath)
    zip = ZipFile.Reader(abspath(zip_filepath))

    for f in zip.files
        filename = String(last(split(f.name,'/')))
        file_data = read(f)

        date = extract_date_from_filename(filename)
        if(date == UNKNOWN_DATE)
            @warn "Reading exif from " * filename
            try
                date = extract_date_from_exif(IOBuffer(file_data))                 
            catch e
                @warn e
            end
        end
        
        year = SubString(date,1:4) * "0000"
        folder_path = abspath(output_folder, year, date * " -")
        mkpath(folder_path)

        new_filepath = abspath(folder_path, filename)
        @info String( filename * " => " * new_filepath)
        try
            write(new_filepath, file_data)     
        catch e
            @warn e
        end
    end
    close(zip)
end

default_folder_input = raw"c:\Temp\takeout"
default_folder_output = raw"c:\Temp\takeout_photos"
files = pick_multi_file(default_folder_input; filterlist="zip")
output_folder = pick_folder(default_folder_output)

@info files
@info output_folder
for filepath in files
    extract_media_from_zipfile(filepath, output_folder)
end

end # module

