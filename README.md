# EXPERIMENTAL
# [Wiki](https://github.com/vugi99/nanos-ground-trace/wiki)

## How it works
* The traces are ordered as chunks, they are saved in the Cache folder for each map when the package is unloaded and the Cache is loaded on package load.
* The server Interval will ask each player that possess a character to calculate traces of the nearest chunk that is not calculated (with a max distance where from the character)
* The client will send back the chunk traces
* The chunk and traces keys are mapped with strings and idk how it works
