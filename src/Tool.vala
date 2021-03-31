namespace Textpieces {
    
    enum ResultType {
        OK,
        ERROR
    }

    [Compact]
    class Result {
        public string value;
        public ResultType type;

        public Result (string value, ResultType type = ResultType.OK) {
            this.value = value;
            this.type = type;
        }
    }

    delegate Result ToolFunc(string input, string[] args);

    struct Tool {
        public string name;
        public string icon;
        public ToolFunc func;
        public string[] args;
    }

    Tool[] get_tools () {
        return {
            Tool () {
                name = "SHA1 Checksum",
                icon = "fingerprint2-symbolic",
                func = (s) => new Result (
                    Checksum.compute_for_string (ChecksumType.SHA1, s)
                )
            },
            Tool () {
                name = "SHA256 Checksum",
                icon = "fingerprint2-symbolic",
                func = (s) => new Result (
                    Checksum.compute_for_string (ChecksumType.SHA256, s)
                )
            },
            Tool () {
                name = "SHA384 Checksum",
                icon = "fingerprint2-symbolic",
                func = (s) => new Result (
                    Checksum.compute_for_string (ChecksumType.SHA384, s)
                )
            },
            Tool () {
                name = "SHA512 Checksum",
                icon = "fingerprint2-symbolic",
                func = (s) => new Result (
                    Checksum.compute_for_string (ChecksumType.SHA512, s)
                )
            },
            Tool () {
                name = "MD5 Checksum",
                icon = "fingerprint2-symbolic",
                func = (s) => new Result (
                    Checksum.compute_for_string (ChecksumType.MD5, s)
                )
            },
            Tool () {
                name = "Base64 Encode",
                icon = "size-right-symbolic",
                func = (s) => new Result (
                    Base64.encode (s.data)
                )
            },
            Tool () {
                name = "Base64 Decode",
                icon = "size-left-symbolic",
                func = (s) => new Result (
                    (string) Base64.decode (s)
                )
            },
            Tool () {
                name = "Replace substring",
                icon = "edit-find-replace-symbolic",
                func = (s, args) => new Result (
                    s.replace (args[0], args[1])
                ),
                args = {"Find", "Replace"}
            },
            Tool () {
                name = "Replace by regular expression",
                icon = "edit-find-replace-symbolic",
                func = (s, args) => {
                    try {
                        var regex = new Regex (args[0]);
                        
                        return new Result (
                            regex.replace (s, s.length, 0, args[1]),
                            ResultType.OK
                        );
                    } catch (RegexError e) {
                        return new Result (
                            "Incorrect regular expression",
                            ResultType.ERROR
                        );
                    }
                },
                args = {"Find", "Replace"}
            },
            Tool () {
                name = "Remove substring",
                icon = "edit-cut-symbolic",
                func = (s, args) => new Result (
                    s.replace (args[0], "")
                ),
                args = {"Substring"}
            },
            Tool () {
                name = "Remove by regular expression",
                icon = "edit-cut-symbolic",
                func = (s, args) => {
                    try {
                        var regex = new Regex (args[0]);
                        
                        return new Result (
                            regex.replace (s, s.length, 0, ""),
                            ResultType.OK
                        );
                    } catch (RegexError e) {
                        return new Result (
                            "Incorrect regular expression",
                            ResultType.ERROR
                        );
                    }
                },
                args = {"Regular expression"}
            },
            Tool () {
                name = "Remove trailing whitespaces",
                icon = "edit-cut-symbolic",
                func = (s) => {
                    var lines = s.split ("\n");
                    for (var i = 0; i < lines.length; i++)
                        lines[i] = lines[i].strip ();

                    return new Result (
                        string.joinv ("\n", lines)
                    );
                }
            },
            Tool () {
                name = "Count symbols",
                icon = "view-list-ordered-symbolic",
                func = (s) => new Result (
                    s.char_count().to_string()
                )
            },
            Tool () {
                name = "Count lines",
                icon = "view-list-ordered-symbolic",
                func = (s) => new Result (
                    s.split("\n").length.to_string()
                )
            },
            Tool () {
                name = "Format JSON",
                icon = "format-justify-left-symbolic",
                func = (s) => {
                    var parser = new Json.Parser ();
                    try {
                        parser.load_from_data (s);
                    } catch (GLib.Error e) {
                        return new Result (
                            "Bad JSON format",
                            ResultType.ERROR
                        );
                    }
                    var generator = new Json.Generator ();
                    generator.set_root (parser.get_root ());
                    generator.pretty = true;
                    return new Result (
                        generator.to_data (null)
                    );
                }
            },
            Tool () {
                name = "Escape text",
                icon = "security-high-symbolic",
                func = (s) => new Result (
                    s.escape ().replace ("'", "\'")
                )
            },
            Tool () {
                name = "Unescape text",
                icon = "security-low-symbolic",
                func = (s) => new Result (
                    s.replace ("\'", "'").compress ()
                )
            }
        };
    }
}
