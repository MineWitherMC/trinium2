# Trinium
![Screenshot](screenshot.jpg)

Work-in-Progress technological and magical (sub)game for
[Minetest](https://github.com/minetest/minetest).

***Warning***: *GitHub Repository is readonly. Actual repository is located on
 [GitLab](https://gitlab.com/MultiDragon/trinium).* 

Copyright (c) 2018 Wizzerine <wizzerine@gmail.com> and contributors (none :D).

## This game is not finished
* Don't expect it to work as well as finished one will;
* Don't expect it to not break compatibility in next update, including API one
 (however, I'll try to avoid API breakage);
* Please report any bugs (debug.txt is sometimes useful).

## Compatibility
Requires Minetest `5.0.0-ddd03c3` or higher. Probably some older builds work too,
 but it's not guaranteed.

## Features
* Fantastic Ore and Map Generation System (WIP)
* Realistic (petro)chemistry
* Research system
* Pulse Network, my approach to storage systems (not finished yet)
* Some kind of Tinkers' Construct port (cannot be finished for now)
* Multiblocks
* **Feature-Requests are always welcome, and most of them will be implemented!**

## Version Scheme
Since 1.0-1-1, I use `major.minor-protocol-build`. Prior to that different schemes
 were used.
* `build` is incremented each release.
* `minor` is incremented when release contains non-breaking features.
* `major` is incremented when release breaks API, `minor` is set to `0`.
* `protocol` is incremented when release breaks worlds.
* Additionally, `-dev` is appended if this version doesn't change any content or
 fix bugs and only changes some API.