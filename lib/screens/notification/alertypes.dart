
class AlertsConstants {

  static Map<String, String> alertDesc = {
    "NUA":"provide nutritional feed with high protein and fibre content",//Nutritional alert
    "DRA":"expected to go dry", //Dry alert
    "HTA":"heat alert", //Heat alert for cattle
    "PTA":"due for pregnancy test", //Pregnancy Test alert
    "CVA":"due for calving", //Calving alert
    "MKA":"ready for milking",  //Milking alert after calving
    "AIA":"due for Insemination", // Artificial Insemination alert for Heifers
    "DWV":"due for deworming vaccination",  //Deworning vaccination alert
    "BRV":"due for brucellosis vaccination", //Brucellosis vaccination alert
  };

  static Map<String, List<String>> alertsForEvents = {
    "Insemination": <String>["PTA"],
    "Pregnant": <String>["NUA", "DRA","CVA"],
    "Dry": <String>[],
    "Abortion": <String>["MKA","HTA","AIA"],
    "Calved": <String>["MKA","HTA"],
  };

}