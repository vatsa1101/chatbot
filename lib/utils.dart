class Utils {
  static String capitalize(String s) {
    if (s.trim() == "") return "";
    return s
        .trim()
        .split(" ")
        .map((str) =>
            str[0].toString().toUpperCase() +
            str.toString().substring(1).toLowerCase())
        .join(" ");
  }
}
