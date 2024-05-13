/*
 * Author: Bilgecrank
 * 
 * Instantiate the crates for the mission and set an event handler to save their inventory when finished.
 *
 * Returns: True.
 *
 */

private "_inventory", "_specialInventory";
localNamespace setVariable ["PESTIS_missionActive", true];

localNamespace setVariable ["PESTIS_missionBoxes", [	
		gunCrate,			//0
		bulletCrate, 		//1
		launcherCrate, 		//2
		missileCrate, 		//3
		bombCrate, 			//4
		grenadeCrate,		//5
		uniformCrate, 		//6
		itemCrate, 			//7
		medicalCrate,		//8
		attachmentCrate,	//9
		radioCrate,			//10
		seahawk,			//12
		mrzr1,				//13
		mrzr2,				//14
		rhib1,				//15
		rhib2]				//16
	];

localNamespace setVariable ["PESTIS_vicList", [
		seahawk,
		mrzr1,
		mrzr2,
		rhib1,
		rhib2,
		praetorian1,
		praetorian2,
		vls,
		hammer,
		centurion]
	];

private _saveCrates = {
	private _missionBoxes = localNamespace getVariable "PESTIS_missionBoxes";
	private _boxes = [_missionBoxes, true] call PESTIS_fnc_boxToArray;
	private _specialBoxes = [[specialCrate], false] call PESTIS_fnc_boxToArray;
	profileNamespace setVariable ["PESTIS_crateInventory", _boxes];
	profileNamespace setVariable ["PESTIS_specialInventory", _specialBoxes];
	[_boxes, _specialBoxes];
};

private _saveVics = {
	private _vicList = localNamespace getVariable "PESTIS_vicList";
	{
		private _vehicleState = [_x] call PESTIS_fnc_getVehicleState;
		if !(isNil "_vehicleState") then {
			// Vehicle is alive, set values.
			profileNamespace setVariable ["PESTIS_" + vehicleVarName _x + "Status", _vehicleState];
		} else {
			// Vehicle does not exist, delete variable.
			profileNamespace setVariable ["PESTIS_" + vehicleVarName _x + "Status", nil];
		};
	} forEach _vicList;
};

// Ensure that bags are redistributed during disconnects, so no gear is lost.
addMissionEventHandler ["HandleDisconnect", {
	_thisArgs params ["_saveCrates", "_saveVics"];
	if (allPlayers isEqualTo []) then {
		diag_log text "PESTIS: Last player left the server, saving inventory and vehicle states.";
		private _inventory = [] call _saveCrates;
		[] call _saveVics;
		saveProfileNamespace;
		[(_inventory select 0), (_inventory select 1)] call PESTIS_fnc_loadBoxes;
	};
	false;
	}, 
	[_saveCrates, _saveVics]
	];

addMissionEventHandler ["MPEnded", {
	_thisArgs params ["_saveCrates", "_saveVics"];
	diag_log text "PESTIS: Game ended, saving inventory and vehicle states.";
	localNamespace setVariable ["PESTIS_missionActive", false];
	[] call _saveCrates;
	[] call _saveVics;
	saveProfileNamespace;
	}, 
	[_saveCrates, _saveVics]
	];

// Collect inventory from save.
_inventory = profileNamespace getVariable "PESTIS_crateInventory";
_specialInventory = profileNamespace getVariable "PESTIS_specialInventory";

// Fill crates with saved inventory if available.
if (!isNil "_inventory") then {
	diag_log text "PESTIS: Initializing inventory from save.";
	if (!isNil "_specialInventory") then {
		[_inventory, _specialInventory] call PESTIS_fnc_loadBoxes;
	} else {
		[_inventory] call PESTIS_fnc_loadBoxes;
	};
};

private _vicList = localNamespace getVariable "PESTIS_vicList";
// Set vehicle states as current with the story.
diag_log text "PESTIS: Initalizing vehicle states from save.";
{
	private _vicStatus = profileNamespace getVariable "PESTIS_" + vehicleVarName _x + "Status";
	if !(isNil "_vicStatus") then {
		[_x, _vicStatus] call PESTIS_fnc_setVehicleState;
	};
} forEach _vicList;

// Set auto-save of all crates, only runs when players are active.
[_saveCrates, _saveVics] spawn {
	params ["_saveCrates", "_saveVics"];
	while {sleep 300; localNamespace getVariable "PESTIS_missionActive"} do {
		if !(allPlayers isEqualTo []) then {
			diag_log text "PESTIS: Auto-saving crate inventory and vehicle states.";
			[] call _saveCrates;
			[] call _saveVics;
			saveProfileNamespace;
		};
	};
};

true;