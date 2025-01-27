function bx_include()
    local baseFolder = debug.getinfo(1,'S').source:match("^@(.+)/buildSystem/build.lua$")
    includedirs { path.join(baseFolder, "include") }
    
    defines "BX_CONFIG_DEBUG=1"

    filter "action:vs*"
        includedirs { path.join(baseFolder, "include/compat/msvc") }
        buildoptions { "/Zc:__cplusplus" }
    filter { "system:windows", "action:gmake" }
        includedirs { path.join(baseFolder, "include/compat/mingw") }
    filter { "system:macosx" }
        includedirs { path.join(baseFolder, "include/compat/osx") }
        buildoptions { "-x objective-c++" }
        
    --links { "bx" }
end

function bx_project(options)
    options = options or {}
    local baseFolder = debug.getinfo(1,'S').source:match("^@(.+)/buildSystem/build.lua$")

    project "bx"
        kind "StaticLib"
        language "C++"
        cppdialect "C++14"
        targetdir "%{wks.location}/bin/%{cfg.buildcfg}/%{prj.name}"
        location "%{wks.location}/%{prj.name}"
        exceptionhandling "Off"
        rtti "Off"
        defines "__STDC_FORMAT_MACROS"
        files
        {
            path.join(baseFolder, "include/bx/*.h"),
            path.join(baseFolder, "include/bx/inline/*.inl"),
            path.join(baseFolder, "src/*.cpp")
        }
        excludes
        {
            path.join(baseFolder, "src/amalgamated.cpp"),
            path.join(baseFolder, "src/crtnone.cpp")
        }
        includedirs
        {
            path.join(baseFolder, "3rdparty"),
        }
        bx_include()

        filter "action:vs*"
            defines "_CRT_SECURE_NO_WARNINGS"

        if options.dependson then
            dependson { options.dependson }
        end

end