name = "Ton's Moar Save Slots"
version = "1.1.1"
author = "dustin potter (ifatree)"

description = [["Got any more of them... save game slots?!"

We got "Ton's Moar"! (default 250 // configurable from 50 - 500)

"Ton" on Steam asked for even moar than the original 50 max save game slots from my previous mod, so... 

This mod gives you more saved game slots by showing a page up and page down arrow on the load game screen.

I hope you like hitting the up and down buttons a lot!?

(Probably) Not supported by Klei, Capy, Valve, or anyone else. Please do not hold us responsible for any consequences.

--- (translation by google) ---

该软件为您提供更多保存的游戏插槽。

我希望你喜欢按上下按钮。

开发人员不对后果负责。

]]

forumthread = ""
api_version = 6
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

configuration_options =
{
	{
		name = "Tons_SaveSlots",
		label = "Number of Slots",
		options =	{
						{description = "50", data = "50"},
						{description = "150", data = "150"},
						{description = "250", data = "250"},
						{description = "Ton's", data = "500"},
					},

		default = "500",
	
	},
	
}