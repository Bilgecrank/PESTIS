/*
 * Author: Bilgecrank
 * 
 * Gathers the inventory of one or more crates into one singular crate to export as an inventory array.
 *
 * Params:
 * 0: Source Containers <ARRAY of OBJECTS>
 * 1: Strip weapons of attachments <BOOL> DEFAULT: true
 *
 * Returns: Array of arrays, one containing weapons in a weaponsItems array, one containing all other inventory objects.
 *
 */
 
params ["_boxes", ["_stripWeapons", true]];
private "_weapons";
private _inventory = [];
private _masterBox = "Supply0" createVehicle [0,0,0];
_masterBox setMaxLoad 1000000000000;

{
	[_x, _masterBox, _stripWeapons] call PESTIS_fnc_boxToBox;
} forEach _boxes;

_weapons = weaponsItemsCargo _masterBox;

{
	_x params ["_item", "_count"];
	for "_i" from 0 to count _item do {
		if !(isNil {_item select _i}) then {
			_inventory pushBack [_item select _i, 
								_count select _i];
		};
	};
} forEach [(getItemCargo _masterBox), (getMagazineCargo _masterBox), (getBackpackCargo _masterBox)];

deleteVehicle _masterBox;

[_weapons, _inventory];