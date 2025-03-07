# Functions

## WKLib.loadLua(directory, logTable)
This function can be used to load a directory of Lua files. It will automatically load all files in the directory and its subdirectories.
Folders can be prefixed with  01_, 02_, 03_, etc. to control the order in which they are loaded.

**Arguments:**
- `directory` (string): The directory to load Lua files from.
- `logTable` (table): A table containing options for logging. The following options are available:
  - `onFinish` (boolean): Whether to log when the function has finished loading all files. Default is `false`.
  - `eachFolder` (boolean): Whether to log when a folder has been loaded. Default is `false`.
  - `color` (Color): The color to use for the log messages. Default is `Color(255, 0, 0)`.
  - `name` (string): The name to use for the log messages. Required with `onFinish`.
  - `text` (string): The text to use for the log messages. Required with `eachFolder`.

**Example Usage:**
Everything in the `testaddon` directory will be loaded.

Files prefixed with `cl_`, `sh_`, or `sv_` will be loaded on the client, shared, or server respectively.

Folder structure:
```
testaddon/
├── autorun/
│   └── sh_testaddon_autoload.lua
└── testaddon/
    ├── subfolder/
    │   ├── cl_subfile.lua
    │   ├── sh_subfile.lua
    │   └── sv_subfile.lua
    ├── cl_subfile.lua
    ├── sh_subfile.lua
    └── sv_subfile.lua
```
sh_testaddon_autoload.lua
```lua
hook.Add("WKLib:OnLoaded", "testaddon", function()
	WKLib.loadLua("testaddon")
end)
```