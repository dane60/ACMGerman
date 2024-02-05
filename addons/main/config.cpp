#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "cba_main",
            "ace_main"
        };
        author = AUTHOR;
        //actionName="Website";
		//url="https://discord.gg/aaaaaaaaaaaaaa";
        VERSION_CONFIG;
    };
};

class CfgMods {
    class PREFIX {
        name = "Advanced Medical System";
        author = AUTHOR;
        picture = "icon.paa";
        hidePicture = "true";
        hideName = "true";
    };
};
