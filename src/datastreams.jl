module DataStreams
    using CSV, EasyStream

    export Dataset1CDT, DatasetUG_2C_5D

    tmp_path = tempdir()
    directory_name = "EasyDataStream"
    local_path = tmp_path * '/' * directory_name
    
    mk_tmp_dir() = mkdir(directory_name)

    function check(name)
        tmp_directories = readdir(tmp_path)
        if directory_name in tmp_directories
            downloaded_datastreams = readdir(local_path)
            
            if(name in downloaded_datastreams)
                return 1
            else
                return 0
            end
        else
            cd(mk_tmp_dir, tmp_path)
            return 0 
        end
    end

    function download(url, name, path)
        current_path = pwd()
        cd(path)
        try
            Base.download(url, name)
        catch
            error("Erro durante o download do DataStream")
            cd(current_path)
            return 0
        end
        cd(current_path)
        return 1
    end

    download(url, name) = download(url, name, local_path)

    #TODO: O retorno dessa função não pode ser o dataStream já na memoria, pois haverá buffers que irão querer somente o path
    function get_datastream(url, name)
        if check(name) == 1
            return CSV.read(local_path * '/' * name; header = false)
        else
            download(url, name)
            return CSV.read(local_path * '/' * name; header = false)
        end
    end

    Dataset1CDT() = Dataset1CDT(150, 1)
    function Dataset1CDT(initial_size::Int, flux_size::Int)
        data = get_datastream("https://raw.githubusercontent.com/Conradox/datastreams/master/sinthetic/1CDT.csv", "1CDT.csv")
        return EasyStream.MemoryBuffer(data, initial_size, flux_size)
    end
    
    function DatasetUG_2C_5D(initial_size::Int, flux_size::Int)
        data = get_datastream("https://raw.githubusercontent.com/Conradox/datastreams/master/sinthetic/UG_2C_5D.csv", "UG_2C_5D.csv")
        return EasyStream.MemoryBuffer(data, initial_size, flux_size)
    end
    DatasetUG_2C_5D() = DatasetUG_2C_5D(150, 1)
end