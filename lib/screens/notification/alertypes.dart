class AlertsConstants {
  static Map<String, String> alertDesc = {
    "NUA":
        "- provide nutritional feed with high protein and fibre content", //Nutritional alert
    "DRA": "is expected to go dry", //Dry alert
    "HTA": "- Heat alert", //Heat alert for cattle
    "PTA": "is due for pregnancy test", //Pregnancy Test alert
    "CVA": "is due for calving", //Calving alert
    "MKA": "is ready for milking", //Milking alert after calving
    "AIA":
        "is due for Insemination", // Artificial Insemination alert for Heifers
    "DWV": "is due for deworming vaccination", //Deworming vaccination alert
    "BRV": "is due for brucellosis vaccination", //Brucellosis vaccination alert
    "MTV": "is due for modified theileriosis vaccination",
  };

  static Map<String, List<String>> alertsForEvents = {
    "Insemination": <String>["PTA"],
    "Pregnant": <String>["NUA", "DRA", "CVA", "MTV"],
    "Dry": <String>[],
    "Abortion": <String>["AIA", "HTA"],
    "Calved": <String>["MKA", "HTA"],
  };

  static Map<String, String> alertTitle = {
    "NUA": "Nutritional Feed Alert", //Nutritional alert
    "DRA": "Dry Alert",
    "HTA": "Heat Alert",
    "PTA": "Pregnancy Test Alert",
    "CVA": "Calving Alert",
    "MKA": "Milking Alert",
    "AIA": "AI Alert", // Artificial Insemination alert for Heifers
    "DWV": "Deworming Vax Alert",
    "BRV": "Brucellosis Vax Alert",
    "MTV": "Modified Theileriosis Vax Alert",
  };
}
