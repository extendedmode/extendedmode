# extendedmode functions
Functions exclusive to the extendedmode framework

## ExM.Game.PlayAnim
```lua
ExM.Game.PlayAnim(animDict, animName, upperbodyOnly, duration)
```

This function is a quick and easy way to play any animation you want without having to request animation dictionaries or specify a heap of parameters

| Argument 		| Data Type | Optional 	| Default Value 		| Description |
| ------------- | --------- | ----------| --------------------- | ----------- |
| animDict 		| string 	| No 		| - 					| The animation dictionary |
| animName 		| string 	| No 		| - 					| The animation in the dictionary to play |
| upperbodyOnly | boolean 	| Yes 		| false 				| If you want the animation to only affect the upperbody |
| duration 		| integer 	| Yes 		| -1 (full animation) 	| Duration in ms you want the animation to run for |