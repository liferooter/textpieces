namespace Textpieces.Utils {
    Result filter_by_regex (string s, string regex_string, bool invert_match = false) {
        string[] lines = {};
        Regex regex;
        try {
            regex = new Regex (regex_string);
        } catch (RegexError error) {
            return new Result (
                "Invalid regular expression",
                ResultType.ERROR
            );
        }
        foreach (var line in s.split ("\n")) {
            if (regex.match (line) ^ invert_match) {
                lines += line;
            }
        }
        return new Result (
            string.joinv ("\n", (string?[]?) lines)
        );
    }
}