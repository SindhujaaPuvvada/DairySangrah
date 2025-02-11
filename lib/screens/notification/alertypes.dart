
class AlertsConstants {

  static Map<String, String> alertDesc = {
    "NUA":"- provide nutritional feed with high protein and fibre content",//Nutritional alert
    "DRA":"is expected to go dry", //Dry alert
    "HTA":"- heat alert", //Heat alert for cattle
    "PTA":"is due for pregnancy test", //Pregnancy Test alert
    "CVA":"is due for calving", //Calving alert
    "MKA":"is ready for milking",  //Milking alert after calving
    "AIA":"is due for Insemination", // Artificial Insemination alert for Heifers
    "DWV":"is due for deworming vaccination",  //Deworming vaccination alert
    "BRV":"is due for brucellosis vaccination", //Brucellosis vaccination alert
  };

  static Map<String, List<String>> alertsForEvents = {
    "Insemination": <String>["PTA"],
    "Pregnant": <String>["NUA","DRA","CVA"],
    "Dry": <String>[],
    "Abortion": <String>["MKA","HTA","AIA"],
    "Calved": <String>["MKA","HTA"],
  };

  /*static Map<String, String> alertTitle = {
    "NUA": "Nutritional Feed Alert", //Nutritional alert
    "DRA": "Dry Alert",
    "HTA": "Heat Alert",
    "PTA": "Pregnancy Test Alert",
    "CVA": "Calving Alert",
    "MKA": "Milking Alert",
    "AIA": "AI Alert", // Artificial Insemination alert for Heifers
    "DWV": "Deworming Vaccination Alert",
    "BRV": "Brucellosis vaccination Alert",
  };*/

}