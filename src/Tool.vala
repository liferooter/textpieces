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

    delegate Result ToolFunc (string input, string[] args);

    struct Tool {
        public string name;
        public string icon;
        public ToolFunc func;
        public string[] args;
    }

    Result run_script (string script_path, string input, string[] args = {}) {
        string[] cmdline = {
            script_path,
        };
        foreach (var arg in args) {
            cmdline += arg;
        }
        try {
            var process = new Subprocess.newv (
                cmdline,
                SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_PIPE
            );
            string? _stdout;
            string? _stderr;
            process.communicate_utf8 (input, null, out _stdout, out _stderr);
            return (process.get_successful ())
                ? new Result (
                    _stdout ??input
                )
                : new Result (
                    _stderr ?? "Error while running tool",
                    ResultType.ERROR
                );
        } catch (Error e) {
            return new Result (
                e.message,
                ResultType.ERROR
            );
        }
    }

    string script (string name) {
        return Config.SCRIPTSDIR + Path.DIR_SEPARATOR_S + name;
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
                icon = "padlock-symbolic",
                func = (s) => new Result (
                    Base64.encode (s.data)
                )
            },
            Tool () {
                name = "Base64 Decode",
                icon = "padlock-open-symbolic",
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
                        string.joinv ("\n", (string?[]?) lines)
                    );
                }
            },
            Tool () {
                name = "Count symbols",
                icon = "view-list-ordered-symbolic",
                func = (s) => new Result (
                    s.char_count ().to_string ()
                )
            },
            Tool () {
                name = "Count lines",
                icon = "view-list-ordered-symbolic",
                func = (s) => new Result (
                    s.split ("\n").length.to_string ()
                )
            },
            Tool () {
                name = "Count words",
                icon = "view-list-ordered-symbolic",
                func = (s) => run_script (script ("countWords.py"), s)
            },
            Tool () {
                name = "Format JSON",
                icon = "format-justify-left-symbolic",
                func = (s) => {
                    var parser = new Json.Parser ();
                    try {
                        parser.load_from_data (s);
                    } catch (Error e) {
                        return new Result (
                            "Invalide JSON",
                            ResultType.ERROR
                        );
                    }
                    var generator = new Json.Generator ();
                    generator.set_root ((!) parser.get_root ());
                    generator.pretty = true;
                    return new Result (
                        generator.to_data (null)
                    );
                }
            },
            Tool () {
                name = "Minify JSON",
                icon = "format-justify-fill-symbolic",
                func = (s) => {
                    var parser = new Json.Parser ();
                    try {
                        parser.load_from_data (s);
                    } catch (Error e) {
                        return new Result (
                            "Invalide JSON",
                            ResultType.ERROR
                        );
                    }
                    var generator = new Json.Generator ();
                    generator.set_root ((!) parser.get_root ());
                    return new Result (
                        generator.to_data (null)
                    );
                }
            },
            Tool () {
                name = "Escape string",
                icon = "security-high-symbolic",
                func = (s) => run_script (script ("escapeString.py"), s)
            },
            Tool () {
                name = "Unescape string",
                icon = "security-low-symbolic",
                func = (s) => run_script (script ("unescapeString.py"), s)
            },
            Tool () {
                name = "Escape HTML",
                icon = "security-high-symbolic",
                func = (s) => run_script (script ("escapeHTML.py"), s)
            },
            Tool () {
                name = "Unescape HTML",
                icon = "security-low-symbolic",
                func = (s) => run_script (script ("unescapeHTML.py"), s)
            },
            Tool () {
                name = "JSON to YAML",
                icon = "network-transmit-symbolic",
                func = (s) => run_script (script ("jsonToYAML.py"), s)
            },
            Tool () {
                name = "YAML to JSON",
                icon = "network-transmit-symbolic",
                func = (s) => run_script (script ("yamlToJSON.py"), s)
            },
            Tool () {
                name = "URL Encode",
                icon = "web-browser-symbolic",
                func = (s) => new Result (Uri.escape_string (s))
            },
            Tool () {
                name = "URL Decode",
                icon = "web-browser-symbolic",
                func = (s) => {
                    var url = Uri.unescape_string (s);
                    if (url != null)
                        return new Result ((!) url);
                    else
                        return new Result (
                            "Invalid encoded URL",
                            ResultType.ERROR
                        );
                }
            }
        };
    }
}