# Hooks

## WKLib:OnLoaded
This hook is called when WKLib has been loaded and is ready to be used. All WKLib functions can safely be used in this hook.

**Example Usage:**
```lua
hook.Add("WKLib:OnLoaded", "MyCustomInitialization", function()
    print("WKLib has been loaded!")
end)
```
