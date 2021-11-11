# IW3 -> IW4X Cubemap Export

## What is this?
This tool exports cubemaps from Call of Duty 4 maps and converts them to the file format that IW4X currently uses to build Call of Duty: Modern Warfare 2 maps.

This is due to the cubemap format in CoD 4 being drastically different from the one MW2 uses. Funnily enough, the CoD 4 map build step for building reflections (cubemaps) draws the cubemap faces to the screen in a sensible format. This is leveraged and dumped with [apitrace](https://github.com/apitrace/apitrace) and then image processed using [sharp](https://github.com/lovell/sharp) in Node.js.

## Usage
1. [Download](https://github.com/Muhlex/iw3-iw4x-cubemap-export/releases) the tool in the release section (or compile yourself).
2. Extract the .zip file and place the contents **inside a new folder with a name of your choice** in your Call of Duty 4 game directory.<br>
⚠️ **No spaces** in the folder name, because I am a good developer.<br>
Example file structure: `Call of Duty 4\iw4x_cubemap_export\build.cmd`
3. Make sure you have the BSP file of the map in `Call of Duty 4\raw\maps\(mp)\mapname.d3dbsp`. When building a custom map, this file is generated in first step of the compiling process. I have no idea how to obtain it from packaged maps (.ff Fastfiles).
4. Run `build.cmd` and type in the name of the map you want to export the cubemaps from.
5. Follow the instructions in the command line.
6. Copy the resulting `.iw4xImage` files into the directory where [IW3X-port](https://github.com/XLabsProject/iw3x-port) exports the map. Currently this is: `IW4X\mods\<mapname>\images\`
7. Build your IW4X map with working cubemaps for specular reflections.
