# OrcaSlicer Ender-3 V3 KE Profile Fix & Windows Build

## Problem Solved

The issue was that the Ender-3 V3 KE printer profiles in OrcaSlicer were not properly selectable in the slicer interface. This was caused by incomplete printer profile configuration.

## What Was Fixed

### 1. Ender-3 V3 KE Profile Issue
- **Problem**: The main machine profile was missing the `inherits` field and essential printer configuration
- **Solution**: Updated `resources/profiles/Creality/machine/Creality Ender-3 V3 KE.json` to include:
  - Proper inheritance from `fdm_creality_common`
  - Complete printer configuration (printable area, acceleration, speeds, etc.)
  - All nozzle diameter support (0.2, 0.4, 0.6, 0.8mm)
  - Proper G-code flavor (Klipper)
  - Machine-specific settings

### 2. Profile Structure
The Ender-3 V3 KE now has complete profiles:
- **Machine Model**: `Creality Ender-3 V3 KE.json` (base model definition)
- **Nozzle Variants**: 0.2, 0.4, 0.6, 0.8mm nozzle configurations
- **Process Profiles**: Multiple layer height options (0.12mm Fine, 0.16mm Optimal, 0.20mm Standard, 0.24mm Draft, 0.48mm Draft)

## How to Use

### Option 1: Use the Fixed Profiles (Recommended)
1. The profiles are now properly configured and should be selectable in OrcaSlicer
2. When creating a new printer configuration, you should now see "Creality Ender-3 V3 KE" as an option
3. Select the appropriate nozzle diameter variant (0.4mm is most common)

### Option 2: Build Windows Portable Executable

#### Using Docker (Recommended for Windows builds)
```bash
./build_windows_docker.sh
```

This script will:
- Create a Windows Docker container
- Install all necessary build tools
- Build OrcaSlicer for Windows
- Create a portable package
- Output: `OrcaSlicer-Windows-Portable.zip`

#### Manual Cross-Compilation (Advanced)
```bash
./build_windows_cross.sh
```

**Note**: Cross-compilation is complex and may require additional configuration.

## Files Modified

1. **`resources/profiles/Creality/machine/Creality Ender-3 V3 KE.json`**
   - Added proper inheritance and complete printer configuration

2. **`build_windows_docker.sh`** (New)
   - Docker-based Windows build script

3. **`build_windows_cross.sh`** (New)
   - Cross-compilation build script

4. **`cmake/windows-toolchain.cmake`** (New)
   - MinGW cross-compilation toolchain

## Verification

To verify the fix works:
1. Open OrcaSlicer
2. Go to Printer Settings
3. Try to add a new printer
4. Look for "Creality Ender-3 V3 KE" in the list
5. Select it and verify all nozzle variants are available

## Troubleshooting

### Profile Still Not Visible
1. Check that the profile files exist in `resources/profiles/Creality/machine/`
2. Verify the JSON syntax is correct
3. Restart OrcaSlicer after making changes

### Windows Build Issues
1. Ensure Docker is installed and running
2. Check available disk space (build requires ~5-10GB)
3. Build time: 30-60 minutes depending on system

## Technical Details

The Ender-3 V3 KE profile now properly inherits from `fdm_creality_common` and includes:
- **Print Area**: 220x220mm
- **Print Height**: 245mm
- **G-code Flavor**: Klipper
- **Acceleration**: 8000mm/s² (X/Y), 300mm/s² (Z)
- **Max Speeds**: 500mm/s (X/Y), 30mm/s (Z)
- **Retraction**: 0.5mm at 30mm/s
- **Layer Heights**: 0.08mm - 0.32mm

## Support

If you encounter issues:
1. Check the OrcaSlicer GitHub repository
2. Verify your OrcaSlicer version is up to date
3. Ensure all profile files are properly installed
