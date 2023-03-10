extends Node


const ITEM_LIST = {
	"money": { "name": "money", "char": "*", "interact": false, "value": 1, "equip": null,  },
	"stair": { "name": "staircase", "char": ">", "interact": true },
	"sword": { "name": "sword", "char": "/", "interact": false, "value": 2, "equip": "weapon", "effect": {"attack": 2} },
	"knife": { "name": "knife", "char": "-", "interact": false, "value": 1, "equip": "weapon", "effect": {"attack": 1} },
	"ring": {"name": "Ring of Sisyphus", "char": "⏻︎", "interact": false, "value": 100, "equip": null },
	"final_stair": { "name": "final staircase", "char": "<", "interact": true },
}


const ENEMY_LIST = {
	"zombie": { "name": "zamble", "char": "Z", "hp": 3, "attack": 1, "move_delay": 1, "move_range": 1, "notice_range": 8 },
	"rat": { "name": "mini rat", "char": "R", "hp": 2, "attack": 1, "move_delay": 0, "move_range": 2, "notice_range": 12 },
	"frog": { "name": "canetoad", "char": "F", "hp": 4, "attack": 2, "move_delay": 2, "move_range": 5, "notice_range": 14 },
}


const CHARACTER_LIST = {
	"default": { "name": "nameless", "hp": 20, "attack": 2}
}
