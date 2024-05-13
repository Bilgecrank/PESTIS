/*
 * Author: Bilgecrank
 * 
 * A function to gather up the total gear from a single crate and put them in another crate
 *
 * Params:
 * 0: Source Container <OBJECT>
 * 1: Target Container <OBEJCT>
 * 2: Strip weapons of attachments <BOOL> DEFAULT: true
 *
 * Returns: True.
 *
 */

params ["_source", "_target", ["_stripWeapons", true]];
private ["_item", "_count"];
private _inventory = [];
private _weapons = weaponsItemsCargo _source;
private _containers = everyContainer _source;

// Handle containers
{
	// Add any weapons stored to the overall weapon storage of the container.
	_weapons append weaponsItemsCargo (_x select 1);
	{
	// Gather all items and magazines.
		_x params ["_item", "_count"];
		for "_i" from 0 to count _item do {
			if !(isNil {_item select _i}) then {
				_inventory pushBack [_item select _i, 
									_count select _i];
			};
		};
	} forEach [(getItemCargo (_x select 1)), (getMagazineCargo (_x select 1))];
} forEach _containers;

// Handle weapons
if _stripWeapons then {
	private _weaponItems = [];
	// Strip attachments and ammo from weapons
	{
		_weaponItems pushBack (_x select 0);
		_weaponItems pushBack (_x select 1);
		_weaponItems pushBack (_x select 2);
		_weaponItems pushBack (_x select 3);
		_weaponItems pushBack ((_x select 4) select 0);
		_weaponItems pushBack ((_x select 5) select 0);
		_weaponItems pushBack (_x select 6);

	} forEach _weapons;
	// Add all attachments, weapons and ammo to inventory individually.
	{
		_target addItemCargo [_x, 1];
	} forEach _weaponItems;
} else {
	// Add all weapons whole, with attachments
	{
		_target addWeaponWithAttachmentsCargo [_x, 1];
	} forEach _weapons;
};

// Handle all non-weapon and non-container items.
{
	_x params ["_item", "_count"];
	for "_i" from 0 to count _item do {
		if !(isNil {_item select _i}) then {
			_inventory pushBack [_item select _i, 
								_count select _i];
		};
	};
} forEach [(getItemCargo _source), (getMagazineCargo _source), (getBackpackCargo _source)];

// Place other items in target container.
{
	[ _x select 0 ] call BIS_fnc_itemType params[ "_type", "_subType" ];
	if (toUpper _subType == "BACKPACK") then {
		_target addBackpackCargo _x;
	} else {
		_target addItemCargo _x;
	};
	
} forEach _inventory;
true;