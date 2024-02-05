#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "cba_main",
            "ace_main",
            "ace_medical_treatment"
        };
        author = AUTHOR;
        VERSION_CONFIG;
    };
};

//#include "AMS_Statemachine.hpp"
#include "CfgFunctions.hpp"
#include "CfgEventHandlers.hpp"
#include "ACE_Medical_Treatment.hpp"
#include "ACE_Medical_Treatment_Actions.hpp"