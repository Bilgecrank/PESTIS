#include "script_component.hpp"

class CfgPatches
{
	class ADDON
	{
		
		name = "Pestis";
		author = "Bilgecrank";
		url = "";
		requiredVersion = 1.6;
		requiredAddons[] = { "CBA_main" };
		// List of objects (CfgVehicles classes) contained in the addon. Important also for Zeus content (units and groups) unlocking.
		units[] = {};
		// List of weapons (CfgWeapons classes) contained in the addon.
		weapons[] = {};

		// Optional. If this is 1, if any of requiredAddons[] entry is missing in your game the entire config will be ignored and return no error (but in rpt) so useful to make a compat Mod (Since Arma 3 2.14)
		skipWhenMissingDependencies = 1;
	};
	
};

#include "CfgFunctions.hpp"